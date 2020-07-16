import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/constants.dart';
import 'task_item.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskList extends StatefulWidget {
  final String userId;
  final String date;
  const TaskList({Key key, this.date, this.userId}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<TaskItem> _tasks = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('users')
            .document(widget.userId)
            .collection('tasks')
            .document(widget.date)
            .collection('tasks')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
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
              onDismissed: () =>
                  FirestoreProvider.updateTaskOrder(_tasks, widget.date),
            );
            _tasks.add(actionItem);
          }
          return ReorderableListView(
            header: GestureDetector(
              onTap: () {},
              child: Container(
                child: GestureDetector(
                  onTap: () {},
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
                          child: TextFormField(
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Add task",
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).hintColor,
                              ),
                              autofocus: false,
                              onFieldSubmitted: (value) {
                                TaskItem newTask = TaskItem(
                                  name: value,
                                  completed: false,
                                  key: UniqueKey(),
                                  order: _tasks.length + 1,
                                  onDismissed: () =>
                                      FirestoreProvider.updateTaskOrder(
                                          _tasks, widget.date),
                                );
                                _tasks.add(newTask);

                                FirestoreProvider.addTask(newTask, widget.date);
                              }),
                        ),
                      ),
                    ],
                  ),
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
            ),
            onReorder: ((oldIndex, newIndex) {
              List<TaskItem> tasks = _tasks;
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final task = tasks.removeAt(oldIndex);
              print(task);
              tasks.insert(newIndex, task);
              print(tasks);
              print(_tasks);
              FirestoreProvider.updateTaskOrder(tasks, widget.date);
            }),
            children: _tasks,
          );
        });
  }
}
