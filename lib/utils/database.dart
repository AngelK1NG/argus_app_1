import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Focal/utils/auth.dart';
import 'package:Focal/components/task.dart';

class DatabaseProvider {
  Firestore _db = Firestore.instance;

  Stream<UncompletedTasks> streamUncompleted(User user) {
    if (user == null || !user.signedIn) {
      return Stream<UncompletedTasks>.value(UncompletedTasks([]));
    } else {
      return _db
          .collection('users')
          .document(user.uid)
          .collection('uncompleted')
          .orderBy('date')
          .orderBy('index')
          .snapshots()
          .map(
            (list) => UncompletedTasks(
              list.documents
                  .map((doc) => Task.fromFirestore(doc, false))
                  .toList(),
            ),
          );
    }
  }

  Stream<CompletedTasks> streamCompleted(User user) {
    if (user == null || !user.signedIn) {
      return Stream<CompletedTasks>.value(CompletedTasks([]));
    } else {
      return _db
          .collection('users')
          .document(user.uid)
          .collection('completed')
          .orderBy('date', descending: true)
          .orderBy('index', descending: true)
          .limit(5)
          .snapshots()
          .map(
            (list) => CompletedTasks(
              list.documents
                  .map((doc) => Task.fromFirestore(doc, true))
                  .toList(),
            ),
          );
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
