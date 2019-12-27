class EuDateTime {
  DateTime dateTime;

  String day;
  String month;
  String year;

  String euDateTime;

  EuDateTime(this.dateTime) {
    day = dateTime.day.toString();
    month = dateTime.month.toString();
    year = dateTime.year.toString();

    if (dateTime.day < 10) day = '0' + day;
    if (dateTime.month < 10) month = '0' + month;
  }

  String getDate() {
    return ('$day/$month/$year');
  }
}
