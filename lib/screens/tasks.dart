import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/components/task.dart';
import 'package:Focal/components/task_input.dart';
import 'package:Focal/components/task_list_header.dart';
import 'package:Focal/components/nav.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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
  List<DragAndDropList> _tasks = [];
  bool _saving = false;

  void setTasks(List<Task> uncompleted, List<Task> completed) {
    Map taskMap = {};
    List<DragAndDropList> newLists = [];
    if (uncompleted != null && uncompleted.isNotEmpty) {
      for (var task in uncompleted) {
        if (taskMap[task.date] == null) {
          taskMap[task.date] = [];
        }
        taskMap[task.date].add(task);
      }
    }
    if (completed != null && completed.isNotEmpty) {
      taskMap['Completed'] = [];
      for (var task in completed) {
        taskMap['Completed'].add(task);
      }
    }
    if ((uncompleted != null && uncompleted.isNotEmpty) ||
        (completed != null && completed.isNotEmpty)) {
      taskMap.forEach((date, tasks) {
        List<DragAndDropItem> newTasks = [];
        for (var task in tasks) {
          newTasks.add(DragAndDropItem(child: task, canDrag: !task.completed));
        }
        newLists.add(DragAndDropList(
          canDrag: false,
          header: TaskListHeader(date: date),
          children: newTasks,
        ));
      });
    }
    _tasks = newLists;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserStatus>(context);
    var keyboard = KeyboardVisibilityProvider.isKeyboardVisible(context);
    if (!_saving) {
      setTasks(Provider.of<UncompletedTasks>(context).tasks,
          Provider.of<CompletedTasks>(context).tasks);
    }
    return Stack(children: <Widget>[
      Nav(
        title: 'Tasks',
        color: Colors.white,
        rightIconData: FeatherIcons.settings,
        rightOnTap: () {
          widget.goToPage(2);
        },
      ),
      Stack(
        children: <Widget>[
          Positioned(
            right: 0,
            left: 0,
            top: 65,
            child: SizedBox(
              height: SizeConfig.safeHeight - 50,
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
                itemGhost: Divider(
                  color: Theme.of(context).primaryColor,
                  thickness: 2,
                  height: 0,
                ),
                listGhostOpacity: 0,
                lastListTargetSize: 0,
                lastItemTargetHeight: 17,
                addLastItemTargetHeightToTop: true,
                onItemReorder: (int oldItemIndex, int oldListIndex,
                    int newItemIndex, int newListIndex) {
                  TaskListHeader header = _tasks[newListIndex].header;
                  if (header.date != 'Completed') {
                    Task movedTask = _tasks[oldListIndex]
                        .children
                        .removeAt(oldItemIndex)
                        .child;
                    Task newMovedTask = Task(
                      id: movedTask.id,
                      index: newItemIndex,
                      name: movedTask.name,
                      date: header.date,
                      completed: movedTask.completed,
                      paused: movedTask.paused,
                      seconds: movedTask.seconds,
                    );
                    _saving = true;
                    setState(() {
                      _tasks[newListIndex].children.insert(
                            newItemIndex,
                            DragAndDropItem(child: newMovedTask),
                          );
                    });
                    List newTasks = [];
                    if (_tasks[oldListIndex].children.isEmpty) {
                      _tasks.removeAt(oldListIndex);
                    } else {
                      for (var i = 0;
                          i < _tasks[oldListIndex].children.length;
                          i++) {
                        Task task = _tasks[oldListIndex].children[i].child;
                        Task newTask = Task(
                          id: task.id,
                          index: i,
                          name: task.name,
                          date: task.date,
                          completed: task.completed,
                          paused: task.paused,
                          seconds: task.seconds,
                        );
                        newTasks.add(newTask);
                      }
                    }
                    for (var i = 0;
                        i < _tasks[newListIndex].children.length;
                        i++) {
                      Task task = _tasks[newListIndex].children[i].child;
                      Task newTask = Task(
                        id: task.id,
                        index: i,
                        name: task.name,
                        date: task.date,
                        completed: task.completed,
                        paused: task.paused,
                        seconds: task.seconds,
                      );
                      newTasks.add(newTask);
                    }
                    int updatedTasks = 0;
                    newTasks.forEach((task) {
                      task.updateDoc(user, () {
                        updatedTasks++;
                        if (updatedTasks == newTasks.length) {
                          _saving = false;
                        }
                      });
                    });
                  }
                },
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
                children: _tasks,
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: Offstage(
              offstage: keyboard,
              child: AnimatedOpacity(
                duration: keyboardDuration,
                curve: keyboardCurve,
                opacity: keyboard ? 0 : 1,
                child: Button(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      transitionDuration: Duration(seconds: 5),
                      pageBuilder: (_, __, ___) {
                        return TaskInput();
                      },
                    ));
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
    ]);
  }
}
