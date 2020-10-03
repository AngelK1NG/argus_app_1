import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/task_item.dart';

class FirestoreProvider {
  FirebaseUser user;

  FirestoreProvider(this.user);

  // check if user document exists in firestore
  Future<bool> userDocumentExists() async {
    bool docExists = false;
    await db.collection('users').document(user.uid).get().then((doc) {
      if (!doc.exists) {
        docExists = false;
      } else {
        docExists = true;
      }
    });
    return docExists;
  }

  // create user document in firestore when signed in with google
  void createUserDocument() async {
    await db.collection('users').document(user.uid).get().then((doc) {
      if (!doc.exists) {
        db.collection('users').document(user.uid).setData({
          'name': user.displayName,
          'email': user.email,
        });
      }
    });
  }

  // update tasks
  void updateTasks(List<TaskItem> tasks, String date) {
    String userId = user.uid;
    int totalTasks = 0;
    int completedTasks = 0;
    for (TaskItem task in tasks) {
      db
          .collection('users')
          .document(userId)
          .collection('tasks')
          .document(date)
          .collection('tasks')
          .document(task.id)
          .updateData({
        'name': task.name,
        'order': tasks.indexOf(task) + 1,
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
        'completed': task.completed,
        'paused': task.paused,
      });
      totalTasks ++;
      if (task.completed) {
        completedTasks ++;
      }
    }
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .updateData({
          'completedTasks': completedTasks,
          'totalTasks': totalTasks,
        });
  }

  // update task name
  void updateTaskName(String name, String taskId, String date) {
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

  // add task
  Future<String> addTask(TaskItem task, String date) async {
    String userId = user.uid;
    String taskId;
    if (task.id != null) {
      taskId = task.id;
      await db
          .collection('users')
          .document(userId)
          .collection('tasks')
          .document(date)
          .collection('tasks')
          .document(task.id)
          .setData({
        'name': task.name,
        'order': task.order,
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
        'completed': task.completed,
        'paused': task.paused,
      }).then((doc) {
        DocumentReference dateDoc = db
          .collection('users')
          .document(user.uid)
          .collection('tasks')
          .document(date);
        dateDoc.setData({
          'secondsFocused': FieldValue.increment(
              task.secondsFocused == null ? 0 : task.secondsFocused),
          'secondsDistracted': FieldValue.increment(
              task.secondsDistracted == null ? 0 : task.secondsDistracted),
          'numDistracted': FieldValue.increment(
              task.numDistracted == null ? 0 : task.numDistracted),
          'numPaused':
              FieldValue.increment(task.numPaused == null ? 0 : task.numPaused),
          'completedTasks': FieldValue.increment(0),
          'totalTasks': FieldValue.increment(1),
        }, merge: true);
      });
    } else {
      await db
          .collection('users')
          .document(userId)
          .collection('tasks')
          .document(date)
          .collection('tasks')
          .add({
        'name': task.name,
        'order': task.order,
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
        'completed': task.completed,
        'paused': task.paused,
      }).then((doc) {
        taskId = doc.documentID;
        DocumentReference dateDoc = db
          .collection('users')
          .document(user.uid)
          .collection('tasks')
          .document(date);
        dateDoc.setData({
          'secondsFocused': FieldValue.increment(
              task.secondsFocused == null ? 0 : task.secondsFocused),
          'secondsDistracted': FieldValue.increment(
              task.secondsDistracted == null ? 0 : task.secondsDistracted),
          'numDistracted': FieldValue.increment(
              task.numDistracted == null ? 0 : task.numDistracted),
          'numPaused':
              FieldValue.increment(task.numPaused == null ? 0 : task.numPaused),
          'completedTasks': FieldValue.increment(0),
          'totalTasks': FieldValue.increment(1),
        }, merge: true);
      });
    }
    return taskId;
  }

  // delete task
  void deleteTask(TaskItem task, String date) {
    String userId = user.uid;
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .document(task.id)
        .delete();
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('tasks')
        .document(date);
    dateDoc.updateData({
      'secondsFocused': FieldValue.increment(
          task.secondsFocused == null ? 0 : -task.secondsFocused),
      'secondsDistracted': FieldValue.increment(
          task.secondsDistracted == null ? 0 : -task.secondsDistracted),
      'numDistracted': FieldValue.increment(
          task.numDistracted == null ? 0 : -task.numDistracted),
      'numPaused':
          FieldValue.increment(task.numPaused == null ? 0 : -task.numPaused),
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
      });
    });
  }
}