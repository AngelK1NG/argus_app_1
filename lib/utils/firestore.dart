import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/material.dart';
import 'package:Focal/Components/task_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FirestoreProvider {
  // create user document in firestore when signed in with google
  static void createUserDocument(FirebaseUser user) async {
    await db.collection('users').document(user.uid).get().then((doc) {
      if (!doc.exists) {
        db.collection('users').document(user.uid).setData({
          'name': user.displayName,
          'email': user.email,
        });
      } else {
        print('user exists');
      }
    });
  }

  // get the list of tasks
  static StreamBuilder<QuerySnapshot> getTasks(String date) {
    String userId = 'K39LOmjUxQYrtt8x5gjziw4wKZz2';
    return StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('users')
            .document(userId)
            .collection('tasks')
            .document(date)
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
          List<TaskItem> tasks = [];
          for (var task in data) {
            String name = task.data['name'];
            TaskItem actionItem = TaskItem(
              name: name,
              key: UniqueKey(),
            );
            tasks.add(actionItem);
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
            onReorder: ((oldIndex, newIndex) {}),
            children: tasks,
          );
        });
  }

  // add task to firestore method
  static void addTask(String date, int order) async {
    FirebaseUser user = await auth.currentUser();
    String userId = user.uid;
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .add({
      'name': '',
      'order': order,
      'completed': false,
    });
  }

  // update method
  static void updateTask(String name, String date, String taskId) async {
    FirebaseUser user = await auth.currentUser();
    String userId = user.uid;
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .document(taskId)
        .updateData({
      'name': name,
    });
  }

  // delete task
  static void deleteTask(String date, String taskId) async {
    FirebaseUser user = await auth.currentUser();
    String userId = user.uid;
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .document(taskId)
        .delete();
  }
}
