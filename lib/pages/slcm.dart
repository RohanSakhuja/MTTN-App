import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'CachedImages.dart';
import 'package:flutter_parallax/flutter_parallax.dart';

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
  Color secColor = new Color.fromRGBO(234, 116, 76, 1.0);
  Color primColor = Color.fromRGBO(190, 232, 223, 0.75);

  @override
  Widget build(BuildContext context) {

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    List<Attendance> att = _parseAttendace();
    print(att.length);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: (){Navigator.pop(context);}),
        title: Text("SLCM ",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.black,
        actions: <Widget>[
          Padding(padding: EdgeInsets.only(left: width * 0.02),)
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black
        ),
        padding: EdgeInsets.symmetric(horizontal: width * .03,vertical: height * 0.02),
        child: ListView.builder(
          itemCount: att.length,
          itemBuilder: (context, index){
            return Container(
              height: height * 0.32,
              margin: EdgeInsets.only(bottom: 10.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 3.0,
                child: _buildSubjectCard(att[index].name, att[index].total, att[index].attended, att[index].missed, att[index].percentage, context, index),
              ),
            );
          },
        ),
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

  capFirst(str) {
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }

  _buildSubjectCard(subName, subClasses, subPresent, subAbsent, subPercentage, context, index){
    
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    CachedImg camm = new CachedImg();
 
    return GestureDetector(
      onTap: (){
        // showSubjectMarks(); // functionality for marks
      },
      child: Stack(
        children: <Widget>[
          Container(
            height: height * 0.31,
            width: width * 0.95,
            child: Parallax.inside(
              mainAxisExtent: 200.0,
              child: camm.images[index],
            )
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(height * 0.03, height * 0.04, height * 0.02, 0.0),
                  height: height * 0.1,
                  width: width * 0.8,
                  child: Text(
                      capFirst(subName.toLowerCase()),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                        fontWeight: FontWeight.w300,
                      ),
                      overflow: TextOverflow.clip,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: height * 0.035,
                          bottom: height * 0.01
                        ),
                        width: width * 0.4,
                        height: height * 0.12,
                        child: Center(
                          child: CircularPercentIndicator(
                            radius: height * 0.11,
                            animation: true,
                            animationDuration: 400,
                            lineWidth: 7.0,
                            percent: double.parse(subPercentage.substring(0,subPercentage.length - 1))/100,
                            center: Text(subPercentage.substring(0,subPercentage.length - 3),style: TextStyle(fontSize: height * 0.05,fontWeight: FontWeight.w300, color: Colors.white)),
                            progressColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.round,
                            backgroundColor: Colors.grey,
                            //animateFromLastPercent: true,
                          )
                        ),
                      ),
                      Container(
                        height: height * 0.12,
                        width: width * 0.5,
                        child: Column(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(
                                top: height * 0.027,
                                left: width * 0.4
                              ),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Total", style: TextStyle(
                                    fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white),),
                                Padding(padding: EdgeInsets.only(left: width * 0.02)),
                                Text("Attended", style: TextStyle(
                                    fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white),),
                                Padding(padding: EdgeInsets.only(left: width * 0.02)),
                                Text("Missed", style: TextStyle(
                                    fontSize: 15.0, fontWeight: FontWeight.w500, color: Colors.white),)
                              ],
                            ),
                            Padding(padding: EdgeInsets.only(top: height * 0.015)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(subClasses, style: TextStyle(fontSize: 15.0, color: Colors.white),),
                                Padding(padding: EdgeInsets.only(left: width * 0.11)),
                                Text(subPresent, style: TextStyle(fontSize: 15.0, color: Colors.white),),
                                Padding(padding: EdgeInsets.only(left: width * 0.15)),
                                Text(subAbsent, style: TextStyle(fontSize: 15.0, color: Colors.white),)
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),  
              ],
            ),
          ),
        ],
      ),
    );
  }


  
  // _buildSubjectCard(subName, subClasses, subPresent, subAbsent, subPercentage, context) {
  //     return GestureDetector(
  //       onTap: (){
  //         //SubjectMarks(); // functionality for marks
  //         },
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: <Widget>[
  //           Container(
  //             margin: EdgeInsets.only(
  //                 top: MediaQuery.of(context).size.height * 0.03,
  //                 left: MediaQuery.of(context).size.width * 0.05,
  //                 right: 20.0
  //             ),
  //             height: 75.0,
  //             width: MediaQuery.of(context).size.width * 0.90,
  //             padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.01),
  //             child: Text(
  //               subName, style: TextStyle(
  //               color: Colors.black,
  //               fontSize: 30.0,
  //               fontWeight: FontWeight.w300,
  //             ),
  //             ),
  //           ),
  //           Row(
  //             children: <Widget>[
  //               Container(
  //                 margin: EdgeInsets.only(
  //                     top: MediaQuery.of(context).size.height * 0.01,
  //                     left: MediaQuery.of(context).size.width * 0.01
  //                 ),
  //                 width: MediaQuery.of(context).size.width * 0.4,
  //                 height: MediaQuery.of(context).size.height * 0.12,
  //                 //color: Colors.red,
  //                 child: Center(
  //                   child: Text(
  //                     subPercentage + "%",
  //                     style: TextStyle(
  //                         fontSize: 35.0,
  //                         fontWeight: FontWeight.w300
  //                     ),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               ),
  //               Container(
  //                 height: MediaQuery.of(context).size.height * 0.12,
  //                 width: MediaQuery.of(context).size.width * 0.5,
  //                 margin: EdgeInsets.only(
  //                   left: MediaQuery.of(context).size.width * 0,
  //                 ),
  //                 //color: Colors.blueGrey,
  //                 child: Column(
  //                   children: <Widget>[
  //                     Padding(padding: EdgeInsets.only(
  //                         top: MediaQuery.of(context).size.height * 0.027,
  //                         left: MediaQuery.of(context).size.width * 0.4
  //                     ),),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: <Widget>[
  //                         Text("Total", style: TextStyle(
  //                             fontSize: 15.0, fontWeight: FontWeight.w700),),
  //                         Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02)),
  //                         Text("Attended", style: TextStyle(
  //                             fontSize: 15.0, fontWeight: FontWeight.w700),),
  //                         Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size
  //                             .width * 0.02)),
  //                         Text("Missed", style: TextStyle(
  //                             fontSize: 15.0, fontWeight: FontWeight.w700),)
  //                       ],
  //                     ),
  //                     Padding(padding: EdgeInsets.only(top: 15.0)),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: <Widget>[
  //                         Text(subClasses, style: TextStyle(fontSize: 15.0,),),
  //                         Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.11)),
  //                         Text(subPresent, style: TextStyle(fontSize: 15.0,),),
  //                         Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.15)),
  //                         Text(subAbsent, style: TextStyle(fontSize: 15.0,),)
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ],
  //       ),
  //     );
  //   }
}