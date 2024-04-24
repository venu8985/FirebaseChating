import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_project/authWithEmail/EmailLogin.dart';
import 'package:test_project/home/home.dart';

class EmailSignup extends StatefulWidget {
  const EmailSignup({super.key});

  @override
  State<EmailSignup> createState() => _EmailSignupState();
}

class _EmailSignupState extends State<EmailSignup> {
  final emailAddress = TextEditingController();
  final password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignUp'),
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
                  signUp('venu', emailAddress.text, password.text);
                },
                child: Text('next')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => EmailLogin()));
                },
                child: Text('login'))
          ],
        ),
      ),
    );
  }

  Future<String?> signUp(String username, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User user = userCredential.user!;
      Navigator.push(context, MaterialPageRoute(builder: (_) => EmailLogin()));
      // Send email verification
      await user.sendEmailVerification();
      if (user.emailVerified) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => EmailLogin()));
        return user.uid;
      }
      return null;
    } catch (e) {
      print("An error occurred while trying to sign up:");
      print(e.toString());
      return null;
    }
  }
  // void signUp() async {
  //   try {
  //     final credential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: emailAddress.text.toString(),
  //       password: password.text.toString(),
  //     );
  //     Navigator.push(context, MaterialPageRoute(builder: (_) => EmailLogin()));
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'weak-password') {
  //       print('The password provided is too weak.');
  //     } else if (e.code == 'email-already-in-use') {
  //       print('The account already exists for that email.');
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<String?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User user = userCredential.user!;

      if (user.emailVerified) {
        return user.uid;
      } else {
        // Email is not verified
        return null;
      }
    } catch (e) {
      // Handle any errors that occur during sign-in
      print('Error signing in: $e');
      return null;
    }
  }
}
