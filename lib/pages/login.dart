import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'slcm.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';


class Login extends StatefulWidget{
  @override
  createState() => new LoginState();
}

class LoginState extends State<Login>{

  TextEditingController controllerReg = new TextEditingController();
  TextEditingController controllerPass = new TextEditingController();

  String regNo;
  String password;
  bool obs = true;
  Icon visibility = Icon(Icons.visibility_off);

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
      var match = {
        'username': reg,
        'password': pass
      };
      final response = await http.post(_slcmApi,
      headers: {
        HttpHeaders.contentTypeHeader : 'application/json'
      },
      body: json.encode(match),
      );
      return response;
     } on SocketException catch(e){
       _showDialog("No Internet", "Please check your internet connection and try again!");
       print(e);
       return null;
     }
  }

  void _checkCredentials(String reg, String pass) {
    _getResponse(reg, pass).then((response){
      if(response.statusCode == 200){
        var res = json.decode(response.body);
        if(res['login'] == 'successful'){
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => StudentInfo(json: res,)));
          } else {
          _showDialog("Invalid Credentials", "Please enter a valid email and/or password.");
          controllerReg.clear();
          controllerPass.clear();
          }
        } else {
          _showDialog("Server Down", "It seems SLCM is down, please try again in some time.");
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * .40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("manipal.jpg"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * .60,
                  color: Color.fromRGBO(190, 232, 223, 0.75),
                )
              ],
            ),
            Container(
              height: 300.0,
              margin: EdgeInsets.only(
                left: 30.0,
                right: 30.0,
                top: 140.0,
              ),
              child: Container(
                  height: 300.0,
                  width: 400.0,
                  child:  Card(
                    color: Color.fromRGBO(255, 255, 245, 1.0),
                    elevation: 5.0,
                    child: ListView(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(top: 0.0),
                          child: Icon(Icons.person_pin, size: 95.0, color: Colors.black,),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 2.5,
                            left: 15.0,
                            right: 15.0,
                          ),
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                controller: controllerReg,
                                onEditingComplete: (){regNo = controllerReg.text;},
                                decoration: InputDecoration(
                                    fillColor: Colors.redAccent,
                                    prefixIcon: Icon(Icons.folder_open),
                                    labelText: "Registration No."
                                ),
                                keyboardType: TextInputType.numberWithOptions(),
                              ),
                              Padding(padding: EdgeInsets.symmetric(vertical: 0.0),),
                              TextFormField(
                                  controller: controllerPass,
                                  obscureText: obs,
                                  onEditingComplete: (){password = controllerPass.text;},
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline),
                                    labelText: "Password",
                                    suffix: IconButton(icon: obs ? Icon(Icons.visibility_off) : Icon(Icons.visibility), onPressed: (){
                                      setState(() {
                                        obs = !obs;
                                      });
                                    })
                                  ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 440.0,
              ),
              child: Center(
                child: Container(
                  height: 50.0,
                  width: 150.0,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(color: Colors.black38, blurRadius: 1.0, spreadRadius: 1.0),
                    ],
                    color: Color.fromRGBO(234, 116, 76, 1.0),
                    borderRadius: BorderRadius.all(Radius.elliptical(25.0, 25.0)),
                  ),
                  child: Center(
                    child: FlatButton(
                        onPressed: () {
                          _checkCredentials(controllerReg.text, controllerPass.text);
                          print(controllerReg.text);
                          print(controllerPass.text);
                        },
                        child: Center(
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0
                            ),
                          ),
                        )),
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}