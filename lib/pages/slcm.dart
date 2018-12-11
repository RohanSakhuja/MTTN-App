import 'package:flutter/material.dart';

class Attendance {
  final String attended;
  final String missed;
  final String name;
  final String percentage;
  final String total;

  Attendance({this.attended, this.missed, this.name, this.percentage, this.total});
}

class StudentInfo extends StatefulWidget{
  final json;
  StudentInfo({this.json});
  StudentInfoState createState() => StudentInfoState();
}

class StudentInfoState extends State<StudentInfo>{
  Color secCol = new Color.fromRGBO(234, 116, 76, 1.0);

  @override
  Widget build(BuildContext context) {
    List<Attendance> att = _parseAttendace();
    print(att.length);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.black,), onPressed: (){Navigator.pop(context);}),
        title: Text("SLCM ",style: TextStyle(color: Colors.black),),
        backgroundColor: secCol,
        actions: <Widget>[
          Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),)
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("astro.png"),
          fit: BoxFit.cover,)
        ),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * .03),
        child: ListView.builder(
                  itemCount: att.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 30.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      height: MediaQuery.of(context).size.height * 0.33,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Column(
                        children: <Widget>[
                          _buildSubjectCard(att[index].name, att[index].total, att[index].attended, att[index].missed, att[index].percentage),
                        ],
                      ),
                    );
                  },
                ),
        // child: ListView(
        //   primary: false,
        //   padding: EdgeInsets.only(
        //     top: MediaQuery.of(context).size.width * .05,
        //     left: MediaQuery.of(context).size.width * .03,
        //     right: MediaQuery.of(context).size.width * .03,
        //     bottom: MediaQuery.of(context).size.width * .03
        //   ),
        //   children: <Widget>[
        //     Column(
        //       children: <Widget>[
                
        //       ],
        //     )
        //   ],
        // ),
      ),
    );
  }

  List<Attendance> _parseAttendace(){
    List<Attendance> data = [];
    var temp = widget.json['Attendance'];
    for (var key in temp.keys) {
      Attendance att = Attendance(
        name: temp[key]['Name'],
        attended: temp[key]['Attended'],
        missed: temp[key]['Missed'],
        total: temp[key]['Total'],
        percentage: temp[key]['Percentage'],);
        data.add(att);
    }
    return data;
  }
  
  _buildSubjectCard(subName, subClasses, subPresent, subAbsent, subPercentage) {
      return GestureDetector(
        onTap: (){
          //SubjectMarks(); // functionality for marks
          },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.03,
                  left: MediaQuery.of(context).size.width * 0.05,
                  right: 20.0
              ),
              height: 75.0,
              width: MediaQuery.of(context).size.width * 0.90,
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
              child: Text(
                subName, style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.w300,
              ),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.width * 0.01
                  ),
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.height * 0.12,
                  //color: Colors.red,
                  child: Center(
                    child: Text(
                      subPercentage + "%",
                      style: TextStyle(
                          fontSize: 50.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.12,
                  width: MediaQuery.of(context).size.width * 0.5,
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.07,
                  ),
                  //color: Colors.blueGrey,
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.027,
                          left: MediaQuery.of(context).size.width * 0.4
                      ),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Total", style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w700),),
                          Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02)),
                          Text("Attended", style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w700),),
                          Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size
                              .width * 0.02)),
                          Text("Missed", style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.w700),)
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 15.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(subClasses, style: TextStyle(fontSize: 15.0,),),
                          Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.11)),
                          Text(subPresent, style: TextStyle(fontSize: 15.0,),),
                          Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15)),
                          Text(subAbsent, style: TextStyle(fontSize: 15.0,),)
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
}

