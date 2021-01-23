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
import 'package:Focal/components/schedule_overlay.dart';
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
          Task newTask;
          newTask = Task(
            index: task.index,
            name: task.name,
            date: task.date,
            completed: task.completed,
            paused: task.paused,
            seconds: task.seconds,
            id: task.id,
            onDismissed: (direction) => onDismissed(direction, newTask),
            onTap: () {},
          );
          newTasks
              .add(DragAndDropItem(child: newTask, canDrag: !task.completed));
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

  void addTask() {
    int index = 0;
    Provider.of<UncompletedTasks>(context, listen: false).tasks.forEach((task) {
      if (task.date == DateProvider().dateString(_date)) {
        index += 1;
      }
    });
    Task newTask = Task(
      index: index,
      name: _text,
      date: DateProvider().dateString(_date),
      completed: false,
      paused: false,
      seconds: 0,
    );
    newTask.addDoc(Provider.of<UserStatus>(context, listen: false));
    _date = DateProvider().today;
  }

  void onDismissed(DismissDirection direction, Task task) async {
    if (direction == DismissDirection.startToEnd) {
      DateTime newDate = task.date.isEmpty ? null : DateTime.parse(task.date);
      Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        transitionDuration: Duration(seconds: 5),
        pageBuilder: (_, __, ___) {
          return ScheduleOverlay(
            date: task.date.isEmpty ? null : DateTime.parse(task.date),
            setDate: (date) {
              newDate = date;
            },
            onPop: () async {
              if (task.date.isEmpty
                  ? newDate != null
                  : newDate != DateTime.parse(task.date)) {
                _saving = true;
                List<DragAndDropItem> newTasks = [];
                int listIndex;
                String listDate;
                for (var i = 0; i < _tasks.length; i++) {
                  DragAndDropList list = _tasks[i];
                  TaskListHeader header = list.header;
                  if (task.date.isEmpty
                      ? header.date == 'No Date'
                      : header.date == task.date) {
                    listIndex = i;
                    listDate = header.date;
                  }
                }
                Task oldTask =
                    _tasks[listIndex].children.removeAt(task.index).child;
                for (var i = 0; i < _tasks[listIndex].children.length; i++) {
                  Task task = _tasks[listIndex].children[i].child;
                  Task newTask;
                  newTask = Task(
                    id: task.id,
                    index: i,
                    name: task.name,
                    date: task.date,
                    completed: task.completed,
                    paused: task.paused,
                    seconds: task.seconds,
                    onDismissed: (direction) => onDismissed(direction, newTask),
                  );
                  newTasks.add(DragAndDropItem(child: newTask));
                }
                DragAndDropList removedList = _tasks.removeAt(listIndex);
                if (removedList.children.isNotEmpty) {
                  setState(() {
                    _tasks.insert(
                      listIndex,
                      DragAndDropList(
                        canDrag: false,
                        header: TaskListHeader(date: listDate),
                        children: newTasks,
                      ),
                    );
                  });
                  await Future.forEach(newTasks, (item) async {
                    Task task = item.child;
                    await task.updateDoc(
                        Provider.of<UserStatus>(context, listen: false));
                  });
                }
                int taskIndex = 0;
                Provider.of<UncompletedTasks>(context, listen: false)
                    .tasks
                    .forEach((task) {
                  if (task.date == DateProvider().dateString(newDate)) {
                    taskIndex += 1;
                  }
                });
                Task newTask = Task(
                  id: task.id,
                  index: taskIndex,
                  name: oldTask.name,
                  date: DateProvider().dateString(newDate),
                  completed: oldTask.completed,
                  paused: oldTask.paused,
                  seconds: oldTask.seconds,
                );
                await newTask
                    .updateDoc(Provider.of<UserStatus>(context, listen: false));
                setState(() => _saving = false);
              } else {
                setState(() {});
              }
            },
          );
        },
      ));
    } else {
      _saving = true;
      await task.deleteDoc(Provider.of<UserStatus>(context, listen: false));
      List<DragAndDropItem> newTasks = [];
      int listIndex;
      String listDate;
      if (task.completed) {
        listIndex = _tasks.length - 1;
      } else {
        for (var i = 0; i < _tasks.length; i++) {
          DragAndDropList list = _tasks[i];
          TaskListHeader header = list.header;
          if (task.date.isEmpty
              ? header.date == 'No Date'
              : header.date == task.date) {
            listIndex = i;
            listDate = header.date;
          }
        }
      }
      setState(() => _tasks[listIndex].children.removeAt(task.index));
      for (var i = 0; i < _tasks[listIndex].children.length; i++) {
        Task task = _tasks[listIndex].children[i].child;
        Task newTask;
        newTask = Task(
          id: task.id,
          index: i,
          name: task.name,
          date: task.date,
          completed: task.completed,
          paused: task.paused,
          seconds: task.seconds,
          onDismissed: (direction) => onDismissed(direction, newTask),
        );
        newTasks.add(DragAndDropItem(child: newTask));
      }
      DragAndDropList removedList = _tasks.removeAt(listIndex);
      if (removedList.children.isNotEmpty) {
        setState(() {
          _tasks.insert(
            listIndex,
            DragAndDropList(
              canDrag: false,
              header: TaskListHeader(date: listDate),
              children: newTasks,
            ),
          );
        });
        await Future.forEach(newTasks, (item) async {
          Task task = item.child;
          await task.updateDoc(Provider.of<UserStatus>(context, listen: false));
        });
      }
      setState(() => _saving = false);
    }
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
            height: SizeProvider.safeHeight - 80,
            child: DragAndDropLists(
              itemDecorationWhileDragging: BoxDecoration(
                color: Theme.of(context).backgroundColor.withOpacity(0.8),
              ),
              itemGhostOpacity: 1,
              itemGhost: Divider(
                color: Theme.of(context).primaryColor,
                thickness: 2,
                height: 0,
              ),
              listGhostOpacity: 0,
              lastListTargetSize: 15,
              lastItemTargetHeight: 15,
              addLastItemTargetHeightToTop: false,
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
                  int newItemIndex, int newListIndex) async {
                _saving = true;
                TaskListHeader oldListHeader = _tasks[oldListIndex].header;
                TaskListHeader newListHeader = _tasks[newListIndex].header;
                Task movedTask =
                    _tasks[oldListIndex].children.removeAt(oldItemIndex).child;
                Task newMovedTask;
                newMovedTask = Task(
                  id: movedTask.id,
                  index: newItemIndex,
                  name: movedTask.name,
                  date:
                      newListHeader.date == 'No Date' ? '' : newListHeader.date,
                  completed: movedTask.completed,
                  paused: movedTask.paused,
                  seconds: movedTask.seconds,
                  onDismissed: (direction) =>
                      onDismissed(direction, newMovedTask),
                );
                setState(() {
                  _tasks[newListIndex].children.insert(
                        newItemIndex,
                        DragAndDropItem(child: newMovedTask),
                      );
                });
                List<DragAndDropItem> oldListTasks = [];
                List<DragAndDropItem> newListTasks = [];
                for (var i = 0; i < _tasks[oldListIndex].children.length; i++) {
                  Task task = _tasks[oldListIndex].children[i].child;
                  Task newTask;
                  newTask = Task(
                    id: task.id,
                    index: i,
                    name: task.name,
                    date: task.date,
                    completed: task.completed,
                    paused: task.paused,
                    seconds: task.seconds,
                    onDismissed: (direction) => onDismissed(direction, newTask),
                  );
                  oldListTasks.add(DragAndDropItem(child: newTask));
                }
                for (var i = 0; i < _tasks[newListIndex].children.length; i++) {
                  Task task = _tasks[newListIndex].children[i].child;
                  Task newTask;
                  newTask = Task(
                    id: task.id,
                    index: i,
                    name: task.name,
                    date: task.date,
                    completed: task.completed,
                    paused: task.paused,
                    seconds: task.seconds,
                    onDismissed: (direction) => onDismissed(direction, newTask),
                  );
                  newListTasks.add(DragAndDropItem(child: newTask));
                }
                DragAndDropList removedOldList = _tasks.removeAt(oldListIndex);
                if (oldListIndex == newListIndex) {
                  setState(() {
                    _tasks.insert(
                      oldListIndex,
                      DragAndDropList(
                        canDrag: false,
                        header: TaskListHeader(date: oldListHeader.date),
                        children: oldListTasks,
                      ),
                    );
                  });
                  await Future.forEach(oldListTasks, (item) async {
                    Task task = item.child;
                    await task.updateDoc(user);
                  });
                } else {
                  if (oldListIndex > newListIndex) {
                    _tasks.removeAt(newListIndex);
                    setState(() {
                      _tasks.insert(
                        newListIndex,
                        DragAndDropList(
                          canDrag: false,
                          header: TaskListHeader(date: newListHeader.date),
                          children: newListTasks,
                        ),
                      );
                    });
                  } else {
                    _tasks.removeAt(newListIndex - 1);
                    setState(() {
                      _tasks.insert(
                        newListIndex - 1,
                        DragAndDropList(
                          canDrag: false,
                          header: TaskListHeader(date: newListHeader.date),
                          children: newListTasks,
                        ),
                      );
                    });
                  }
                  if (removedOldList.children.isNotEmpty) {
                    setState(() {
                      _tasks.insert(
                        oldListIndex,
                        DragAndDropList(
                          canDrag: false,
                          header: TaskListHeader(date: oldListHeader.date),
                          children: oldListTasks,
                        ),
                      );
                    });
                    await Future.forEach(oldListTasks, (item) async {
                      Task task = item.child;
                      await task.updateDoc(user);
                    });
                    await Future.forEach(newListTasks, (item) async {
                      Task task = item.child;
                      await task.updateDoc(user);
                    });
                  } else {
                    await Future.forEach(newListTasks, (item) async {
                      Task task = item.child;
                      await task.updateDoc(user);
                    });
                  }
                }
                setState(() => _saving = false);
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
        // Positioned(
        //   right: 10,
        //   bottom: 10,
        //   child: AnimatedOpacity(
        //     opacity: _saving ? 1 : 0,
        //     duration: fadeDuration,
        //     curve: fadeCurve,
        //     child: SizedBox(
        //       height: 60,
        //       width: 60,
        //       child: CircularProgressIndicator(
        //         backgroundColor: Colors.transparent,
        //         strokeWidth: 2,
        //       ),
        //     ),
        //   ),
        // ),
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
                    submit: addTask,
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
            color: Theme.of(context).primaryColor,
            vibrate: true,
          ),
        ),
      ],
    );
  }
}
