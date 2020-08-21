import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Focal/components/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:Focal/utils/analytics.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/size_config.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/sqr_button.dart';
import 'package:Focal/components/task_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TasksPage extends StatefulWidget {
  TasksPage({Key key}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _formKey = GlobalKey<FormState>();
  String _date;
  FirebaseUser user;
  bool _loading = true;
  List<TaskItem> _tasks = [];
  int _completedTasks;
  double _safeAreaDifference = 0;
  double _bottomPadding = 0;

  void getCompletedTasks() {
    FirebaseUser user = context.read<User>().user;
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.get().then((snapshot) {
      if (snapshot.data == null) {
        _completedTasks = 0;
        dateDoc.setData({
          'completedTasks': 0,
          'totalTasks': 0,
        });
      } else {
        setState(() {
          _completedTasks = snapshot.data['completedTasks'];
        });
      }
    });
  }

  void getTasks() {
    _tasks = [];
    FirebaseUser user = context.read<User>().user;
    db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date)
        .collection('tasks')
        .orderBy('order')
        .getDocuments()
        .then((snapshot) {
      snapshot.documents.forEach((task) {
        String name = task.data['name'];
        TaskItem newTask = TaskItem(
          name: name,
          id: task.documentID,
          completed: task.data['completed'],
          saved: task.data['saved'],
          order: task.data['order'],
          secondsFocused: task.data['secondsFocused'],
          secondsDistracted: task.data['secondsDistracted'],
          secondsPaused: task.data['secondsPaused'],
          numDistracted: task.data['numDistracted'],
          numPaused: task.data['numPaused'],
          key: UniqueKey(),
          date: _date,
        );
        newTask.onDismissed = () {
          removeTask(newTask);
          AnalyticsProvider().logDeleteTask(newTask, DateTime.now());
        };
        newTask.onUpdate = (value) => newTask.name = value;
        setState(() {
          _tasks.add(newTask);
        });
      });
      setState(() {
        _loading = false;
      });
    });
  }

  void removeTask(TaskItem task) {
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    firestoreProvider.deleteTask(task, _date);
    firestoreProvider.updateTasks(_tasks, _date);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _date = getDateString(DateTime.now());
    });
    getCompletedTasks();
    getTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool isKeyboardVisible =
        MediaQuery.of(context).viewInsets.bottom > 0.0;
    if (isKeyboardVisible) {
      setState(() {
        _safeAreaDifference = 0;
      });
    } else {
      setState(() {
        _bottomPadding = MediaQuery.of(context).padding.bottom;
        _safeAreaDifference = MediaQuery.of(context).padding.bottom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    FirestoreProvider firestoreProvider = FirestoreProvider(user);
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: (SizeConfig.safeBlockVertical * 100 +
              _safeAreaDifference -
              _bottomPadding) *
          0.15,
      backgroundColor: Theme.of(context).primaryColor,
      staticChild: Stack(children: <Widget>[
        Positioned(
          right: 40,
          top: (SizeConfig.safeBlockVertical * 100 +
                  _safeAreaDifference -
                  _bottomPadding) *
              0.05,
          child: Text(
            (DateTime.parse(_date).year == DateTime.now().year &&
                    DateTime.parse(_date).month == DateTime.now().month &&
                    DateTime.parse(_date).day == DateTime.now().day)
                ? "Today"
                : (DateTime.parse(_date).year == DateTime.now().year &&
                        DateTime.parse(_date).month == DateTime.now().month &&
                        DateTime.parse(_date).day == DateTime.now().day + 1)
                    ? "Tomorrow"
                    : DateTime.parse(_date).month.toString() +
                        "/" +
                        DateTime.parse(_date).day.toString(),
            style: headerTextStyle,
          ),
        ),
      ]),
      dynamicChild: Stack(
        children: <Widget>[
          Positioned(
            right: 0,
            left: 0,
            top: (SizeConfig.safeBlockVertical * 100 +
                        _safeAreaDifference -
                        _bottomPadding) *
                    0.15 +
                20,
            child: SizedBox(
              height: SizeConfig.safeBlockVertical * 85 - 20,
              child: ReorderableListView(
                header: Container(
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 31, right: 11),
                        child: FaIcon(
                          FontAwesomeIcons.plus,
                          size: 15,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width - 116,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Add task...",
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              autofocus: false,
                              onFieldSubmitted: (value) async {
                                if (_formKey.currentState.validate()) {
                                  HapticFeedback.heavyImpact();
                                  TaskItem newTask = TaskItem(
                                    id: '',
                                    name: value,
                                    completed: false,
                                    saved: false,
                                    key: UniqueKey(),
                                    order: _tasks.length - _completedTasks,
                                    date: _date,
                                  );
                                  newTask.onDismissed = () {
                                    removeTask(newTask);
                                    AnalyticsProvider().logDeleteTask(newTask, DateTime.now());
                                  };
                                  newTask.onUpdate =
                                      (value) => newTask.name = value;
                                  setState(() {
                                    _tasks.insert(
                                        _tasks.length - _completedTasks,
                                        newTask);
                                  });
                                  String userId = user.uid;
                                  db
                                      .collection('users')
                                      .document(userId)
                                      .collection('tasks')
                                      .document(_date)
                                      .collection('tasks')
                                      .add({
                                    'name': newTask.name,
                                    'order': newTask.order,
                                    'completed': newTask.completed,
                                    'saved': newTask.saved,
                                  }).then((doc) {
                                    _tasks[_tasks.length - _completedTasks - 1]
                                        .id = doc.documentID;
                                    firestoreProvider.updateTasks(
                                        _tasks, _date);
                                  });
                                  _formKey.currentState.reset();
                                  AnalyticsProvider()
                                      .logAddTask(newTask, DateTime.now());
                                }
                              },
                              validator: (value) {
                                return value.isEmpty
                                    ? 'You cannot add an empty task'
                                    : null;
                              }),
                        ),
                      ),
                    ],
                  ),
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerLeft,
                ),
                onReorder: ((oldIndex, newIndex) {
                  if (!_tasks[oldIndex].completed) {
                    List<TaskItem> tasks = _tasks;
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final task = tasks.removeAt(oldIndex);
                    if (newIndex >= tasks.length - _completedTasks) {
                      int distanceFromEnd = tasks.length - newIndex;
                      tasks.insert(
                          newIndex - (_completedTasks - distanceFromEnd), task);
                      firestoreProvider.updateTasks(tasks, _date);
                    } else {
                      tasks.insert(newIndex, task);
                      firestoreProvider.updateTasks(tasks, _date);
                    }
                  }
                }),
                children: _tasks,
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: 30,
            child: SqrButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 28,
              ),
              onTap: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.parse(_date),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2120),
                ).then((date) {
                  if (date != null) {
                    setState(() {
                      _date = getDateString(date);
                    });
                    getCompletedTasks();
                    getTasks();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
