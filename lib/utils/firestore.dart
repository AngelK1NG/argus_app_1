import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/task_item.dart';
import 'package:Focal/utils/date.dart';

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
          'daysActive': 1,
          'lastActive': getDateString(DateTime.now()),
          'secondsFocused': 0,
          'completedTasks': 0,
          'volts': {
            'dateTime': getDateTimeString(DateTime.now()),
            'val': 1000,
          }
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
          .collection('dates')
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
      totalTasks++;
      if (task.completed) {
        completedTasks++;
      }
    }
    db
        .collection('users')
        .document(userId)
        .collection('dates')
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
        .collection('dates')
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
    DocumentReference dateDoc = db
        .collection('users')
        .document(user.uid)
        .collection('dates')
        .document(date);
    DocumentSnapshot snapshot = await dateDoc.get();
    if (snapshot.data == null) {
      await dateDoc.setData({
        'secondsFocused': 0,
        'secondsDistracted': 0,
        'numDistracted': 0,
        'numPaused': 0,
        'completedTasks': 0,
        'totalTasks': 0,
      });
    }
    if (task.id != null) {
      taskId = task.id;
      await db
          .collection('users')
          .document(userId)
          .collection('dates')
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
      });
    } else {
      await db
          .collection('users')
          .document(userId)
          .collection('dates')
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
        .collection('dates')
        .document(date)
        .collection('tasks')
        .document(task.id)
        .delete();
  }
}
