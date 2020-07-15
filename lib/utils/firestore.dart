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
      }
    });
  }

  // get the list of tasks in splash screen
  List<Map> getTasks() {
    return [];
  }

  // add task to firestore method
  static void addTask() {}

  // update method
  static void updateTask() {}

  // delete task
  static void deleteTask() {}
}
