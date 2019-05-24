import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'slcm.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flare_flutter/flare_actor.dart';
import 'colors/color.dart';

class Login extends StatefulWidget {
  @override
  createState() => new LoginState();
}

DatabaseReference databaseReference = new FirebaseDatabase().reference();

bool isHidden;

class LoginState extends State<Login> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _fetchState();
    super.initState();
  }

  TextEditingController controllerReg = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();

  String regNo;
  String password;
  bool obsecureText = true;
  bool isVerifying = false;

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

  Future<String> _fetchState() async {
  var snapshot = await databaseReference.once();
  Map<dynamic, dynamic> stateJson = snapshot.value['SLCM'];

  for (var item in stateJson.keys) {
    try {
      isHidden = stateJson["isHidden"];
      setState(() {
        isVerifying = false;
      });
      print("Eefef");
    } catch (e) {
      print(e);
    }
  }
}

  Future<http.Response> _getResponse(String reg, String pass) async {
    try {
      final String _slcmApi = 'http://139.59.65.42:8080/';
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
      _showDialog("No Internet",
          "Please check your internet connection and try again!");
      setState(() {
        isVerifying = false;
      });
      print(e);
      return null;
    }
  }

  void _checkCredentials(String reg, String pass) {
    _getResponse(reg, pass).then((response) {
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        if (res['login'] == 'successful') {
          setState(() {
            isVerifying = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StudentInfo(
                        json: res,
                      )));
        } else {
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
        _showDialog("Server Down",
            "It seems SLCM is down, please try again in some time.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _fetchState();

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
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
              height: height * 0.52,
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
                            child: TextField(
                              controller: controllerReg,
                              keyboardType: TextInputType.numberWithOptions(),
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
                                      child: TextField(
                                        obscureText: obsecureText,
                                        controller: controllerPass,
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
                      isVerifying = true;
                      regNo = controllerReg.text;
                      password = controllerPass.text;
                      print(controllerReg.text + controllerPass.text);
                      isHidden
                          ? _showDialog("Oops!",
                              "It seems like SLCM is down for the time being.")
                          : _checkCredentials(regNo, password);
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: height * 0.7),
              child: isVerifying
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colorMain),
                    )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
