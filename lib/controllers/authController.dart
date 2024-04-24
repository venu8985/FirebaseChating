import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthentication {
  String? phoneNumber;

  Future<ConfirmationResult> sendOTP(String phoneNumber) async {
    this.phoneNumber = phoneNumber;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      ConfirmationResult result = await auth.signInWithPhoneNumber(
        '+91$phoneNumber',
      );
      print("OTP Sent to +91 $phoneNumber");
      return result;
    } catch (e) {
      print("Failed to send OTP: $e");
      throw e;
    }
  }

  Future<void> authenticate(
      ConfirmationResult confirmationResult, String otp) async {
    try {
      UserCredential userCredential = await confirmationResult.confirm(otp);
      if (userCredential.additionalUserInfo != null &&
          userCredential.additionalUserInfo!.isNewUser) {
        printMessage("Authentication Successful");
      } else {
        printMessage("User already exists");
      }
    } catch (e) {
      printMessage("Authentication failed: $e");
      throw e;
    }
  }

  void printMessage(String msg) {
    debugPrint(msg);
  }
}
