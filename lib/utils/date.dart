String getDateString(DateTime date) {
  String day = date.day.toString();
  String month = date.month.toString();
  String year = date.year.toString();
  if (day.length == 1) {
    day = '0' + day;
  }
  if (month.length == 1) {
    month = '0' + month;
  }
  return year + month + day;
}

DateTime getDateFromString(String date) {
  return DateTime.parse(date);
}
