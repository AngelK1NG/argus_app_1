import 'dart:collection';

import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/components/task_item.dart';
import 'package:Focal/components/nav_button.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

class TasksPage extends StatefulWidget {
  final Function goToPage;
  final Function setLoading;

  TasksPage({
    @required this.goToPage,
    @required this.setLoading,
    Key key,
  }) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _formKey = GlobalKey<FormState>();
  FocusNode _focus = FocusNode();
  FirebaseUser _user;
  bool _loading = false;
  bool _addingTask = false;
  bool _keyboard = false;
  Map<String, List<TaskItem>> _taskMap = {};
  List<DragAndDropList> _taskList = [];
  void deleteTask(TaskItem task) {}

  void setTasks(Map taskMap) {
    List<DragAndDropList> newTaskList = [];
    taskMap.forEach((date, tasks) {
      List<DragAndDropItem> newTasks = [];
      for (var task in tasks) {
        newTasks.add(DragAndDropItem(child: task, canDrag: !task.completed));
      }
      if (date != 'Completed') {
        DateTime dateTime = DateTime.parse(date);
        newTaskList.add(DragAndDropList(
          canDrag: false,
          header: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.centerLeft,
            height: 20,
            child: Text(
              '${dateTime.month.toString()}/${dateTime.day}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          children: newTasks,
        ));
      } else {
        newTaskList.add(DragAndDropList(
          canDrag: false,
          header: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            alignment: Alignment.centerLeft,
            height: 20,
            child: Text(
              'Completed',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          children: newTasks,
        ));
      }
    });
    _taskMap = taskMap;
    _taskList = newTaskList;
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(loadingDelay, () {
      if (_loading && mounted) {
        widget.setLoading(true);
      }
    });
    _user = Provider.of<User>(context, listen: false).user;
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          _keyboard = visible;
        });
        if (!visible) {
          FocusScope.of(context).unfocus();
          setState(() {
            _addingTask = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('users')
            .document(_user.uid)
            .collection('completed')
            .orderBy('date', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, completedSnapshot) {
          return StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('users')
                  .document(_user.uid)
                  .collection('uncompleted')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, uncompletedSnapshot) {
                Map<String, List<TaskItem>> newTaskMap = {};
                if (uncompletedSnapshot.hasData &&
                    uncompletedSnapshot.data.documents.isNotEmpty) {
                  for (var task in uncompletedSnapshot.data.documents) {
                    if (newTaskMap[task.data['date']] == null) {
                      newTaskMap[task.data['date']] = [];
                    }
                    newTaskMap[task.data['date']].add(TaskItem(
                      name: task.data['name'],
                      index: task.data['index'],
                      completed: false,
                      paused: task.data['paused'],
                    ));
                  }
                }
                if (completedSnapshot.hasData &&
                    completedSnapshot.data.documents.isNotEmpty) {
                  for (var task in completedSnapshot.data.documents) {
                    if (newTaskMap['Completed'] == null) {
                      newTaskMap['Completed'] = [];
                    }
                    newTaskMap['Completed'].add(TaskItem(
                      name: task.data['name'],
                      index: task.data['index'],
                      completed: true,
                    ));
                  }
                }
                setTasks(newTaskMap);
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Stack(children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      child: Text(
                        'Tasks',
                        style: whiteHeaderTextStyle,
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 0,
                      child: NavButton(
                        onTap: () {
                          widget.goToPage(2);
                        },
                        iconData: FeatherIcons.settings,
                        color: white,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: _loading ? 0 : 1,
                      duration: cardDuration,
                      curve: cardCurve,
                      child: Opacity(
                        opacity: _loading ? 0 : 1,
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              right: 0,
                              left: 0,
                              top: 65,
                              child: SizedBox(
                                height: _keyboard
                                    ? SizeConfig.safeHeight -
                                        MediaQuery.of(context)
                                            .viewInsets
                                            .bottom -
                                        135
                                    : SizeConfig.safeHeight - 65,
                                child: DragAndDropLists(
                                  itemDecorationWhileDragging: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: black.withOpacity(0.2),
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        offset: Offset(
                                            0, 0), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  itemGhostOpacity: 0,
                                  listGhostOpacity: 0,
                                  lastListTargetSize: 0,
                                  lastItemTargetHeight: 15,
                                  addLastItemTargetHeightToTop: true,
                                  onItemReorder: (_, __, ____, _____) {},
                                  children: _taskList,
                                ),
                              ),
                            ),
                            AnimatedPositioned(
                              duration: keyboardDuration,
                              curve: keyboardCurve,
                              bottom: _addingTask
                                  ? MediaQuery.of(context).viewInsets.bottom -
                                      75
                                  : -150,
                              left: 0,
                              right: 0,
                              child: Offstage(
                                offstage: !_addingTask,
                                child: AnimatedContainer(
                                  duration: cardDuration,
                                  curve: cardCurve,
                                  height: 150,
                                  width: SizeConfig.safeWidth,
                                  alignment: Alignment.topLeft,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(40),
                                      topRight: Radius.circular(40),
                                    ),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        spreadRadius: -5,
                                        blurRadius: 15,
                                        color: black,
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    height: 75,
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 21, right: 11),
                                          child: Icon(
                                            FeatherIcons.plus,
                                            size: 18,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: SizeConfig.safeWidth - 75,
                                          child: Focus(
                                            onFocusChange: (focus) {
                                              if (!focus) {
                                                setState(() {
                                                  _addingTask = false;
                                                });
                                              }
                                            },
                                            child: Form(
                                              key: _formKey,
                                              child: TextFormField(
                                                focusNode: _focus,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Add task...",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400,
                                                  color: black,
                                                ),
                                                autofocus: false,
                                                onFieldSubmitted:
                                                    (value) async {},
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 20,
                              child: Offstage(
                                offstage: _keyboard,
                                child: AnimatedOpacity(
                                  duration: keyboardDuration,
                                  curve: keyboardCurve,
                                  opacity: _keyboard ? 0 : 1,
                                  child: Button(
                                    onTap: () {
                                      setState(() {
                                        _addingTask = true;
                                      });
                                      FocusScope.of(context)
                                          .requestFocus(_focus);
                                    },
                                    width: 50,
                                    row: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FeatherIcons.plus,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    gradient: LinearGradient(
                                      colors: [blue, purple],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    vibrate: true,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                );
              });
        });
  }
}
