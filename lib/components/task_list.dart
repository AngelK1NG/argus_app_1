import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/constants.dart';
import 'task_item.dart';
import 'package:Focal/utils/firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskList extends StatefulWidget {
  final String date;
  final String userId;
  const TaskList({Key key, this.date, this.userId}) : super(key: key);

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<TaskItem> _tasks = [];
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
            return Center(
                child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).accentColor,
            ));
          }
          final data = snapshot.data.documents;
          for (var task in data) {
            String name = task.data['name'];
            TaskItem actionItem = TaskItem(
              name: name,
              id: task.documentID,
              completed: task.data['completed'],
              order: task.data['order'],
              key: UniqueKey(),
            );
            _tasks.add(actionItem);
          }
          return ReorderableListView(
            header: GestureDetector(
              onTap: () {},
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    var now = DateTime.now();
                    String day = now.day.toString();
                    String month = now.month.toString();
                    String year = now.year.toString();
                    if (day.length == 1) {
                      day = '0' + day;
                    }
                    if (month.length == 1) {
                      month = '0' + month;
                    }
                    String date = month + day + year;
                    FirestoreProvider.addTask(date, 1);
                  },
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
                          onSaved: (value) {},
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
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              setState(() {
                final task = _tasks.removeAt(oldIndex);
                _tasks.insert(newIndex, task);
              });
            }),
            children: _tasks,
          );
        });
  }
}
