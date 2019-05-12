import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'slcm.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flare_flutter/flare_actor.dart';

Color colorMain = Color.fromRGBO(234, 116, 76, 1.0);

class Login extends StatefulWidget {
  @override
  createState() => new LoginState();
}

class LoginState extends State<Login> {
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
              "Please enter a valid email and/or password.");
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

  FlareController flrctrl;

  // Container buildThisShit() {
  //   return Container(
  //     height: 120.0,
  //     width: 300.0,
  //     child: FlareActor(
  //       "assets/first1.flr",
  //       controller: flrctrl,
  //       alignment: Alignment.center,
  //       fit: BoxFit.cover,
  //       animation: isVerifying ? "first" : null,
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: height * .40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("manipal.jpg"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: height * .60,
                )
              ],
            ),
          ),
          Center(
              child: Container(
            child: Center(
              child: ListView(
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: height * 0.17),
                    width: width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(1.0),
                            ],
                            stops: [
                              0.0,
                              0.7
                            ])),
                    height: height * 0.25,
                  ),
                  Material(
                    color: Colors.white,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 60.0,
                            width: width * 0.8,
                            child: TextField(
                              controller: controllerReg,
                              keyboardType: TextInputType.numberWithOptions(),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Registraion Number',
                                  prefixIcon: Icon(Icons.person)),
                            ),
                          ),
                          SizedBox(
                            height: 60.0,
                            width: width * 0.8,
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
                          IconButton(
                            icon: obsecureText
                                ? Icon(
                                    Icons.visibility_off,
                                    color: Colors.black.withOpacity(0.5),
                                  )
                                : Icon(
                                    Icons.visibility,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                            onPressed: () => setState(() {
                                  obsecureText = !obsecureText;
                                }),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.0),
                          ),
                          MaterialButton(
                            minWidth: width * 0.75,
                            color: colorMain,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 18.0),
                            ),
                            onPressed: () {
                              isVerifying = true;
                              regNo = controllerReg.text;
                              password = controllerPass.text;
                              _checkCredentials(regNo, password);
                            },
                          ),
                          Padding(
                            padding: EdgeInsets.all(15.0),
                          ),
                          Container(
                            height: height * 0.05,
                            width: width * 0.1,
                            child: isVerifying
                                ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(120, 188, 196, 1)),
                                )
                                : null,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ))
        ]));
  }
}
