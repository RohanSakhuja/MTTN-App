import 'package:flutter/material.dart';
import 'package:mttn_app/utils/subjectModals.dart';

class SISSubjectCard extends StatelessWidget {
  final SisAttendance subject;

  SISSubjectCard(this.subject);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
              Color.fromRGBO(15, 15, 15, 1.0),
              Color.fromRGBO(25, 25, 25, 1.0),
              Color.fromRGBO(65, 65, 65, 1.0),
            ])),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              subject.subjectName.toUpperCase(),
              style: TextStyle(
                  fontSize: 27,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
            ),
            ...attendanceBuilder(),
          ],
        ),
      ),
    );
  }

  List<Widget> attendanceBuilder() {
    List<Widget> widgets = new List();
    for (Attendance att in subject.subs) {
      try {
        widgets.add(new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              att.name.toUpperCase() ?? "",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  att.percentage ?? "",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "ATTENDED ${att.attended ?? ""}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "OUT OF ${att.total ?? ""}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          ],
        ));
        if (subject.subs.indexOf(att) != (subject.subs.length - 1)) {
          widgets.add(Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100.0),
            child: Divider(
              thickness: 1.5,
            ),
          ));
        }
      } catch (e) {
        print(e);
      }
    }
    return widgets;
  }
}
