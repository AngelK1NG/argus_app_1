import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:Focal/utils/database.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/button.dart';
import 'package:Focal/components/task.dart';
import 'package:Focal/components/add_overlay.dart';
import 'package:Focal/components/schedule_overlay.dart';
import 'package:Focal/components/task_list_header.dart';
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
  List<Task> _overdueTasks = [];
  Map<DateTime, List<Task>> _dateTasks = {};
  List<Task> _noDateTasks = [];
  List<Task> _completedTasks = [];
  List<DragAndDropList> _allTasks = [];
  String _text = '';
  DateTime _date = DateProvider().today;
  ScrollController _scrollController = ScrollController();

  void getTasks() {
    List<Task> uncompleted =
        Provider.of<UncompletedTasks>(context, listen: false).tasks;
    List<Task> completed =
        Provider.of<CompletedTasks>(context, listen: false).tasks;
    _overdueTasks = [];
    _dateTasks = {};
    _noDateTasks = [];
    _completedTasks = [];
    if (uncompleted != null && uncompleted.isNotEmpty) {
      for (var task in uncompleted) {
        if (task.date == null) {
          _noDateTasks.add(task);
        } else if (task.date.isBefore(DateProvider().today)) {
          _overdueTasks.add(task);
        } else {
          if (_dateTasks[task.date] == null) {
            _dateTasks[task.date] = [];
          }
          _dateTasks[task.date].add(task);
        }
      }
    }
    if (completed != null && completed.isNotEmpty) {
      for (var task in completed) {
        _completedTasks.add(task);
      }
    }
    setTasks();
  }

  void setTasks() {
    _allTasks = [];
    List<DragAndDropList> allTasks = [];
    if (_overdueTasks.isNotEmpty) {
      List<DragAndDropItem> newTasks = [];
      for (var task in _overdueTasks) {
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
        newTasks.add(DragAndDropItem(child: newTask));
      }
      allTasks.add(DragAndDropList(
        canDrag: false,
        header: TaskListHeader(title: 'Overdue'),
        children: newTasks,
      ));
    }
    if (_dateTasks.isNotEmpty) {
      _dateTasks.forEach((date, tasks) {
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
          newTasks.add(DragAndDropItem(child: newTask));
        }
        allTasks.add(DragAndDropList(
          canDrag: false,
          header: TaskListHeader(title: date),
          children: newTasks,
        ));
      });
    }
    if (_noDateTasks.isNotEmpty) {
      List<DragAndDropItem> newTasks = [];
      for (var task in _noDateTasks) {
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
        newTasks.add(DragAndDropItem(child: newTask));
      }
      allTasks.add(DragAndDropList(
        canDrag: false,
        header: TaskListHeader(title: 'No Date'),
        children: newTasks,
      ));
    }
    if (_completedTasks.isNotEmpty) {
      List<DragAndDropItem> newTasks = [];
      for (var task in _completedTasks) {
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
        newTasks.add(DragAndDropItem(child: newTask, canDrag: false));
      }
      allTasks.add(DragAndDropList(
        canDrag: false,
        header: TaskListHeader(title: 'Completed'),
        children: newTasks,
      ));
    }
    setState(() {
      _allTasks = allTasks;
    });
  }

  void addTask() {
    Task newTask;
    if (_date != null) {
      if (_dateTasks[_date] == null) {
        _dateTasks[_date] = [];
      }
      newTask = Task(
        index: _dateTasks[_date].length,
        name: _text,
        date: _date,
        completed: false,
        paused: false,
        seconds: 0,
      );
      _dateTasks[_date].add(newTask);
    } else {
      newTask = Task(
        index: _noDateTasks.length,
        name: _text,
        date: _date,
        completed: false,
        paused: false,
        seconds: 0,
      );
      _noDateTasks.add(newTask);
    }
    setTasks();
    newTask.addDoc(Provider.of<UserStatus>(context, listen: false));
  }

  void onDismissed(DismissDirection direction, Task task) async {
    if (direction == DismissDirection.startToEnd) {
      DateTime newDate = task.date;
      Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        transitionDuration: Duration(seconds: 5),
        pageBuilder: (_, __, ___) {
          return ScheduleOverlay(
            date: task.date,
            setDate: (date) {
              newDate = date;
            },
            onPop: () async {
              if (newDate != task.date) {
                //   List<DragAndDropItem> newTasks = [];
                //   int listIndex;
                //   String listDate;
                //   for (var i = 0; i < _tasks.length; i++) {
                //     DragAndDropList list = _tasks[i];
                //     TaskListHeader header = list.header;
                //     if (task.date.isEmpty
                //         ? header.date == 'No Date'
                //         : header.date == task.date) {
                //       listIndex = i;
                //       listDate = header.date;
                //     }
                //   }
                //   Task oldTask =
                //       _tasks[listIndex].children.removeAt(task.index).child;
                //   for (var i = 0; i < _tasks[listIndex].children.length; i++) {
                //     Task task = _tasks[listIndex].children[i].child;
                //     Task newTask;
                //     newTask = Task(
                //       id: task.id,
                //       index: i,
                //       name: task.name,
                //       date: task.date,
                //       completed: task.completed,
                //       paused: task.paused,
                //       seconds: task.seconds,
                //       onDismissed: (direction) => onDismissed(direction, newTask),
                //     );
                //     newTasks.add(DragAndDropItem(child: newTask));
                //   }
                //   DragAndDropList removedList = _tasks.removeAt(listIndex);
                //   if (removedList.children.isNotEmpty) {
                //     setState(() {
                //       _tasks.insert(
                //         listIndex,
                //         DragAndDropList(
                //           canDrag: false,
                //           header: TaskListHeader(date: listDate),
                //           children: newTasks,
                //         ),
                //       );
                //     });
                //     await Future.forEach(newTasks, (item) async {
                //       Task task = item.child;
                //       await task.updateDoc(
                //           Provider.of<UserStatus>(context, listen: false));
                //     });
                //   }
                //   int taskIndex = 0;
                //   Provider.of<UncompletedTasks>(context, listen: false)
                //       .tasks
                //       .forEach((task) {
                //     if (task.date == DateProvider().dateString(newDate)) {
                //       taskIndex += 1;
                //     }
                //   });
                //   Task newTask = Task(
                //     id: task.id,
                //     index: taskIndex,
                //     name: oldTask.name,
                //     date: DateProvider().dateString(newDate),
                //     completed: oldTask.completed,
                //     paused: oldTask.paused,
                //     seconds: oldTask.seconds,
                //   );
                //   await newTask
                //       .updateDoc(Provider.of<UserStatus>(context, listen: false));
                //   setState(() => _saving = false);
                // } else {
                //   setState(() {});
              }
            },
          );
        },
      ));
    } else {
      //   _saving = true;
      //   await task.deleteDoc(Provider.of<UserStatus>(context, listen: false));
      //   List<DragAndDropItem> newTasks = [];
      //   int listIndex;
      //   String listDate;
      //   if (task.completed) {
      //     listIndex = _tasks.length - 1;
      //   } else {
      //     for (var i = 0; i < _tasks.length; i++) {
      //       DragAndDropList list = _tasks[i];
      //       TaskListHeader header = list.header;
      //       if (task.date.isEmpty
      //           ? header.date == 'No Date'
      //           : header.date == task.date) {
      //         listIndex = i;
      //         listDate = header.date;
      //       }
      //     }
      //   }
      //   setState(() => _tasks[listIndex].children.removeAt(task.index));
      //   for (var i = 0; i < _tasks[listIndex].children.length; i++) {
      //     Task task = _tasks[listIndex].children[i].child;
      //     Task newTask;
      //     newTask = Task(
      //       id: task.id,
      //       index: i,
      //       name: task.name,
      //       date: task.date,
      //       completed: task.completed,
      //       paused: task.paused,
      //       seconds: task.seconds,
      //       onDismissed: (direction) => onDismissed(direction, newTask),
      //     );
      //     newTasks.add(DragAndDropItem(child: newTask));
      //   }
      //   DragAndDropList removedList = _tasks.removeAt(listIndex);
      //   if (removedList.children.isNotEmpty) {
      //     setState(() {
      //       _tasks.insert(
      //         listIndex,
      //         DragAndDropList(
      //           canDrag: false,
      //           header: TaskListHeader(date: listDate),
      //           children: newTasks,
      //         ),
      //       );
      //     });
      //     await Future.forEach(newTasks, (item) async {
      //       Task task = item.child;
      //       await task.updateDoc(Provider.of<UserStatus>(context, listen: false));
      //     });
      //   }
      //   setState(() => _saving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserStatus>(context);
    return Stack(
      children: [
        CustomScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: TasksSliverAppBar(
                leftOnTap: () {},
                rightOnTap: () => widget.goToPage(2),
                onStretch: () {
                  Future.delayed(Duration.zero, () {
                    getTasks();
                    HapticFeedback.mediumImpact();
                  });
                },
              ),
            ),
            _allTasks.isNotEmpty
                ? SliverPadding(
                    padding: EdgeInsets.only(top: 15),
                    sliver: DragAndDropLists(
                      itemDecorationWhileDragging: BoxDecoration(
                        color:
                            Theme.of(context).backgroundColor.withOpacity(0.8),
                      ),
                      itemGhostOpacity: 1,
                      itemGhost: Divider(
                        color: Theme.of(context).accentColor,
                        thickness: 2,
                        height: 0,
                      ),
                      listGhostOpacity: 0,
                      lastListTargetSize: 15,
                      lastItemTargetHeight: 15,
                      addLastItemTargetHeightToTop: true,
                      sliverList: true,
                      scrollController: _scrollController,
                      itemOnWillAccept: (_, target) {
                        Task task = target.child;
                        if ((task.date != null &&
                                task.date.isBefore(DateProvider().today)) ||
                            task.completed) {
                          return false;
                        } else {
                          return true;
                        }
                      },
                      itemTargetOnWillAccept: (_, target) {
                        DragAndDropList list = target.parent;
                        TaskListHeader header = list.header;
                        if (header.title == 'Overdue' ||
                            header.title == 'Completed') {
                          return false;
                        } else {
                          return true;
                        }
                      },
                      // onItemReorder: (int oldItemIndex, int oldListIndex,
                      //     int newItemIndex, int newListIndex) async {
                      //   _saving = true;
                      //   TaskListHeader oldListHeader = _tasks[oldListIndex].header;
                      //   TaskListHeader newListHeader = _tasks[newListIndex].header;
                      //   Task movedTask = _tasks[oldListIndex]
                      //       .children
                      //       .removeAt(oldItemIndex)
                      //       .child;
                      //   Task newMovedTask;
                      //   newMovedTask = Task(
                      //     id: movedTask.id,
                      //     index: newItemIndex,
                      //     name: movedTask.name,
                      //     date: newListHeader.date == 'No Date'
                      //         ? ''
                      //         : newListHeader.date,
                      //     completed: movedTask.completed,
                      //     paused: movedTask.paused,
                      //     seconds: movedTask.seconds,
                      //     onDismissed: (direction) =>
                      //         onDismissed(direction, newMovedTask),
                      //   );
                      //   setState(() {
                      //     _tasks[newListIndex].children.insert(
                      //           newItemIndex,
                      //           DragAndDropItem(child: newMovedTask),
                      //         );
                      //   });
                      //   List<DragAndDropItem> oldListTasks = [];
                      //   List<DragAndDropItem> newListTasks = [];
                      //   for (var i = 0;
                      //       i < _tasks[oldListIndex].children.length;
                      //       i++) {
                      //     Task task = _tasks[oldListIndex].children[i].child;
                      //     Task newTask;
                      //     newTask = Task(
                      //       id: task.id,
                      //       index: i,
                      //       name: task.name,
                      //       date: task.date,
                      //       completed: task.completed,
                      //       paused: task.paused,
                      //       seconds: task.seconds,
                      //       onDismissed: (direction) =>
                      //           onDismissed(direction, newTask),
                      //     );
                      //     oldListTasks.add(DragAndDropItem(child: newTask));
                      //   }
                      //   for (var i = 0;
                      //       i < _tasks[newListIndex].children.length;
                      //       i++) {
                      //     Task task = _tasks[newListIndex].children[i].child;
                      //     Task newTask;
                      //     newTask = Task(
                      //       id: task.id,
                      //       index: i,
                      //       name: task.name,
                      //       date: task.date,
                      //       completed: task.completed,
                      //       paused: task.paused,
                      //       seconds: task.seconds,
                      //       onDismissed: (direction) =>
                      //           onDismissed(direction, newTask),
                      //     );
                      //     newListTasks.add(DragAndDropItem(child: newTask));
                      //   }
                      //   DragAndDropList removedOldList =
                      //       _tasks.removeAt(oldListIndex);
                      //   if (oldListIndex == newListIndex) {
                      //     setState(() {
                      //       _tasks.insert(
                      //         oldListIndex,
                      //         DragAndDropList(
                      //           canDrag: false,
                      //           header: TaskListHeader(date: oldListHeader.date),
                      //           children: oldListTasks,
                      //         ),
                      //       );
                      //     });
                      //     await Future.forEach(oldListTasks, (item) async {
                      //       Task task = item.child;
                      //       await task.updateDoc(user);
                      //     });
                      //   } else {
                      //     if (oldListIndex > newListIndex) {
                      //       _tasks.removeAt(newListIndex);
                      //       setState(() {
                      //         _tasks.insert(
                      //           newListIndex,
                      //           DragAndDropList(
                      //             canDrag: false,
                      //             header: TaskListHeader(date: newListHeader.date),
                      //             children: newListTasks,
                      //           ),
                      //         );
                      //       });
                      //     } else {
                      //       _tasks.removeAt(newListIndex - 1);
                      //       setState(() {
                      //         _tasks.insert(
                      //           newListIndex - 1,
                      //           DragAndDropList(
                      //             canDrag: false,
                      //             header: TaskListHeader(date: newListHeader.date),
                      //             children: newListTasks,
                      //           ),
                      //         );
                      //       });
                      //     }
                      //     if (removedOldList.children.isNotEmpty) {
                      //       setState(() {
                      //         _tasks.insert(
                      //           oldListIndex,
                      //           DragAndDropList(
                      //             canDrag: false,
                      //             header: TaskListHeader(date: oldListHeader.date),
                      //             children: oldListTasks,
                      //           ),
                      //         );
                      //       });
                      //       await Future.forEach(oldListTasks, (item) async {
                      //         Task task = item.child;
                      //         await task.updateDoc(user);
                      //       });
                      //       await Future.forEach(newListTasks, (item) async {
                      //         Task task = item.child;
                      //         await task.updateDoc(user);
                      //       });
                      //     } else {
                      //       await Future.forEach(newListTasks, (item) async {
                      //         Task task = item.child;
                      //         await task.updateDoc(user);
                      //       });
                      //     }
                      //   }
                      //   setState(() => _saving = false);
                      // },
                      children: _allTasks,
                    ),
                  )
                : SliverToBoxAdapter(child: Container()),
          ],
        ),
        Positioned(
          right: 15,
          bottom: 15,
          child: Button(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
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
                ),
              );
            },
            width: 50,
            row: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FeatherIcons.plus,
                  color: white,
                  size: 20,
                ),
              ],
            ),
            color: Theme.of(context).accentColor,
          ),
        ),
      ],
    );
  }
}

