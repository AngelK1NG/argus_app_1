import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/components/task.dart';

class DatabaseProvider {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<UncompletedTasks> streamUncompleted(UserStatus user) {
    if (user == null || !user.signedIn) {
      return Stream<UncompletedTasks>.value(UncompletedTasks(null));
    } else {
      return _db
          .collection('users')
          .doc(user.uid)
          .collection('uncompleted')
          .orderBy('date')
          .orderBy('index')
          .snapshots()
          .map(
            (list) => UncompletedTasks(
              list.docs.map((doc) => Task.fromFirestore(doc, false)).toList(),
            ),
          );
    }
  }

  Stream<CompletedTasks> streamCompleted(UserStatus user) {
    if (user == null || !user.signedIn) {
      return Stream<CompletedTasks>.value(CompletedTasks(null));
    } else {
      return _db
          .collection('users')
          .doc(user.uid)
          .collection('completed')
          .orderBy('date', descending: true)
          .orderBy('index', descending: true)
          .limit(5)
          .snapshots()
          .map(
            (list) => CompletedTasks(
              list.docs.map((doc) => Task.fromFirestore(doc, true)).toList(),
            ),
          );
    }
  }

  void createUserDocument(User user) async {
    DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      _db.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
      });
    }
  }
}

class UncompletedTasks {
  final List tasks;
  UncompletedTasks(this.tasks);
}

class CompletedTasks {
  final List tasks;
  CompletedTasks(this.tasks);
}
