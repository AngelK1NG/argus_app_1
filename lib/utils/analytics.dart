import 'package:Focal/constants.dart';
import 'package:Focal/components/task_item.dart';

class AnalyticsProvider {
  //home
  void logStartTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'start_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString().padLeft(2, '0') + ':' + time.minute.toString().padLeft(2, '0'),
      },
    );
  }

  void logPauseTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'pause_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString().padLeft(2, '0') + ':' + time.minute.toString().padLeft(2, '0'),
      },
    );
  }

  void logResumeTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'resume_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString().padLeft(2, '0') + ':' + time.minute.toString().padLeft(2, '0'),
      },
    );
  }

  void logCompleteTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'complete_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString().padLeft(2, '0') + ':' + time.minute.toString().padLeft(2, '0'),
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'secondsPaused': task.secondsPaused,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
      },
    );
  }

  void logSaveTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'save_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString().padLeft(2, '0') + ':' + time.minute.toString().padLeft(2, '0'),
        'secondsFocused': task.secondsFocused,
        'secondsDistracted': task.secondsDistracted,
        'secondsPaused': task.secondsPaused,
        'numDistracted': task.numDistracted,
        'numPaused': task.numPaused,
      },
    );
  }

  //tasks
  void logAddTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'add_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString().padLeft(2, '0') + ':' + time.minute.toString().padLeft(2, '0'),
      },
    );
  }

  void logDeleteTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'delete_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString().padLeft(2, '0') + ':' + time.minute.toString().padLeft(2, '0'),
      },
    );
  }

  //settings
  void logSignOut() {
    analytics.logEvent(
      name: 'sign_out',
    );
  }

  //login
  void logGoogleSignIn() {
    analytics.logEvent(
      name:'sign_in_google',
    );
  }

  void logAppleSignIn() {
    analytics.logEvent(
      name:'sign_in_apple',
    );
  }
}