class TasksSliverAppBar extends SliverPersistentHeaderDelegate {
  final VoidCallback leftOnTap;
  final VoidCallback rightOnTap;
  final VoidCallback onStretch;

  TasksSliverAppBar({
    @required this.leftOnTap,
    @required this.rightOnTap,
    @required this.onStretch,
  });

  @override
  OverScrollHeaderStretchConfiguration get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(
        onStretchTrigger: () async => onStretch(),
        stretchTriggerOffset: 100,
      );

  @override
  double get maxExtent => 150;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var user = Provider.of<UserStatus>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.expand,
          overflow: Overflow.visible,
          children: [
            Container(
              color: Theme.of(context).backgroundColor,
            ),
            Center(
              child: Opacity(
                opacity: shrinkOffset < 40
                    ? 0
                    : shrinkOffset > 60
                        ? 1
                        : (shrinkOffset - 40) / 20,
                child: Text(
                  'Tasks',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 15,
              bottom: 22,
              child: Opacity(
                opacity: shrinkOffset < 40
                    ? 1
                    : shrinkOffset > 60
                        ? 0
                        : (60 - shrinkOffset) / 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${TimeOfDay.now().hour < 13 ? 'Good morning' : TimeOfDay.now().hour < 18 ? 'Good afternoon' : 'Good evening'}${user.displayName != null ? ', ' + user.displayName : ''}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${DateProvider().weekdayString(DateTime.now(), true)}, ${DateProvider().monthString(DateTime.now(), true)} ${DateTime.now().day}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: GestureDetector(
                onTap: leftOnTap,
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.transparent,
                  child: Icon(
                    FeatherIcons.barChart2,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: rightOnTap,
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.transparent,
                  child: Icon(
                    FeatherIcons.settings,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 215,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: constraints.maxHeight < 200
                      ? 0
                      : constraints.maxHeight > 250
                          ? 1
                          : (constraints.maxHeight - 200) / 50,
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 194,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: constraints.maxHeight < 200
                      ? 0
                      : constraints.maxHeight > 250
                          ? 1
                          : (constraints.maxHeight - 200) / 50,
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      strokeWidth: 1,
                      value: constraints.maxHeight < 200
                          ? 0
                          : constraints.maxHeight > 250
                              ? 1
                              : (constraints.maxHeight - 200) / 50,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
