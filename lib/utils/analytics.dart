import 'package:Focal/constants.dart';
import 'package:Focal/components/task.dart';

class AnalyticsProvider {
  //focus
  void logStartTask(Task task, DateTime time) {
    analytics.logEvent(
      name: 'start_task',
      parameters: <String, dynamic>{},
    );
  }

  void logResumeTask(Task task, DateTime time) {
    analytics.logEvent(
      name: 'resume_task',
      parameters: <String, dynamic>{},
    );
  }

  void logCompleteTask(Task task, DateTime time) {
    analytics.logEvent(
      name: 'complete_task',
      parameters: <String, dynamic>{},
    );
  }

  void logPauseTask(Task task, DateTime time) {
    analytics.logEvent(
      name: 'save_task',
      parameters: <String, dynamic>{},
    );
  }

  //tasks
  void logAddTask(Task task, DateTime time) {
    analytics.logEvent(
      name: 'add_task',
      parameters: <String, dynamic>{},
    );
  }

  void logDeferTask(Task task, DateTime time) {
    analytics.logEvent(
      name: 'defer_task',
      parameters: <String, dynamic>{},
    );
  }

  void logDeleteTask(Task task, DateTime time) {
    analytics.logEvent(
      name: 'delete_task',
      parameters: <String, dynamic>{},
    );
  }

  //auth
  void logGoogleSignIn() {
    analytics.logEvent(
      name: 'sign_in_google',
    );
  }

  void logAppleSignIn() {
    analytics.logEvent(
      name: 'sign_in_apple',
    );
  }

  void logSignOut() {
    analytics.logEvent(
      name: 'sign_out',
    );
  }
}
