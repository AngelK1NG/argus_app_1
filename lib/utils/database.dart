import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vivi/utils/auth.dart';
import 'package:vivi/components/alarm.dart';

class DatabaseProvider {
  FirebaseFirestore _db = FirebaseFirestore.instance;

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
              list.docs.map((doc) => Alarm.fromFirestore(doc, true)).toList(),
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

class CompletedTasks {
  final List tasks;
  CompletedTasks(this.tasks);
}
