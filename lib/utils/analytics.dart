import 'package:Focal/constants.dart';
import 'package:Focal/components/task_item.dart';

class AnalyticsProvider {
  void logAddTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'add_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString() + time.minute.toString(),
      },
    );
  }

  void logStartTask(TaskItem task, DateTime time) {
    analytics.logEvent(
      name: 'start_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString() + ':' + time.minute.toString(),
      },
    );
  }

  void logPauseTask(TaskItem task, DateTime time, String duration) {
    analytics.logEvent(
      name: 'pause_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString() + ':' + time.minute.toString(),
        'duration': duration,
      },
    );
  }

  void logCompleteTask(TaskItem task, DateTime time, String duration) {
    analytics.logEvent(
      name: 'complete_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString() + ':' + time.minute.toString(),
        'duration': duration,
      },
    );
  }

  void logSaveTask(TaskItem task, DateTime time, String duration) {
    analytics.logEvent(
      name: 'abandon_task',
      parameters: <String, dynamic>{
        'name': task.name,
        'time': time.hour.toString() + ':' + time.minute.toString(),
        'duration': duration,
      },
    );
  }
}
