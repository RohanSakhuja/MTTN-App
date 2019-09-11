import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

class NoirVerification {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _reference = FirebaseDatabase().reference();
  String _verificationId;
  String smsCode;
  String phoneNumber;

  GlobalKey<ScaffoldState> key;

  NoirVerification(this.key);

  Future<String> currentUser() async {
    FirebaseUser user = await _auth.currentUser();
    String temp = user != null ? user.phoneNumber : "No number";
    print("temp:"+temp);
    return temp;
  }

  void setup(phone) {
    phoneNumber = phone;
    _verifyPhoneNumber();
  }

  void signOut() async {
    if (_auth.currentUser() != null) {
      await _auth.signOut();
      print(currentUser());
      showSnackbar("Successfully Signed out");
    }
  }

  void _verifyPhoneNumber() async {
    var temp = await _reference.child("NOIR").child(phoneNumber).once();
    if (temp.value != null) {
      bool verified = await _processNumber();
      print(verified);
    } else {
      print("Invalid User");
      showSnackbar('Invalid User');
    }
  }

  // Example code of how to verify phone number
  Future<bool> _processNumber() async {
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);

      String message = 'Received phone auth credential: $phoneAuthCredential';
      showSnackbar(message);

      return true;
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      String message =
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      showSnackbar(message);
      return false;
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

  void _signInWithPhoneNumber() async {
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
      content: Text(message),
    ));
  }
}
