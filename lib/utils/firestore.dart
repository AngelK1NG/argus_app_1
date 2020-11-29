import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Focal/constants.dart';
import 'package:Focal/components/task_item.dart';
import 'package:Focal/utils/date.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreProvider {
  FirebaseUser user;

  FirestoreProvider(this.user);

  // check if user document exists in firestore
  Future<bool> userDocumentExists() async {
    bool docExists = false;
    DocumentSnapshot doc =
        await db.collection('users').document(user.uid).get();
    if (!doc.exists) {
      docExists = false;
    } else {
      docExists = true;
    }
    return docExists;
  }

  // create user document in firestore when new user logs in
  void createUserDocument() async {
    DocumentSnapshot doc =
        await db.collection('users').document(user.uid).get();
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
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('newUser', true);
      });
    }
  }

  // add default tasks for new user
  Future<void> addDefaultTasks() async {
    List taskNames = [
      'Tap to edit this task ✏️',
      'Hold and drag to reorder 🔃',
      'Swipe right to defer this task 📅',
      'Swipe left to delete this task 🗑️',
      'Swipe and tap on the date to schedule tasks',
      'Tap the + button to add another task',
    ];
    await db
        .collection('users')
        .document(user.uid)
        .collection('dates')
        .document(getDateString(DateTime.now()))
        .setData({
      'completedTasks': 0,
      'startedTasks': 0,
      'totalTasks': taskNames.length,
      'secondsFocused': 0,
      'secondsDistracted': 0,
      'numDistracted': 0,
      'numPaused': 0,
      'volts': [],
    });
    for (var i = 0; i < taskNames.length; i++) {
      await addTask(
        TaskItem(
          name: taskNames[i],
          completed: false,
          paused: false,
          order: i + 1,
          date: getDateString(DateTime.now()),
          secondsFocused: 0,
          secondsDistracted: 0,
          numPaused: 0,
          numDistracted: 0,
          voltsIncrement: 0,
        ),
        getDateString(DateTime.now()),
      );
    }
  }

  // update tasks
  void updateTasks(List<TaskItem> tasks, String date) {
    String userId = user.uid;
    int totalTasks = 0;
    int completedTasks = 0;
    int startedTasks = 0;
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
        'completed': task.completed,
        'paused': task.paused,
        'order': tasks.indexOf(task) + 1,
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
        'voltsIncrement': task.voltsIncrement,
      });
      totalTasks++;
      if (task.completed) {
        completedTasks++;
        startedTasks++;
      } else if (task.paused) {
        startedTasks++;
      }
    }
    db
        .collection('users')
        .document(userId)
        .collection('dates')
        .document(date)
        .updateData({
      'completedTasks': completedTasks,
      'startedTasks': startedTasks,
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
        'startedTasks': 0,
        'totalTasks': 0,
        'volts': [],
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
        'completed': task.completed,
        'paused': task.paused,
        'order': task.order,
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
        'voltsIncrement': task.voltsIncrement,
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
        'completed': task.completed,
        'paused': task.paused,
        'order': task.order,
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
        'voltsIncrement': task.voltsIncrement,
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
