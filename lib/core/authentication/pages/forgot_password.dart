import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/core/widgets/custom_button.dart';
import 'package:todo_app/core/widgets/custom_textfield.dart';


import '../services/auth.dart';
import 'signup_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final Auth _auth = Auth();

  final formkey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
 

  @override
  void dispose() {
    emailcontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Form(
        key: formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              'Forgot Password',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            SizedBox(
              height: 30,
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: CustomTextField(
                    hintText: 'email', controller: emailcontroller),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(text: 'CONTINUE', onPressed: reset),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?'),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Signup()));
                    },
                    child: Text('Register')),
              ],
            )
          ],
        ),
      ),
    );
  }

  void reset() async {
    String email = emailcontroller.text;
    try {
      await _auth.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent'),
      ));
    } on FirebaseAuthException catch (e) {
      print('Error occured: $e');
    }
  }
}
