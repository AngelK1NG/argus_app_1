import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/constants.dart';
import 'package:flutter/cupertino.dart';

class FirestoreProvider {
  // create user document in firestore when signed in with google
  static void createUserDocument(FirebaseUser user) {
    db.collection('users').document(user.uid).setData({
      'name': user.displayName,
      'email': user.email,
    });
  }

  // get the list of tasks in splash screen
  List<Widget> getTask() {}

  // add task to firestore method
  static void addTask() {}

  // update method
  static void updateTask() {}

  // delete task
  static void deleteTask() {}
}
