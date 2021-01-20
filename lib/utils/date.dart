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
    if (date == null) {
      return '';
    } else {
      String day = date.day.toString().padLeft(2, '0');
      String month = date.month.toString().padLeft(2, '0');
      String year = date.year.toString();
      return year + month + day;
    }
  }

  String weekdayString(DateTime date, bool full) {
    if (date == null) {
      return '';
    } else {
      switch (date.weekday) {
        case 1:
          {
            return full ? 'Monday' : 'Mon';
          }
        case 2:
          {
            return full ? 'Tuesday' : 'Tue';
          }
        case 3:
          {
            return full ? 'Wednesday' : 'Wed';
          }
        case 4:
          {
            return full ? 'Thursday' : 'Thu';
          }
        case 5:
          {
            return full ? 'Friday' : 'Fri';
          }
        case 6:
          {
            return full ? 'Saturday' : 'Sat';
          }
        case 7:
          {
            return full ? 'Sunday' : 'Sun';
          }
        default:
          {
            return '';
          }
      }
    }
  }

  String monthString(DateTime date, bool full) {
    if (date == null) {
      return '';
    } else {
      switch (date.month) {
        case 1:
          {
            return full ? 'January' : 'Jan';
          }
        case 2:
          {
            return full ? 'Februray' : 'Feb';
          }
        case 3:
          {
            return full ? 'March' : 'Mar';
          }
        case 4:
          {
            return full ? 'April' : 'Apr';
          }
        case 5:
          {
            return full ? 'May' : 'May';
          }
        case 6:
          {
            return full ? 'June' : 'Jun';
          }
        case 7:
          {
            return full ? 'July' : 'Jul';
          }
        case 8:
          {
            return full ? 'August' : 'Aug';
          }
        case 9:
          {
            return full ? 'September' : 'Sep';
          }
        case 10:
          {
            return full ? 'October' : 'Oct';
          }
        case 11:
          {
            return full ? 'November' : 'Nov';
          }
        case 12:
          {
            return full ? 'December' : 'Dec';
          }
        default:
          {
            return '';
          }
      }
    }
  }
}
