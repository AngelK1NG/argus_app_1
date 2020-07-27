import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/constants.dart';
import 'package:provider/provider.dart';
import 'task_item.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:Focal/utils/date.dart';
import 'package:Focal/utils/analytics.dart';

class TaskList extends StatefulWidget {
  final VoidCallback callback;
  const TaskList({@required this.callback, Key key}) : super(key: key);

  @override
  TaskListState createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  List<TaskItem> _tasks = [];
  final _formKey = GlobalKey<FormState>();
  int _completedTasks;
  String _date = getDateString(DateTime.now());

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
          key: UniqueKey(),
          date: _date,
        );
        newTask.onDismissed = () => removeTask(newTask);
        setState(() {
          _tasks.add(newTask);
        });
      });
      widget.callback();
    });
  }

  void removeTask(TaskItem task) {
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    setState(() {
      _tasks.remove(_tasks.firstWhere((tasku) => tasku.id == task.id));
      if (task.completed) {
        _completedTasks --;
      }
    });
    firestoreProvider.updateTaskOrder(_tasks, _date);
  }

  void setDate(String date) {
    setState(() {
      _date = date;
    });
    getTasks();
  }

  @override
  void initState() {
    super.initState();
    getCompletedTasks();
    getTasks();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);

    return ReorderableListView(
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
                      hintText: "Add task",
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
                          _tasks[_tasks.length - _completedTasks - 1].id = doc.documentID;
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
        height: 50,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
          width: 1,
          color: Theme.of(context).dividerColor,
        ))),
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
    );
  }
}
