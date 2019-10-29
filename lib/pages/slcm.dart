import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final String code;

  Attendance(
      {this.attended,
      this.missed,
      this.name,
      this.percentage,
      this.total,
      this.code});
}

class Marks {
  final String name;
  final String obtained;
  final String total;

  Marks({this.name, this.obtained, this.total});
}

class SubjectMarks {
  final String code;
  final List<Marks> assignments;
  final List<Marks> sessionals;
  final List<Marks> otherMarks;

  SubjectMarks({this.code, this.assignments, this.sessionals, this.otherMarks});
}

class SLCM extends StatefulWidget {
  @override
  createState() => new SLCMState();
}

DatabaseReference databaseReference = new FirebaseDatabase().reference();

class SLCMState extends State<SLCM> with AutomaticKeepAliveClientMixin {
  Color secColor = new Color.fromRGBO(234, 116, 76, 1.0);
  Color primColor = Color.fromRGBO(190, 232, 223, 0.75);

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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

  _cachedLogin() async {
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
  bool isRefreshing = false;

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

  _checkCredentials(String reg, String pass) async {
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
            isRefreshing = false;
          });
        } else if (res['login'] == 'unsuccessful') {
          _showDialog("Invalid Credentials",
              "Please enter a valid registration number and/or password.");
          controllerReg.clear();
          controllerPass.clear();
          setState(() {
            loggedIn = false;
            isVerifying = false;
            isRefreshing = false;
          });
        }
      } else {
        setState(() {
          isVerifying = false;
          isRefreshing = false;
        });
      }
    });
  }

  storeUserInfo(String reg) async {
    String username = _preferences.getString("username");
    String token = _preferences.getString("fcm-token") ?? "null";
    String version = _preferences.getString("appVersion") ?? "null";
    String device = _preferences.getString("device") ?? "null";
    if (token == "null" || device == "null" || version == "null") {
      token = await _firebaseMessaging.getToken();
      _preferences.setString("fcm-token", token);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device = "${androidInfo.model}-${androidInfo.device}";
      version = "1.0.0";
      _preferences.setString("device", "$device");
      _preferences.setString("appVersion", "$version");
    }
    databaseReference.child("users-android").update({
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
        ],
      ),
    );
  }

  Future<Null> _refresh() async {
    isRefreshing = true;
    Completer<Null> completer = new Completer<Null>();
    _cachedLogin();
    Future.doWhile(() {
      return Future.delayed(new Duration(seconds: 1), () {
        return isRefreshing;
      });
    }).then((val) => completer.complete());
    return completer.future;
  }

  Widget attendancePage(var height, var width) {
    List<Attendance> att = _parseAttendace();

    att.sort((a, b) {
      return a.percentage.compareTo(b.percentage);
    });

    List<SubjectMarks> marks = _parseMarks();
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: darkTheme ? primaryDark : primaryLight,
        elevation: 0.0,
        title: Text(
          capFirst(username.toLowerCase().split(" ")),
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          InkWell(
            child: Container(
                padding: EdgeInsets.only(right: 10.0),
                alignment: Alignment.center,
                child: Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                )),
            onTap: () {
              logout();
            },
          )
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Container(
          child: att.length == 0
              ? Center(
                  child: Text(
                    "No Attendance Data",
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  itemCount: att.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 1.0),
                      color: Colors.transparent,
                      child: _buildSubjectCard(
                          att[index].name,
                          att[index].total,
                          att[index].attended,
                          att[index].missed,
                          att[index].percentage,
                          att[index].code,
                          context,
                          index,
                          marks),
                    );
                  },
                ),
        ),
      ),
    );
  }

  List<Attendance> _parseAttendace() {
    List<Attendance> data = [];

    var temp = attendance['Attendance'];

    try {
      for (var key in temp.keys) {
        Attendance att = Attendance(
            name: temp[key]['Name'],
            attended: temp[key]['Attended'],
            missed: temp[key]['Missed'],
            total: temp[key]['Total'],
            percentage: temp[key]['Percentage'],
            code: temp[key]['Code']);
        data.add(att);
      }
    } catch (e) {
      print(e);
    }

    return data;
  }

  List<SubjectMarks> _parseMarks() {
    List<SubjectMarks> marks = [];

    var tempMarks;

    try {
      tempMarks = attendance['Marks'];
    } catch (e) {}

    //print(tempMarks);

    try {
      for (var key in tempMarks.keys) {
        var code = key;
        List<Marks> assign = [];
        List<Marks> sess = [];
        List<Marks> other = [];

        for (var temp in tempMarks[key].keys) {
          Marks m = Marks(
              name: temp,
              obtained: tempMarks[key][temp]['Obtained'],
              total: tempMarks[key][temp]['Total']);

          if (m.name != 'Total Marks') {
            if (temp.toString().contains('Assignment')) {
              assign.add(m);
            } else if (temp.toString().contains('Sessionals')) {
              sess.add(m);
            } else {
              other.add(m);
            }
          }
        }

        marks.add(SubjectMarks(
            code: code,
            assignments: assign,
            sessionals: sess,
            otherMarks: other));
      }
    } catch (e) {
      print(e);
      //print(e);
    }

    return marks;
  }

  capFirst(List<String> name) {
    for (var i = 0; i < name.length; i++) {
      name[i] = "${name[i][0].toUpperCase()}${name[i].substring(1)}";
    }
    String temp = name.join(" ");
    print(temp);
    return temp;
  }

  showSubjectMarks(name, index, SubjectMarks subjectMarks) {
    CachedImg camm = new CachedImg();

    SubjectMarks tempMarks = subjectMarks;
    List<Marks> mainMarks = [];
    mainMarks.addAll(tempMarks.assignments);
    mainMarks.addAll(tempMarks.sessionals);
    mainMarks.addAll(tempMarks.otherMarks);

    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Stack(
            children: <Widget>[
              Container(
                height: 350.0,
                width: MediaQuery.of(context).size.width,
                child: camm.images[index],
              ),
              Container(
                  height: 350.0,
                  padding: EdgeInsets.all(18.0),
                  color: Colors.black.withOpacity(0.3),
                  child: Column(
                    children: <Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: Colors.white, fontSize: 28.0),
                          )),
                      Container(
                        height: 240,
                        padding: EdgeInsets.only(top: 16.0),
                        child: ListView.builder(
                          itemCount: mainMarks.length,
                          itemBuilder: (context, ind) {
                            return Container(
                              padding: EdgeInsets.all(2.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 180,
                                        child: Text(
                                          mainMarks[ind].name,
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16.0),
                                        ),
                                      ),
                                      Text(
                                        "${mainMarks[ind].obtained} / ${mainMarks[ind].total}",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24.0),
                                      )
                                    ],
                                  ),
                                  (ind + 1 < mainMarks.length &&
                                          mainMarks[ind + 1]
                                              .name
                                              .contains('Sessional 1'))
                                      ? Container(
                                          margin: EdgeInsets.all(20.0),
                                          color: Colors.white.withOpacity(1.0),
                                          height: 0.5,
                                          width: 300.0,
                                        )
                                      : Container()
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  )),
            ],
          );
        });
  }

  _getMarks(SubjectMarks marks, String type) {
    try {
      if (type == "obtained") {
        double sum = 0;

        for (Marks temp in marks.assignments)
          sum += double.parse(temp.obtained);

        for (Marks temp in marks.sessionals) sum += double.parse(temp.obtained);

        for (Marks temp in marks.otherMarks) sum += double.parse(temp.obtained);

        return sum;
      } else {
        double sum = 0;

        for (Marks temp in marks.assignments) sum += double.parse(temp.total);

        for (Marks temp in marks.sessionals) sum += double.parse(temp.total);

        for (Marks temp in marks.otherMarks) sum += double.parse(temp.total);

        return sum;
      }
    } catch (e) {
      //print(e);
      return "null on marks";
    }
  }

  _buildSubjectCard(subName, subClasses, subPresent, subAbsent, subPercentage,
      subCode, context, index, List<SubjectMarks> marks) {
    CachedImg camm = new CachedImg();

    SubjectMarks subMarks;
    bool hasMarks = false;

    print(marks.length);
    print(subCode);

    for (var i in marks) {
      if (i.code == subCode) {
        subMarks = i;
      }
    }

    var marksObtained = _getMarks(subMarks, "obtained");
    var marksMax = _getMarks(subMarks, "max");

    bool nullMarks = false;

    if (marksObtained == "null on marks" || marksMax == "null on marks") {
      nullMarks = true;
      hasMarks = false;
    }
    try {
      hasMarks = (marksMax > 0 && marksMax != "null on marks") ? true : false;
    } catch (e) {}

    print(hasMarks);

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      child: GestureDetector(
        onTap: () {
          if (hasMarks) showSubjectMarks(subName, index, subMarks);
        },
        child: Stack(
          children: <Widget>[
            Container(
                height: 395.0,
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
                    margin: EdgeInsets.only(top: 12.0),
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
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(24.0),
                    color: Colors.white70,
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 1,
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 0.0),
                    child: !(nullMarks || !hasMarks)
                        ? RichText(
                            text: TextSpan(
                                style: Theme.of(context).textTheme.body1,
                                children: [
                                  TextSpan(
                                      text: marksObtained.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 32.0)),
                                  TextSpan(
                                      text: " / ",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16.0)),
                                  TextSpan(
                                      text: marksMax.toString(),
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16.0)),
                                ]),
                          )
                        : Container(),
                  ),
                  Container(
                    child: Text(
                        //  (!hasMarks || nullMarks) ? (hasMarks && !nullMarks ? "tap for more" : "") : "tap for more.",
                        (hasMarks)
                            ? "tap for more"
                            : ((nullMarks) ? "" : "no marks uploaded"),
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12.0)),
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
