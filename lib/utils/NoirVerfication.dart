import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class NoirUser {
  String cardNumber;
  String username;
  NoirUser({this.username, this.cardNumber});
}

class NoirVerification {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _reference = FirebaseDatabase().reference();
  String _verificationId;
  String smsCode;
  String phoneNumber;

  NoirUser cardDetails;
  Observable<FirebaseUser> firebaseUser;

  GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

  NoirVerification(this.key) {
    firebaseUser = Observable(_auth.onAuthStateChanged);
  }

  Future<NoirUser> currentUser() async {
    FirebaseUser user = await _auth.currentUser();
    if (user != null) {
      var snap = await _reference
          .child("NOIR")
          .child(user.phoneNumber.replaceFirst("+91", ""))
          .once();
      if (snap.value["Redeemed"] == false) {
        signOut();
        return null;
      }
      cardDetails = NoirUser(
          username: snap.value["Name"], cardNumber: snap.value["Card Number"]);
      return cardDetails;
    } else {
      return null;
    }
  }

  void signOut() async {
    if (_auth.currentUser() != null) {
      await _auth.signOut();
      print((cardDetails?.username) ?? "No user signed in");
      cardDetails = null;
      print("Successfully Signed out");
    }
  }

  Future<bool> verifyPhoneNumber(phone) async {
    phoneNumber = phone;
    var temp = await _reference.child("NOIR").child(phoneNumber).once();
    if (temp.value != null) {
      if (temp.value["Redeemed"] == false) {
        bool verified = await _processNumber();
        print(verified);
        return true;
      } else {
        print("Already redeemed");
        showSnackbar('Noir card already redeemed for this number.', pr: true);
        return false;
      }
    } else {
      print("Invalid User");
      showSnackbar('No Noir card registered for this number.', pr: true);
      return false;
    }
  }

  _processNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      print(cardDetails?.username);
      String message = 'Received phone auth credential';
      print(message);
      _reference.child("NOIR").child(phoneNumber).child("Redeemed").set(true);
      showSnackbar("Noir card successfully redeemed");
      Navigator.maybePop(key.currentContext);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      String message =
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      print(message);
      showSnackbar(
          "Phone number verification failed.\nMessage: ${authException.message}",
          pr: true);
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: "+91 " + phoneNumber,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void signInWithPhoneNumber(smsCode) async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      print(credential);
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      if (user != null) {
        print('Successfully signed in, uid: ' + user.uid);
        _reference.child("NOIR").child(phoneNumber).child("Redeemed").set(true);
        showSnackbar("Noir card successfully redeemed");
      } else {
        showSnackbar('Redeem failed. Please try again', pr: true);
      }
    } on PlatformException catch (e) {
      print(e.code);
      if (e.code == "ERROR_SESSION_EXPIRED") {
        showSnackbar('Session expired');
      } else if (e.code == "ERROR_INVALID_VERIFICATION_CODE") {
        showSnackbar("Invalid verification code");
      } else {
        showSnackbar('Something went wrong. Please try again later.', pr: true);
      }
    } catch (e) {
      print(e);
      showSnackbar('An unexpected error occured. Please try again later.',
          pr: true);
    }
  }

  showSnackbar(String message, {bool pr}) {
    print(message);
    key.currentState.showSnackBar(SnackBar(
      content: Text(message),
      action: (pr ?? false)
          ? SnackBarAction(
              label: "Contact us",
              onPressed: () =>
                  _launchUrl("whatsapp://send?phone=+917411447558"),
            )
          : null,
    ));
  }

  _launchUrl(url) async =>
      (await canLaunch(url)) ? await launch(url) : throw 'Could not lauch $url';
}
