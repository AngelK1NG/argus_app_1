class DateProvider {
  DateTime get today {
    return DateTime.parse(dateString(DateTime.now()));
  }

  DateTime get tomorrow {
    return DateTime.parse(dateString(DateTime.now().add(Duration(days: 1))));
  }

  DateTime get nextWeek {
    return DateTime.parse(dateString(
        DateTime.now().add(Duration(days: 8 - DateTime.now().weekday))));
  }

  String dateString(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return year + month + day;
  }

  String dateTimeString(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    String second = date.second.toString().padLeft(2, '0');
    return year + month + day + ' $hour:$minute:$second';
  }

  String weekdayString(DateTime date, bool short) {
    if (date == null) {
      return '';
    } else {
      switch (date.weekday) {
        case 1:
          {
            return short ? 'Mon' : 'Monday';
          }
        case 2:
          {
            return short ? 'Tue' : 'Tuesday';
          }
        case 3:
          {
            return short ? 'Wed' : 'Wednesday';
          }
        case 4:
          {
            return short ? 'Thu' : 'Thursday';
          }
        case 5:
          {
            return short ? 'Fri' : 'Friday';
          }
        case 6:
          {
            return short ? 'Sat' : 'Saturday';
          }
        case 7:
          {
            return short ? 'Sun' : 'Sunday';
          }
        default:
          {
            return '';
          }
      }
    }
  }
}
