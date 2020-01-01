import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mttn_app/main.dart';
import 'package:mttn_app/utils/eu_datetime.dart';
import 'package:mttn_app/utils/subjectModals.dart';
import 'package:mttn_app/widgets/sisSubjectCard.dart';
import 'package:mttn_app/widgets/slcmSubjectCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SLCM extends StatefulWidget {
  @override
  createState() => new SLCMState();
}

DatabaseReference databaseReference = new FirebaseDatabase().reference();

class SLCMState extends State<SLCM> with AutomaticKeepAliveClientMixin {
  Color secColor = new Color.fromRGBO(234, 116, 76, 1.0);
  Color primColor = Color.fromRGBO(190, 232, 223, 0.75);

  GlobalKey<ScaffoldState> _key = GlobalKey();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  SharedPreferences _preferences;
  String _slcmApi, _sisApi;

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
        _sisApi = urls['SIS Data'];
      });
    } catch (e) {
      var snapshot = await databaseReference.child('URL').once();
      urls = snapshot.value;
      setState(() {
        _slcmApi = urls['SLCM Data'];
        _sisApi = urls['SIS Data'];
      });
    }
  }

  _cachedLogin() async {
    _preferences = await SharedPreferences.getInstance();
    List<String> cred = _preferences.getStringList('credentials') ?? [];
    var temp = _preferences.getBool('isSLCM');
    if (temp == null) {
      logout(cachedLogout: true);
      return;
    }
    if (cred.length != 0) {
      slcmSelected = temp;
      setState(() {});
      _checkCredentials(cred[0], cred[1]);
    }
  }

  TextEditingController controllerReg = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();
  TextEditingController controllerDOB = new TextEditingController();
  bool obsecureText = true;
  bool isVerifying = false;
  bool loggedIn = false;
  var attendance;
  String username;
  bool isRefreshing = false;
  bool slcmSelected = true;

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
        slcmSelected ? _slcmApi : _sisApi,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: json.encode(match),
      );
      return response;
    } on SocketException catch (e) {
      if (e.osError.errorCode == 111) {
        _showDialog("Server Down",
            "It seems server is down, please try again in some time.");
        return null;
      }
      if (await getCache()) {
        showSnackbar(
            "Cached attendance loaded. Please check your internet connection and try again!");
        return null;
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
          _preferences.setBool('isSLCM', slcmSelected);
          _preferences.setStringList('credentials', [reg, pass]);
          _preferences.setString('attendance', response.body);
          _preferences.setString('username', res["user"]);
          clearControllers();
          storeUserInfo(reg);
          setState(() {
            isVerifying = false;
            loggedIn = true;
            attendance = res;
            username = slcmSelected ? res["user"] : res["Name"];
            isRefreshing = false;
          });
        } else if (res['login'] == 'unsuccessful') {
          _showDialog("Invalid Credentials",
              "Please enter a valid registration number and/or ${slcmSelected ? "password" : "date of birth"}.");
          setState(() {
            loggedIn = false;
            isVerifying = false;
            isRefreshing = false;
          });
        }
      } else {
        _showDialog("Server Error",
            "Trouble communicating with the university server. Please try again later.");
        setState(() {
          isVerifying = false;
          isRefreshing = false;
        });
      }
    });
  }

  clearControllers() {
    controllerReg.clear();
    controllerPass.clear();
    controllerDOB.clear();
    _passFocus.unfocus();
    _regFocus.unfocus();
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

  logout({bool cachedLogout = false}) {
    _preferences.remove('credentials');
    _preferences.remove('attendance');
    _preferences.remove('username');
    _preferences.remove('isSLCM');
    if (!cachedLogout) {
      showSnackbar("Successfully logged out.");
    }
    setState(() {
      loggedIn = false;
    });
  }

  getCache() async {
    _preferences = await SharedPreferences.getInstance();
    String temp = _preferences.getString('attendance');
    if (temp != null) {
      var res = jsonDecode(temp);
      var flag = _preferences.getBool('isSLCM');
      if (flag == null) {
        logout();
        return false;
      }
      setState(() {
        slcmSelected = flag;
        isVerifying = false;
        loggedIn = true;
        attendance = res;
        username = slcmSelected ? res["user"] : res["Name"];
        isRefreshing = false;
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _key,
      backgroundColor: darkTheme ? Colors.black : Colors.white,
      floatingActionButton: (!loggedIn && !isVerifying)
          ? Container(
              height: height / 12,
              width: height / 12,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      slcmSelected ? 'SIS' : 'SLCM',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black),
                    ),
                    Icon(
                      Icons.swap_horiz,
                      color: Colors.black,
                      size: 25,
                    )
                  ],
                ),
                onPressed: () {
                  setState(() {
                    slcmSelected = !slcmSelected;
                  });
                },
              ),
            )
          : Container(),
      body: loggedIn ? attendancePage(height, width) : loginPage(height, width),
    );
  }

  final FocusNode _regFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  Widget loginPage(height, width) {
    return ListView(
      children: <Widget>[
        Container(
          height: height * 0.45,
          padding: const EdgeInsets.fromLTRB(10, 130, 10, 40),
          child: AnimatedCrossFade(
            firstChild: Image.asset('assets/ic.png'),
            secondChild: Image.asset('assets/edu.png'),
            duration: const Duration(milliseconds: 400),
            reverseDuration: const Duration(milliseconds: 400),
            crossFadeState: slcmSelected
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: width * 0.9,
          child: Material(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                        _fieldFocusChange(context, _regFocus, _passFocus);
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Registration Number',
                          prefixIcon: Icon(Icons.person)),
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            enabled: slcmSelected,
                            obscureText: slcmSelected ? obsecureText : false,
                            controller:
                                slcmSelected ? controllerPass : controllerDOB,
                            focusNode: _passFocus,
                            textInputAction: TextInputAction.done,
                            style: TextStyle(fontSize: height * 0.023),
                            onFieldSubmitted: (value) {
                              _passFocus.unfocus();
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText:
                                    slcmSelected ? 'Password' : 'Date of Birth',
                                prefixIcon: Icon(slcmSelected
                                    ? (obsecureText
                                        ? Icons.lock
                                        : Icons.lock_open)
                                    : Icons.date_range)),
                          ),
                        ),
                        Container(
                          child: slcmSelected
                              ? IconButton(
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
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.calendar_today,
                                  ),
                                  onPressed: () async {
                                    DateTime date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime.now());
                                    if (date != null) {
                                      controllerDOB.text =
                                          EuDateTime(date).getDate();
                                    }
                                  },
                                ),
                        )
                      ],
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
                  if (!isVerifying) {
                    _passFocus.unfocus();
                    _regFocus.unfocus();
                    isVerifying = true;
                    _checkCredentials(
                        controllerReg.text,
                        slcmSelected
                            ? controllerPass.text
                            : controllerDOB.text);
                  }
                },
              ),
            ),
          ),
        ),
        Container(
          height: 25.0,
        ),
        Container(
          child: Center(
            child: isVerifying
                ? CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  )
                : null,
          ),
        )
      ],
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
    return slcmSelected
        ? slcmAttendancePage(height, width)
        : sisAttendancePage(height, width);
  }

  Widget sisAttendancePage(var height, var width) {
    List<SisAttendance> att = parseSISAttendance();
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
                      child: SISSubjectCard(att[index]),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget slcmAttendancePage(var height, var width) {
    List<Attendance> att = _parseSLCMAttendace();

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
                      child: SLCMSubjectCard(
                          att[index].name,
                          att[index].total,
                          att[index].attended,
                          att[index].missed,
                          att[index].percentage,
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

  List<Attendance> _parseSLCMAttendace() {
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
        );
        data.add(att);
      }
    } catch (e) {
      print(e);
    }

    return data;
  }

  List<SisAttendance> parseSISAttendance() {
    List<SisAttendance> sis = new List();
    try {
      Map json = attendance["Attendance"];
      for (var key in json.keys) {
        String subname = (json[key].containsKey("Subject")
                ? json[key]["Subject"]
                : json[key]["Subject name"]) ??
            "";
        if (subname != null && subname != "") {
          List<Attendance> att = new List();
          for (String element in json[key].keys) {
            if (json[key][element] != null && json[key][element] != "") {
              if (element.contains("(%)")) {
                var temp = element.replaceFirst(" (%)", "");
                att.add(new Attendance(
                    attended: json[key][temp + " (Attd.)"],
                    percentage: json[key][temp + " (%)"],
                    total: json[key][temp + " (Held)"],
                    name: temp,
                    missed: null));
              }
            }
          }
          sis.add(SisAttendance(subname, att));
        }
      }
      return sis;
    } catch (e) {
      print(e);
    }
    return new List();
  }

  List<SubjectMarks> _parseMarks() {
    List<SubjectMarks> marks = [];

    var tempMarks;

    try {
      tempMarks = attendance['Marks'];
    } catch (e) {}
    try {
      for (var key in tempMarks.keys) {
        var name = key;
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
            name: name,
            assignments: assign,
            sessionals: sess,
            otherMarks: other));
      }
    } catch (e) {
      print(e);
    }

    return marks;
  }

  capFirst(List<String> name) {
    for (var i = 0; i < name.length; i++) {
      name[i] = "${name[i][0].toUpperCase()}${name[i].substring(1)}";
    }
    String temp = name.join(" ");
    return temp;
  }

  showSnackbar(String text) {
    SnackBar snackbar = new SnackBar(
      content: Text(text),
    );
    _key.currentState.showSnackBar(snackbar);
    return;
  }
}
