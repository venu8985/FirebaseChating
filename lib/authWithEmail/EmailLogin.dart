import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_project/home/home.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final emailAddress = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailAddress,
            ),
            TextField(
              controller: password,
            ),
            ElevatedButton(
                onPressed: () {
                  login();
                },
                child: Text('Next')),
            ElevatedButton(
                onPressed: () {
                  resetPassword(emailAddress.text.toString());
                },
                child: Text('Reset password')),
          ],
        ),
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  void login() async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailAddress.text.toString(),
              password: password.text.toString());
      User? user = credential.user;
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .set({'email': emailAddress.text.toString(), 'uid': user.uid});
      Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  // Future<String?> signInWithEmailPassword(String email, String password) async {
  //   try {
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     User user = userCredential.user!;

  //     if (user.emailVerified) {
  //       Navigator.pushAndRemoveUntil(context,
  //           MaterialPageRoute(builder: (_) => Home()), (route) => false);
  //       return user.uid;
  //     } else {
  //       // Email is not verified
  //       return null;
  //     }
  //   } catch (e) {
  //     // Handle any errors that occur during sign-in
  //     print('Error signing in: $e');
  //     return null;
  //   }
  // }
}
