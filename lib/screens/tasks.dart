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
          order: task.data['order'],
          focused: task.data['focused'],
          distracted: task.data['distracted'],
          paused: task.data['paused'],
          key: UniqueKey(),
          date: _date,
        );
        newTask.onDismissed = () => removeTask(newTask);
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
    FirebaseUser user = context.read<User>().user;
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks--;
      }
    });
    firestoreProvider.updateTaskOrder(_tasks, _date);
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(_date);
    dateDoc.updateData({
      'secondsFocused': FieldValue.increment(task.focused == null ? 0 : -task.focused),
      'secondsDistracted': FieldValue.increment(task.distracted == null ? 0 : -task.distracted),
      'secondsPaused': FieldValue.increment(task.paused == null ? 0 : -task.paused),
    }).then((_) {
      dateDoc.get().then((snapshot) {
        if (snapshot.data['secondsFocused'] < 0) {
          dateDoc.updateData({
            'secondsFocused': 0,
          });
        }
        if (snapshot.data['secondsDistracted'] < 0) {
          dateDoc.updateData({
            'secondsDistracted': 0,
          });
        }
        if (snapshot.data['secondsPaused'] < 0) {
          dateDoc.updateData({
            'secondsPaused': 0,
          });
        }
      });
    });
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
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    FirestoreProvider firestoreProvider = FirestoreProvider(user);
    return WrapperWidget(
      loading: _loading,
      nav: true,
      cardPosition: MediaQuery.of(context).size.height / 2 - 240,
      backgroundColor: Theme.of(context).primaryColor,
      staticChild: Stack(
        children: <Widget>[
          Positioned(
            right: 30,
            top: 30,
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
        ]
      ),
      dynamicChild: Stack(
        children: <Widget>[
          Positioned(
            right: 0,
            left: 0,
            top: MediaQuery.of(context).size.height / 2 - 240,
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2 + 240,
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
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width - 100,
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
                                    key: UniqueKey(),
                                    order: _tasks.length - _completedTasks,
                                    date: _date,
                                  );
                                  newTask.onDismissed = () => removeTask(newTask);
                                  newTask.onUpdate = (value) => newTask.name = value;
                                  setState(() {
                                    _tasks.insert(
                                        _tasks.length - _completedTasks, newTask);
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
                                  }).then((doc) {
                                    _tasks[_tasks.length - _completedTasks - 1].id =
                                        doc.documentID;
                                    firestoreProvider.updateTaskOrder(_tasks, _date);
                                    DocumentReference dateDoc = db
                                        .collection('users')
                                        .document(user.uid)
                                        .collection('tasks')
                                        .document(_date);
                                    dateDoc.updateData({
                                      'totalTasks': FieldValue.increment(1),
                                    });
                                  });
                                  _formKey.currentState.reset();
                                  AnalyticsProvider().logAddTask(newTask, DateTime.now());
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
                      tasks.insert(newIndex - (_completedTasks - distanceFromEnd), task);
                      firestoreProvider.updateTaskOrder(tasks, _date);
                    } else {
                      tasks.insert(newIndex, task);
                      firestoreProvider.updateTaskOrder(tasks, _date);
                    }
                  }
                }),
                children: _tasks,
              ),
            ),
          ),
          Positioned(
            right: 30,
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
