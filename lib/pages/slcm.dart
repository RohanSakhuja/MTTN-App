import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flare_flutter/flare_actor.dart';
import 'package:mttn_app/main.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  SharedPreferences _preferences;
  String _slcmApi;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getUrl();
    _cachedLogin();
    super.initState();
  }

  getUrl() async {
    var urls;
    try {
      _preferences = await SharedPreferences.getInstance();
      urls = jsonDecode(_preferences.getString('url'));
      setState(() {
        _slcmApi = urls['SLCM Data'];
      });
    } catch (e) {
      var snapshot = await databaseReference.child('URL').once();
      urls = snapshot.value;
      setState(() {
        _slcmApi = urls['SLCM Data'];
      });
    }
  }

  void _cachedLogin() async {
    _preferences = await SharedPreferences.getInstance();
    List<String> cred = _preferences.getStringList('credentials') ?? [];
    if (cred.length != 0) {
      _checkCredentials(cred[0], cred[1]);
    }
  }

  TextEditingController controllerReg = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();

  String regNo;
  String password;
  bool obsecureText = true;
  bool isVerifying = false;
  bool loggedIn = false;
  var attendance;
  String username;

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

  void _checkCredentials(String reg, String pass) async {
    _preferences = await SharedPreferences.getInstance();
    _getResponse(reg, pass).then((response) {
      if (response != null && response.statusCode == 200) {
        var res = json.decode(response.body);
        if (res['login'] == 'successful') {
          _preferences.setStringList('credentials', [reg, pass]);
          _preferences.setString('attendance', response.body);
          _preferences.setString('username', res["user"]);
          storeUserInfo(reg);
          setState(() {
            isVerifying = false;
            loggedIn = true;
            attendance = res;
            username = res["user"];
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

  storeUserInfo(String reg) {
    String username = _preferences.getString("username");
    String token = _preferences.getString("fcm-token");
    String version = _preferences.getString("appVersion");
    String device = _preferences.getString("device");
    databaseReference.child("users").update({
      "$reg": {
        "appVersion": version,
        "device": device,
        "fcmToken": token,
        "name": username,
      }
    });
  }

  logout() {
    _preferences.remove('credentials');
    setState(() {
      loggedIn = false;
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
        // fit: StackFit.expand,
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
            margin: EdgeInsets.only(top: 270.0),
            //  color: Colors.teal,
            width: width * 0.9,
            //height: height * 0.5,
            alignment: Alignment.center,
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 70.0),
                  width: width * 0.9,
                  child: Material(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    child: Container(
                      //height: height * 0.18,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            child: TextFormField(
                              controller: controllerReg,
                              focusNode: _regFocus,
                              keyboardType: TextInputType.numberWithOptions(),
                              textInputAction: TextInputAction.next,
                              style: TextStyle(fontSize: height * 0.023),
                              onFieldSubmitted: (term) {
                                _fieldFocusChange(
                                    context, _regFocus, _passFocus);
                              },
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Registration Number',
                                  prefixIcon: Icon(Icons.person)),
                            ),
                          ),
                          SizedBox(
                            //    height: height * 0.07,
                            width: width * 0.9,
                            child: Container(
                              child: SizedBox.fromSize(
                                // size: Size.fromHeight(height * 0.08),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      // height: height * 0.08,
                                      width: width * 0.75,
                                      child: TextFormField(
                                        obscureText: obsecureText,
                                        controller: controllerPass,
                                        focusNode: _passFocus,
                                        textInputAction: TextInputAction.done,
                                        style:
                                            TextStyle(fontSize: height * 0.023),
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
                                      // height: height * 0.08,
                                      child: IconButton(
                                        icon: obsecureText
                                            ? Icon(
                                                Icons.visibility_off,
                                              )
                                            : Icon(
                                                Icons.visibility,
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
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 30.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 100.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    width: width * 0.6,
                    height: height * 0.055,
                    child: Material(
                      //color: Color.fromRGBO(64, 224, 208, 1.0),
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      child: InkWell(
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                fontSize: height * 0.023),
                          ),
                        ),
                        onTap: () {
                          _passFocus.unfocus();
                          _regFocus.unfocus();
                          isVerifying = true;
                          regNo = controllerReg.text;
                          password = controllerPass.text;
                          _checkCredentials(regNo, password);
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 25.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.4),
                  child: isVerifying
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                        )
                      : null,
                )
              ],
            ),
          )
          //   Container(
          //     margin: EdgeInsets.only(top: 270.0),
          //     width: width * 0.9,
          //     height: height * 0.5,
          //     child: ListView(
          //       //mainAxisAlignment: MainAxisAlignment.spaceAround,
          //       children: <Widget>[
          //         Container(
          //          // color: Colors.redAccent,
          //           height: height * 0.24,
          //           width: width * 0.9,
          //           child: ListView(
          //             children: <Widget>[
          //             ],
          //           ),
          //         ),
          //         Container(
          //           padding: EdgeInsets.symmetric(horizontal: 80.0),
          //           height: height * 0.06,
          //           //margin: EdgeInsets.only(top: height * 0.44),
          //           decoration: BoxDecoration(
          //            // color: Colors.red,
          //             borderRadius: BorderRadius.all(Radius.circular(20.0)),
          //           ),
          //           child: Container(
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.all(Radius.circular(20.0)),
          //             ),
          //             width: width * 0.45,
          //           //  height: height * 0.055,
          //             child: Material(
          //               color: Color.fromRGBO(64, 224, 208, 1.0),
          //               borderRadius: BorderRadius.all(Radius.circular(20.0)),
          //               child: InkWell(
          //                 splashColor: Colors.white,
          //                 child: Center(
          //                   child: Text(
          //                     "Login",
          //                     style: TextStyle(
          //                         fontWeight: FontWeight.w400,
          //                         color: Colors.black,
          //                         fontSize: height * 0.025),
          //                   ),
          //                 ),
          //                 onTap: () {
          //                   _passFocus.unfocus();
          //                   _regFocus.unfocus();
          //                   isVerifying = true;
          //                   regNo = controllerReg.text;
          //                   password = controllerPass.text;
          //                   _checkCredentials(regNo, password);
          //                 },
          //               ),
          //             ),
          //           ),
          //         ),
          //         Container(
          //           margin: EdgeInsets.only(top: 30.0),
          //           padding: EdgeInsets.symmetric(horizontal: 165.0),
          //          // padding: EdgeInsets.only(top: height * 0.7),
          //           child: isVerifying
          //               ? CircularProgressIndicator(
          //                   valueColor:
          //                       AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          //                 )
          //               : null,
          //         )
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget attendancePage(var height, var width) {
    List<Attendance> att = _parseAttendace();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkTheme ? primaryDark : primaryLight,
        elevation: 0.0,
        title: Text(
          capFirst(username.toLowerCase().split(" ")),
          style: TextStyle(color: darkTheme ? Colors.black : Colors.white),
        ),
        actions: <Widget>[
          InkWell(
            child: Container(
                padding: EdgeInsets.only(right: 10.0),
                alignment: Alignment.center,
                child: Text(
                  "Logout",
                  style: TextStyle(
                      color: darkTheme ? Colors.black : Colors.white,
                      fontSize: 18.0),
                )),
            onTap: () {
              logout();
            },
          )
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Container(
        child: ListView.builder(
          itemCount: att.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 1.0),
              height: 350.0,
              color: Colors.transparent,
              child: _buildSubjectCard(
                  att[index].name,
                  att[index].total,
                  att[index].attended,
                  att[index].missed,
                  att[index].percentage,
                  context,
                  index),
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

  capFirst(List<String> name) =>
      '${name[0][0].toUpperCase()}${name[0].substring(1)} ${name[1][0].toUpperCase()}${name[1].substring(1)}';

  _buildSubjectCard(subName, subClasses, subPresent, subAbsent, subPercentage,
      context, index) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    CachedImg camm = new CachedImg();

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      child: GestureDetector(
        onTap: () {
          // showSubjectMarks(); // functionality for marks
        },
        child: Stack(
          children: <Widget>[
            Container(
                height: 350.0,
                child: Parallax.inside(
                  mainAxisExtent: 200.0,
                  child: camm.images[index],
                )),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 110.0,
                    //color: Colors.red,
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(3.0, 10.0, 3.0, 0.0),
                    child: Text(
                      subName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Container(
                    child: Center(
                        child: CircularPercentIndicator(
                      //radius: height * 0.11,
                      radius: 110.0,
                      animation: true,
                      animationDuration: 100,
                      lineWidth: 7.0,
                      percent: double.parse(subPercentage.substring(
                              0, subPercentage.length - 1)) /
                          100,
                      center: Text(
                          subPercentage.substring(0, subPercentage.length - 3),
                          style: TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.w300,
                              color: Colors.white)),
                      progressColor: Colors.white,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: Colors.white10,
                    )),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Total",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                            ),
                            Text(
                              subClasses,
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Attended",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                            ),
                            Text(
                              subPresent,
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              "Missed",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                            ),
                            Text(
                              subAbsent,
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  onTap: () {
//                           _passFocus.unfocus();
//                           _regFocus.unfocus();
//                           isVerifying = true;
//                           regNo = controllerReg.text;
//                           password = controllerPass.text;
//                           _checkCredentials(regNo, password);
//                         },

// Material(
//                         borderRadius: BorderRadius.all(Radius.circular(20.0)),
//                         child: Container(
//                           height: height * 0.17,
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: <Widget>[
//                               SizedBox(
//                                 child: TextFormField(
//                                   controller: controllerReg,
//                                   focusNode: _regFocus,
//                                   keyboardType:
//                                       TextInputType.numberWithOptions(),
//                                   textInputAction: TextInputAction.next,
//                                   style: TextStyle(fontSize: height * 0.023),
//                                   onFieldSubmitted: (term) {
//                                     _fieldFocusChange(
//                                         context, _regFocus, _passFocus);
//                                   },
//                                   decoration: const InputDecoration(
//                                       border: InputBorder.none,
//                                       labelText: 'Registration Number',
//                                       prefixIcon: Icon(Icons.person)),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: height * 0.07,
//                                 width: width * 0.9,
//                                 child: Container(
//                                   child: SizedBox.fromSize(
//                                    // size: Size.fromHeight(height * 0.08),
//                                     child: Row(
//                                       children: <Widget>[
//                                         Container(
//                                           height: height * 0.08,
//                                           width: width * 0.75,
//                                           child: TextFormField(
//                                             obscureText: obsecureText,
//                                             controller: controllerPass,
//                                             focusNode: _passFocus,
//                                             textInputAction:
//                                                 TextInputAction.done,
//                                             style: TextStyle(
//                                                 fontSize: height * 0.023),
//                                             onFieldSubmitted: (value) {
//                                               _passFocus.unfocus();
//                                             },
//                                             decoration: InputDecoration(
//                                                 border: InputBorder.none,
//                                                 labelText: 'Password',
//                                                 prefixIcon: Icon(obsecureText
//                                                     ? Icons.lock
//                                                     : Icons.lock_open)),
//                                           ),
//                                         ),
//                                         Container(
//                                           height: height * 0.08,
//                                           child: IconButton(
//                                             icon: obsecureText
//                                                 ? Icon(
//                                                     Icons.visibility_off,
//                                                   )
//                                                 : Icon(
//                                                     Icons.visibility,
//                                                   ),
//                                             onPressed: () => setState(() {
//                                                   obsecureText = !obsecureText;
//                                                 }),
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),

//                             ],
//                           ),
//                         ),
//                       ),
