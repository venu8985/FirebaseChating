import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:test_project/home/home.dart';

class OTP extends StatefulWidget {
  final String verificationId;
  final String phone;

  OTP({super.key, required this.verificationId, required this.phone});

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  bool isLoading = false;
  TextEditingController otpVerify = TextEditingController();
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
              title: Text("Otp verifying"),
            ),
            body: Center(
                child: Column(
              children: [
                TextField(
                  controller: otpVerify,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: "enter otp number"),
                ),
                ElevatedButton(
                    onPressed: () {
                      signup();
                    },
                    child: Text("verify otp"))
              ],
            )),
          );
  }

  void signup() async {
    setState(() {
      isLoading = true;
    });
    String phone = "+91" + '${widget.phone}';

    String otp = otpVerify.text.trim();

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otp,
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => Home()),
        );
      }
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    setState(() {
      isLoading = false;
    });
  }
}
