import 'package:Focal/utils/user.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/constants.dart';
import 'package:provider/provider.dart';
import 'task_item.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskList extends StatefulWidget {
  final String date;
  const TaskList({Key key, this.date}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<TaskItem> _tasks = [];
  final _formKey = GlobalKey<FormState>();
  DocumentSnapshot _completedTasks;
  bool _loading = false;

  void toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  @override
  void initState() {
    super.initState();
    FirebaseUser user = context.read<User>().user;
    db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(widget.date)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      setState(() {
        _completedTasks = snapshot;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FirebaseUser user = Provider.of<User>(context, listen: false).user;
    FirestoreProvider firestoreProvider =
        FirestoreProvider(Provider.of<User>(context, listen: false).user);
    return StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('users')
            .document(user.uid)
            .collection('tasks')
            .document(widget.date)
            .collection('tasks')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || _loading) {
            return Center(child: CircularProgressIndicator());
          }
          _tasks = [];
          final data = snapshot.data.documents;
          for (var task in data) {
            String name = task.data['name'];
            TaskItem actionItem = TaskItem(
              name: name,
              id: task.documentID,
              completed: task.data['completed'],
              order: task.data['order'],
              key: UniqueKey(),
              onDismissed: () {
                _tasks.remove(
                    _tasks.firstWhere((tasku) => tasku.id == task.documentID));
                firestoreProvider.updateTaskOrder(_tasks, widget.date);
              },
              date: widget.date,
            );
            _tasks.add(actionItem);
          }
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
                              toggleLoading();
                              TaskItem newTask = TaskItem(
                                name: value,
                                completed: false,
                                key: UniqueKey(),
                                order: _tasks.length -
                                    (_completedTasks.data == null
                                        ? 0
                                        : _completedTasks
                                            .data['completedTasks']),
                                onDismissed: () => firestoreProvider
                                    .updateTaskOrder(_tasks, widget.date),
                                date: widget.date,
                              );
                              String userId = user.uid;
                              DocumentReference dateDoc = db
                                  .collection('users')
                                  .document(userId)
                                  .collection('tasks')
                                  .document(widget.date);
                              db
                                  .collection('users')
                                  .document(userId)
                                  .collection('tasks')
                                  .document(widget.date)
                                  .collection('tasks')
                                  .add({
                                'name': newTask.name,
                                'order': newTask.order,
                                'completed': newTask.completed,
                              }).then((doc) {
                                newTask.id = doc.documentID;
                                print(newTask.id);
                                _tasks.insert(
                                    _tasks.length -
                                        (_completedTasks.data == null
                                            ? 0
                                            : _completedTasks
                                                .data['completedTasks']),
                                    newTask);
                                firestoreProvider.updateTaskOrder(
                                    _tasks, widget.date);
                                dateDoc.get().then((snapshot) {
                                  if (snapshot.data == null) {
                                    dateDoc.setData({
                                      'completedTasks': 0,
                                    });
                                  }
                                });
                                toggleLoading();
                              });
                              _formKey.currentState.reset();
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
                if (newIndex >=
                    tasks.length -
                        (_completedTasks.data == null
                            ? 0
                            : _completedTasks.data['completedTasks'])) {
                  int distanceFromEnd = tasks.length - newIndex;
                  tasks.insert(
                      newIndex -
                          ((_completedTasks.data == null
                                  ? 0
                                  : _completedTasks.data['completedTasks']) -
                              distanceFromEnd),
                      task);
                  firestoreProvider.updateTaskOrder(tasks, widget.date);
                } else {
                  tasks.insert(newIndex, task);
                  firestoreProvider.updateTaskOrder(tasks, widget.date);
                }
              }
            }),
            children: _tasks,
          );
        });
  }
}
