import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mttn_app/utils/NoirVerfication.dart';
import 'package:url_launcher/url_launcher.dart';

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
  NoirUser card;
  NoirVerification noir;
  @override
  void initState() {
    noir = NoirVerification(widget._key);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("Rebuilt");
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
                      child: buildInfoTile()),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => noir.signOut(),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () => _launchUrl(
                              "https://manipalthetalk.org/NoirSelectPrivileges.pdf"),
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

  buildInfoTile() {
    print("###");
    print(card);
    print("###");
    return StreamBuilder(
      stream: noir.firebaseUser,
      builder: (context, snap) {
        if (snap.hasData) {
          return FutureBuilder<NoirUser>(
              future: noir.currentUser(),
              builder: (context, snapshot) {
                if (snap.hasData && snapshot.data?.username != null) {
                  // print(snapshot.data.username);
                  return ListTile(
                    title: Text(
                      snapshot.data.username,
                      style: TextStyle(
                          color: Color.fromRGBO(255, 215, 0, 0.7),
                          fontSize: 18),
                    ),
                    subtitle: Text(
                      snapshot.data.cardNumber,
                      style: TextStyle(
                        color: Color.fromRGBO(255, 215, 0, 0.7),
                        fontSize: 18,
                      ),
                    ),
                  );
                } else {
                  return CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Color.fromRGBO(255, 215, 0, 0.7)),
                  );
                }
              });
        } else {
          return Text(
            "TAP TO ACTIVATE NOIR CARD",
            style: TextStyle(
              color: Color.fromRGBO(255, 215, 0, 0.7),
              fontSize: 15,
            ),
          );
        }
      },
    );
  }

  handleOTP() {
    TextEditingController _otp = new TextEditingController();
    return StreamBuilder<FirebaseUser>(
        stream: noir.firebaseUser,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data?.phoneNumber != null) {
          } else {
            showDialog(
                context: widget._key.currentContext,
                builder: (context) {
                  return AlertDialog(
                    title: Text("OTP Verification"),
                    content: TextFormField(
                      controller: _otp,
                      keyboardType: TextInputType.number,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Redeem'),
                        onPressed: () async {
                          noir.signInWithPhoneNumber(_otp.text);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          }
        });
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
                onPressed: () async {
                  await noir.verifyPhoneNumber(_phoneNumber.text);
                  var temp = await noir.currentUser();
                  print(temp);
                  Navigator.pop(context);
                  handleOTP();
                },
              )
            ],
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

_launchUrl(url) async =>
    (await canLaunch(url)) ? await launch(url) : throw 'Could not lauch $url';
