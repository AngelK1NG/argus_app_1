import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/utils/size.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/components/task.dart';
import 'package:Focal/components/add_overlay.dart';
import 'package:Focal/components/task_list_header.dart';
import 'package:Focal/components/nav.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
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
  List<DragAndDropList> _tasks = [];
  bool _saving = false;
  String _text = '';
  DateTime _date = DateProvider().today;

  void setTasks(List<Task> uncompleted, List<Task> completed) {
    Map taskMap = {};
    List<DragAndDropList> newLists = [];
    if (uncompleted != null && uncompleted.isNotEmpty) {
      for (var task in uncompleted) {
        if (task.date.isEmpty) {
          if (taskMap['No Date'] == null) {
            taskMap['No Date'] = [];
          }
          taskMap['No Date'].add(task);
        } else if (DateTime.parse(task.date).isBefore(DateProvider().today)) {
          if (taskMap['Overdue'] == null) {
            taskMap['Overdue'] = [];
          }
          taskMap['Overdue'].add(task);
        } else {
          if (taskMap[task.date] == null) {
            taskMap[task.date] = [];
          }
          taskMap[task.date].add(task);
        }
      }
    }
    if (taskMap['No Date'] != null) {
      var noDates = taskMap.remove('No Date');
      taskMap.addAll({'No Date': noDates});
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

  void submitTask(String text) {
    int index = 0;
    Provider.of<UncompletedTasks>(context, listen: false).tasks.forEach((task) {
      if (task.date == DateProvider().dateString(_date)) {
        index += 1;
      }
    });
    Task newTask = Task(
      index: index,
      name: text,
      date: DateProvider().dateString(_date),
      completed: false,
      paused: false,
      seconds: 0,
    );
    newTask.addDoc(Provider.of<UserStatus>(context, listen: false));
    _date = DateProvider().today;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserStatus>(context);
    if (!_saving) {
      setTasks(Provider.of<UncompletedTasks>(context).tasks,
          Provider.of<CompletedTasks>(context).tasks);
    }
    return Stack(
      children: [
        Nav(
          title: 'Tasks',
          color: Colors.white,
          rightIconData: FeatherIcons.settings,
          rightOnTap: () {
            widget.goToPage(2);
          },
        ),
        Positioned(
          right: 0,
          left: 0,
          top: 65,
          child: SizedBox(
            height: SizeProvider.safeHeight - 65,
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
              itemOnWillAccept: (_, target) {
                Task task = target.child;
                if ((task.date.isNotEmpty &&
                        DateTime.parse(task.date)
                            .isBefore(DateProvider().today)) ||
                    task.completed) {
                  return false;
                } else {
                  return true;
                }
              },
              itemTargetOnWillAccept: (_, target) {
                DragAndDropList list = target.parent;
                TaskListHeader header = list.header;
                if (header.date == 'Overdue' || header.date == 'Completed') {
                  return false;
                } else {
                  return true;
                }
              },
              onItemReorder: (int oldItemIndex, int oldListIndex,
                  int newItemIndex, int newListIndex) {
                TaskListHeader header = _tasks[newListIndex].header;
                Task movedTask =
                    _tasks[oldListIndex].children.removeAt(oldItemIndex).child;
                Task newMovedTask = Task(
                  id: movedTask.id,
                  index: newItemIndex,
                  name: movedTask.name,
                  date: header.date == 'No Date' ? '' : header.date,
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
                for (var i = 0; i < _tasks[oldListIndex].children.length; i++) {
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
                for (var i = 0; i < _tasks[newListIndex].children.length; i++) {
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
                if (_tasks[oldListIndex].children.isEmpty) {
                  _tasks.removeAt(oldListIndex);
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
                      padding: EdgeInsets.only(top: 20, left: 50, right: 50),
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
          child: Button(
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                transitionDuration: Duration(seconds: 5),
                pageBuilder: (_, __, ___) {
                  return AddOverlay(
                    text: _text,
                    setText: (text) => _text = text,
                    date: _date,
                    setDate: (date) => _date = date,
                    submit: submitTask,
                  );
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
      ],
    );
  }
}
