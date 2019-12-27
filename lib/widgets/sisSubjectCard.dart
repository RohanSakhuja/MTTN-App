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
              subject.subjectName,
              style: TextStyle(fontSize: 24, color: Colors.white),
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
              att.name ?? "",
              style: TextStyle(fontSize: 23, color: Colors.white),
            ),
            Column(
              children: <Widget>[
                Text(
                  "${att.percentage ?? ""}%",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                Text(
                  "ATTENDED ${att.attended ?? ""}",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "OUT OF ${att.total ?? ""}",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "MISSED ${att.missed ?? ""}",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            )
          ],
        ));
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: Divider(
            thickness: 1.5,
          ),
        ));
      } catch (e) {
        print(e);
      }
    }
    return widgets;
  }
}
