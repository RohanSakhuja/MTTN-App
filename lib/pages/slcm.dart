import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flare_flutter/flare_actor.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'CachedImages.dart';
import 'package:flutter_parallax/flutter_parallax.dart';

class Attendance {
  final String attended;
  final String missed;
  final String name;
  final String percentage;
  final String total;

  Attendance(
      {this.attended, this.missed, this.name, this.percentage, this.total});
}

class SLCM extends StatefulWidget {
  @override
  createState() => new SLCMState();
}

DatabaseReference databaseReference = new FirebaseDatabase().reference();

class SLCMState extends State<SLCM> with AutomaticKeepAliveClientMixin {
  Color secColor = new Color.fromRGBO(234, 116, 76, 1.0);
  Color primColor = Color.fromRGBO(190, 232, 223, 0.75);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
  }

  TextEditingController controllerReg = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();

  String regNo;
  String password;
  bool obsecureText = true;
  bool isVerifying = false;
  bool loggedIn = false;
  var attendance;

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<http.Response> _getResponse(String reg, String pass) async {
    try {
      final String _slcmApi = 'https://slcm.herokuapp.com/attendance';
      var match = {'username': reg, 'password': pass};
      setState(() {
        isVerifying = true;
      });
      final response = await http.post(
        _slcmApi,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(match),
      );
      return response;
    } on SocketException catch (e) {
      if (e.osError.errorCode == 111) {
        _showDialog("Server Down",
            "It seems SLCM is down, please try again in some time.");
        return null; // if connection refused
      }
      _showDialog("No Internet",
          "Please check your internet connection and try again!");
      setState(() {
        isVerifying = false;
      });
      return null;
    }
  }

  void _checkCredentials(String reg, String pass) {
    _getResponse(reg, pass).then((response) {
      if (response != null && response.statusCode == 200) {
        var res = json.decode(response.body);
        print(res['login']);
        if (res['login'] == 'successful') {
          setState(() {
            isVerifying = false;
            loggedIn = true;
            attendance = res;
          });
        } else if (res['login'] == 'unsuccessful') {
          _showDialog("Invalid Credentials",
              "Please enter a valid registration number and/or password.");
          controllerReg.clear();
          controllerPass.clear();
          setState(() {
            isVerifying = false;
          });
        }
      } else {
        setState(() {
          isVerifying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return loggedIn ? attendancePage(height, width) : loginPage(height, width);
  }

  final FocusNode _regFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget loginPage(height, width) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      body: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            child: FlareActor(
              "assets/earthlogin.flr",
              alignment: Alignment.center,
              fit: BoxFit.cover,
              animation: "Preview2",
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(2.0, height * 0.33, 2.0, 0.0),
            height: height * 0.66,
            width: width * 0.9,
            child: ListView(
              children: <Widget>[
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  //  color: Colors.white,
                  child: Container(
                    height: height * 0.185,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        SizedBox(
                          height: height * 0.08,
                          width: width * 0.9,
                          child: TextFormField(
                            controller: controllerReg,
                            focusNode: _regFocus,
                            keyboardType: TextInputType.numberWithOptions(),
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (term) {
                              _fieldFocusChange(context, _regFocus, _passFocus);
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Registraion Number',
                                prefixIcon: Icon(Icons.person)),
                          ),
                        ),
                        // Padding(padding: EdgeInsets.all(2.0),),
                        SizedBox(
                          height: height * 0.07,
                          width: width * 0.9,
                          child: Container(
                            child: SizedBox.fromSize(
                              size: Size.fromHeight(height * 0.08),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    height: height * 0.08,
                                    width: width * 0.75,
                                    child: TextFormField(
                                      obscureText: obsecureText,
                                      controller: controllerPass,
                                      focusNode: _passFocus,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (value) {
                                        _passFocus.unfocus();
                                      },
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'Password',
                                          prefixIcon: Icon(obsecureText
                                              ? Icons.lock
                                              : Icons.lock_open)),
                                    ),
                                  ),
                                  Container(
                                    height: height * 0.08,
                                    child: IconButton(
                                      icon: obsecureText
                                          ? Icon(
                                              Icons.visibility_off,
                                              // color: Colors.black
                                              //     .withOpacity(0.5),
                                            )
                                          : Icon(
                                              Icons.visibility,
                                              // color: Colors.black
                                              //     .withOpacity(0.5),
                                            ),
                                      onPressed: () => setState(() {
                                            obsecureText = !obsecureText;
                                          }),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: height * 0.06,
            margin: EdgeInsets.only(top: height * 0.5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              width: width * 0.6,
              height: height * 0.055,
              child: Material(
                color: Color.fromRGBO(64, 224, 208, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                child: InkWell(
                  splashColor: Colors.white,
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                          fontSize: 18.0),
                    ),
                  ),
                  onTap: () {
                    // controllerPass.
                    isVerifying = true;
                    regNo = controllerReg.text;
                    password = controllerPass.text;
                    // print(controllerReg.text + controllerPass.text);
                    _checkCredentials(regNo, password);
                  },
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: height * 0.7),
            child: isVerifying
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  )
                : null,
          )
        ],
      ),
    );
  }

  Widget attendancePage(var height, var width) {
    List<Attendance> att = _parseAttendace();
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          "SLCM ",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            iconSize: 80.0,
            icon: Text('Logout', style: TextStyle(fontSize: 18.0),),
            onPressed: () {
              setState(() {
                loggedIn = false;
              });
            },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(color: Colors.black),
        padding: EdgeInsets.symmetric(
            horizontal: width * .03, vertical: height * 0.02),
        child: ListView.builder(
          itemCount: att.length,
          itemBuilder: (context, index) {
            return Container(
              height: height * 0.32,
              margin: EdgeInsets.only(bottom: 10.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 3.0,
                child: _buildSubjectCard(
                    att[index].name,
                    att[index].total,
                    att[index].attended,
                    att[index].missed,
                    att[index].percentage,
                    context,
                    index),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Attendance> _parseAttendace() {
    List<Attendance> data = [];
    var temp = attendance['Attendance'];
    for (var key in temp.keys) {
      Attendance att = Attendance(
        name: temp[key]['Name'],
        attended: temp[key]['Attended'],
        missed: temp[key]['Missed'],
        total: temp[key]['Total'],
        percentage: temp[key]['Percentage'],
      );
      data.add(att);
    }
    return data;
  }

  capFirst(str) {
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }

  _buildSubjectCard(subName, subClasses, subPresent, subAbsent, subPercentage,
      context, index) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    CachedImg camm = new CachedImg();

    return GestureDetector(
      onTap: () {
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
              )),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(
                      height * 0.03, height * 0.04, height * 0.02, 0.0),
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
                          top: height * 0.035, bottom: height * 0.01),
                      width: width * 0.4,
                      height: height * 0.12,
                      child: Center(
                          child: CircularPercentIndicator(
                        radius: height * 0.11,
                        animation: true,
                        animationDuration: 400,
                        lineWidth: 7.0,
                        percent: double.parse(subPercentage.substring(
                                0, subPercentage.length - 1)) /
                            100,
                        center: Text(
                            subPercentage.substring(
                                0, subPercentage.length - 3),
                            style: TextStyle(
                                fontSize: height * 0.05,
                                fontWeight: FontWeight.w300,
                                color: Colors.white)),
                        progressColor: Colors.white,
                        circularStrokeCap: CircularStrokeCap.round,
                        backgroundColor: Colors.grey,
                        //animateFromLastPercent: true,
                      )),
                    ),
                    Container(
                      height: height * 0.12,
                      width: width * 0.5,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                top: height * 0.027, left: width * 0.4),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Total",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: width * 0.02)),
                              Text(
                                "Attended",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: width * 0.02)),
                              Text(
                                "Missed",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              )
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: height * 0.015)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                subClasses,
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: width * 0.11)),
                              Text(
                                subPresent,
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(left: width * 0.15)),
                              Text(
                                subAbsent,
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              )
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
}
