import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/components/task.dart';
import 'package:Focal/components/nav_button.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

class TasksPage extends StatefulWidget {
  final Function goToPage;

  TasksPage({
    @required this.goToPage,
    Key key,
  }) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _formKey = GlobalKey<FormState>();
  FocusNode _focus = FocusNode();
  bool _addingTask = false;
  bool _keyboard = false;
  List _uncompletedTasks = [];
  List _completedTasks = [];
  List<DragAndDropList> _dragAndDropList = [];
  void deleteTask(Task task) {}

  void setTasks(UncompletedTasks uncompleted, CompletedTasks completed) {
    Map taskMap = {};
    List<DragAndDropList> newList = [];
    if (uncompleted != null && uncompleted.tasks.isNotEmpty) {
      _uncompletedTasks = uncompleted.tasks;
      for (var task in uncompleted.tasks) {
        if (taskMap[task.date] == null) {
          taskMap[task.date] = [];
        }
        taskMap[task.date].add(task);
      }
    }
    if (completed != null && completed.tasks.isNotEmpty) {
      _completedTasks = completed.tasks;
      taskMap['Completed'] = [];
      for (var task in completed.tasks) {
        taskMap['Completed'].add(task);
      }
    }
    if ((uncompleted != null && uncompleted.tasks.isNotEmpty) ||
        (completed != null && completed.tasks.isNotEmpty)) {
      taskMap.forEach((date, tasks) {
        List<DragAndDropItem> newTasks = [];
        for (var task in tasks) {
          newTasks.add(DragAndDropItem(child: task, canDrag: !task.completed));
        }
        if (date != 'Completed') {
          DateTime dateTime = DateTime.parse(date);
          newList.add(DragAndDropList(
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
          newList.add(DragAndDropList(
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
    }
    _dragAndDropList = newList;
  }

  @override
  void initState() {
    super.initState();
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
    setTasks(Provider.of<UncompletedTasks>(context),
        Provider.of<CompletedTasks>(context));
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
        Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 65,
              child: SizedBox(
                height: _keyboard
                    ? SizeConfig.safeHeight -
                        MediaQuery.of(context).viewInsets.bottom -
                        135
                    : SizeConfig.safeHeight - 65,
                child: DragAndDropLists(
                  itemDecorationWhileDragging: BoxDecoration(
                    color: white.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withOpacity(0.2),
                        spreadRadius: 0,
                        blurRadius: 20, // changes position of shadow
                      ),
                    ],
                  ),
                  itemGhostOpacity: 1,
                  itemGhost: Container(
                    height: 50,
                    width: SizeConfig.safeWidth,
                    color: Theme.of(context).primaryColor,
                  ),
                  listGhostOpacity: 0,
                  lastListTargetSize: 0,
                  lastItemTargetHeight: 15,
                  addLastItemTargetHeightToTop: true,
                  onItemReorder: (_, __, ____, _____) {},
                  contentsWhenEmpty: Center(
                    child: Column(
                      children: [
                        Text(
                          'Start fresh.',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'Got something to do? Add it by tapping the + button.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: _dragAndDropList,
                ),
              ),
            ),
            AnimatedPositioned(
              duration: keyboardDuration,
              curve: keyboardCurve,
              bottom: _addingTask
                  ? MediaQuery.of(context).viewInsets.bottom - 75
                  : -150,
              left: 0,
              right: 0,
              child: Offstage(
                offstage: !_addingTask,
                child: AnimatedContainer(
                  duration: keyboardDuration,
                  curve: keyboardCurve,
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
                          padding: const EdgeInsets.only(left: 21, right: 11),
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
                                onFieldSubmitted: (value) async {},
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
                      FocusScope.of(context).requestFocus(_focus);
                    },
                    width: 50,
                    row: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FeatherIcons.plus,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColorLight
                      ],
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
      ]),
    );
  }
}
