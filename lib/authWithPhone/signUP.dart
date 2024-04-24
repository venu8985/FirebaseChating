import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_project/authWithPhone/otp.dart';
import 'package:test_project/controllers/authController.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  TextEditingController phoneController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text("Otp test"),
            ),
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: "enter mobile number"),
                ),
                ElevatedButton(
                    onPressed: () {
                      sendotp();
                    },
                    child: Text("send otp"))
              ],
            )),
          );
  }

  void sendotp() async {
    setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91" + phoneController.text.trim(),
      codeSent: (verificationId, resendToken) {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTP(
                      verificationId: verificationId,
                      phone: phoneController.text.trim(),
                    ))).then((value) {});
      },
      verificationCompleted: (credential) {},
      verificationFailed: (ex) {
        print(ex.code.toString());
      },
      codeAutoRetrievalTimeout: (verificationId) {},
      timeout: Duration(seconds: 60),
    );
  }
}
