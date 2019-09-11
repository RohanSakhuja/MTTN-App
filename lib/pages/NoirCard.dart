import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mttn_app/utils/NoirVerfication.dart';

class NoirCard extends StatefulWidget {
  final GlobalKey<ScaffoldState> _key;
  NoirCard(this._key);
  @override
  NoirCardState createState() => new NoirCardState();
}

class NoirCardState extends State<NoirCard> with AutomaticKeepAliveClientMixin {
  String phoneNumber;
  String smsCode;
  bool isRedeemed = false;
  FirebaseUser _currentUser;

  @override
  void initState() {
    NoirVerification(widget._key).currentUser().then((val) {
      phoneNumber = val ?? "";
      print("constructor: " + phoneNumber);
    });
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InkWell(
      onTap: handleActivation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                  Color.fromRGBO(0, 0, 0, 1.0),
                  Color.fromRGBO(25, 25, 25, 1.0),
                  Color.fromRGBO(65, 65, 65, 1.0),
                ])),
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "NOIR SELECT",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                          fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: buildInfoTile(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.power,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () =>
                              NoirVerification(widget._key).signOut(),
                        ),
                         IconButton(
                          icon: Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 30,
                          ),
                          // onPressed: () =>
                          //     NoirVerification(widget._key).signOut(),
                          onPressed: () => handleOTP(),
                        ),
                        
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: info,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  info() {
    NoirVerification(widget._key).currentUser().then((val) {
      phoneNumber = val;
      print("Value: " + phoneNumber);
      setState(() {});
    });
  }

  buildInfoTile() {
    return ListTile(
      title: Text(
        "ROHAN SAKHUJA",
        style: TextStyle(color: Color.fromRGBO(255, 215, 0, 0.7), fontSize: 18),
      ),
      subtitle: Text(
        phoneNumber??"",
        style: TextStyle(
          color: Color.fromRGBO(255, 215, 0, 0.7),
          fontSize: 18,
        ),
      ),
    );
  }

  handleOTP(){
    TextEditingController _OTP = new TextEditingController();
    showDialog(
      context: widget._key.currentContext,
      builder: (context){
        return AlertDialog(
          title: Text("OTP Verification"),
          content: TextFormField(
            controller: _OTP,
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            
          ],
        );
      }
    );
  }

  handleActivation() {
    TextEditingController _phoneNumber = new TextEditingController();
    showDialog(
        context: widget._key.currentContext,
        builder: (context) {
          return AlertDialog(
            title: Text("Phone Number"),
            content: TextFormField(
              controller: _phoneNumber,
              keyboardType: TextInputType.number,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Verify"),
                onPressed: () {
                  handleOTP();
                  Navigator.pop(context);
                  NoirVerification(widget._key).setup(_phoneNumber.text);
                },
              )
            ],
          );
        });
  }
}
