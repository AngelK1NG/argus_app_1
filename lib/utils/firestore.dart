import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/constants.dart';

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

  // get the list of tasks in splash screen
  List<Map> getTasks() {
    return [];
  }

  // add task to firestore method
  static void addTask(String date, String name, int order) async {
    FirebaseUser user = await auth.currentUser();
    String userId = user.uid;
    db
        .collection('users')
        .document(userId)
        .collection('tasks')
        .document(date)
        .collection('tasks')
        .add({
      'date': Timestamp.now(),
      'name': name,
      'order': order,
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
