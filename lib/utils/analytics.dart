import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:Focal/components/task.dart';

class AnalyticsProvider {
  FirebaseAnalytics _analytics = FirebaseAnalytics();

  //focus
  void logStartTask(Task task, DateTime time) {
    _analytics.logEvent(
      name: 'start_task',
      parameters: <String, dynamic>{},
    );
  }

  void logResumeTask(Task task, DateTime time) {
    _analytics.logEvent(
      name: 'resume_task',
      parameters: <String, dynamic>{},
    );
  }

  void logCompleteTask(Task task, DateTime time) {
    _analytics.logEvent(
      name: 'complete_task',
      parameters: <String, dynamic>{},
    );
  }

  void logPauseTask(Task task, DateTime time) {
    _analytics.logEvent(
      name: 'save_task',
      parameters: <String, dynamic>{},
    );
  }

  //tasks
  void logAddTask(Task task, DateTime time) {
    _analytics.logEvent(
      name: 'add_task',
      parameters: <String, dynamic>{},
    );
  }

  void logDeferTask(Task task, DateTime time) {
    _analytics.logEvent(
      name: 'defer_task',
      parameters: <String, dynamic>{},
    );
  }

  void logDeleteTask(Task task, DateTime time) {
    _analytics.logEvent(
      name: 'delete_task',
      parameters: <String, dynamic>{},
    );
  }

  //auth
  void logGoogleSignIn() {
    _analytics.logEvent(
      name: 'sign_in_google',
    );
  }

  void logAppleSignIn() {
    _analytics.logEvent(
      name: 'sign_in_apple',
    );
  }

  void logSignOut() {
    _analytics.logEvent(
      name: 'sign_out',
    );
  }
}
