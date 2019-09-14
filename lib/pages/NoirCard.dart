import 'package:flutter/material.dart';
import 'package:mttn_app/utils/NoirVerfication.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mttn_app/main.dart';

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
  bool closeDialog = false;

  BuildContext otpContext;
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
      onLongPress: () => _launchUrl("whatsapp://send?phone=+917411447558"),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  Navigator.maybePop(context);
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
    showDialog(
        context: widget._key.currentContext,
        builder: (otpContext) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              "OTP Verification",
              textAlign: TextAlign.center,
            ),
            content: Container(
              height: 120.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: _otp,
                    keyboardType: TextInputType.number,
                  ),
                  Container(
                    width: 2,
                    height: 10,
                  ),
                  MaterialButton(
                    color: darkTheme
                        ? Colors.greenAccent.withOpacity(0.7)
                        : Colors.indigoAccent,
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        alignment: Alignment.center,
                        child: Text(
                          "Redeem Card",
                          style: TextStyle(color: Colors.white),
                        )),
                    onPressed: () async {
                      noir.signInWithPhoneNumber(_otp.text);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  handleActivation() {
    if (noir.cardDetails?.cardNumber != null) {
      SnackBar snackbar = new SnackBar(
        content: Text("Long press the card to contact MTTN PR"),
      );
      widget._key.currentState.showSnackBar(snackbar);
      return;
    }
    TextEditingController _phoneNumber = new TextEditingController();
    TextEditingController content = new TextEditingController();
    content.text = "Enter the phone number registered for your Noir card.";
    showDialog(
        context: widget._key.currentContext,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(
              content.text,
              textAlign: TextAlign.center,
            ),
            content: Container(
              height: 120.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: _phoneNumber,
                    keyboardType: TextInputType.number,
                  ),
                  Container(
                    width: 2,
                    height: 10,
                  ),
                  MaterialButton(
                    color: darkTheme
                        ? Colors.greenAccent.withOpacity(0.7)
                        : Colors.indigoAccent,
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.55,
                        alignment: Alignment.center,
                        child: Text(
                          "Verify",
                          style: TextStyle(color: Colors.white),
                        )),
                    onPressed: () async {
                      bool flag =
                          await noir.verifyPhoneNumber(_phoneNumber.text);
                      var temp = await noir.currentUser();
                      print(temp);
                      Navigator.pop(context);
                      if (flag) {
                        handleOTP();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

_launchUrl(url) async =>
    (await canLaunch(url)) ? await launch(url) : throw 'Could not lauch $url';
