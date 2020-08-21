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

  // update task name
  void updateTaskName(String name, String date, String taskId) {
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
        'order': tasks.indexOf(task) + 1,
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'secondsPaused': task.secondsPaused,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
        'completed': task.completed,
        'saved': task.saved,
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

  // delete task
  void deleteTask(String date, String taskId) {
    String userId = user.uid;
    DocumentReference taskDocumentReference = db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .document(taskId);
    taskDocumentReference.delete();
  }
}