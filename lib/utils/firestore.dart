import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/task_item.dart';

class FirestoreProvider {
  FirebaseUser user;

  FirestoreProvider(this.user);

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

  // add task to firestore method
  void addTask(TaskItem task, String date) {
    String userId = user.uid;
    CollectionReference completedTasks = db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('completed_tasks');
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .document(task.id)
        .setData({
      'name': task.name,
      'order': task.order,
      'completed': task.completed,
    });

    completedTasks.getDocuments().then((snapshots) {
      if (snapshots.documents.length == 0) {
        print('collection does not exist');
        completedTasks.document('completed').setData({
          'number': 0,
        });
      }
    });
  }

  // update method
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

  void updateTaskOrder(List<TaskItem> tasks, String date) {
    String userId = user.uid;
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
      });
    }
  }

  // delete task
  void deleteTask(String date, String taskId, bool isCompleted) {
    String userId = user.uid;
    DocumentReference taskDocumentReference = db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .document(taskId);

    taskDocumentReference.delete();
    if (isCompleted) {
      db
          .collection('users')
          .document(userId)
          .collection('tasks')
          .document(date)
          .collection('completed_tasks')
          .document('completed')
          .updateData({
        'number': FieldValue.increment(-1),
      });
    }
  }

  // add to completed number of tasks
  void addCompletedTaskNumber(String date) {
    String userId = user.uid;
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('completed_tasks')
        .document('completed')
        .updateData({
      'number': FieldValue.increment(1),
    });
  }
}
