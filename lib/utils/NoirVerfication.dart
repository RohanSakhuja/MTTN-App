import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';

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
      showSnackbar("Successfully Signed out");
    }
  }

  Future<bool> verifyPhoneNumber(phone) async {
    phoneNumber = phone;
    var temp = await _reference.child("NOIR").child(phoneNumber).once();
    if (temp.value != null) {
      bool verified = await _processNumber();
      print(verified);
      return true;
    } else {
      print("Invalid User");
      showSnackbar('Invalid User');
      return false;
    }
  }

  // Example code of how to verify phone number
  _processNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      print(cardDetails?.username);
      String message = 'Received phone auth credential';
      showSnackbar(message);
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      String message =
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      showSnackbar(message);
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
        showSnackbar('Successfully signed in, uid: ' + user.uid);
      } else {
        showSnackbar('Sign in failed');
      }
    } on PlatformException catch (e) {
      print(e.code);
      if (e.code == "ERROR_SESSION_EXPIRED") {
        showSnackbar('ERROR_SESSION_EXPIRED');
      } else if (e.code == "ERROR_INVALID_VERIFICATION_CODE") {
        showSnackbar("ERROR_INVALID_VERIFICATION_CODE");
      } else {
        showSnackbar('Platform Exception occured');
      }
    } catch (e) {
      print(e);
      showSnackbar('Exception occured');
    }
  }

  showSnackbar(String message) {
    print(message);
    key.currentState.showSnackBar(SnackBar(
      content: message.contains("failed") ? Text(":( Looks like the verification faces some error, please try again or contact us.") : Text(message)
    ));
  }
}
