class Attendance {
  final String attended;
  final String missed;
  final String name;
  final String percentage;
  final String total;

  Attendance({
    this.attended,
    this.missed,
    this.name,
    this.percentage,
    this.total,
  });
}

class SisAttendance {
  final List<Attendance> subs;
  final String subjectName;

  SisAttendance(this.subjectName, this.subs);
}

class Marks {
  final String name;
  final String obtained;
  final String total;

  Marks({this.name, this.obtained, this.total});
}

class SubjectMarks {
  final String name;
  final List<Marks> assignments;
  final List<Marks> sessionals;
  final List<Marks> otherMarks;

  SubjectMarks({this.name, this.assignments, this.sessionals, this.otherMarks});
}
