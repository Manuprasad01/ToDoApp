import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/core/widgets/custom_button.dart';
import 'package:todo_app/core/widgets/custom_textfield.dart';

import 'package:todo_app/features/pages/home_page.dart';

import '../services/auth.dart';
import 'signup_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final Auth _auth = Auth();

  final formkey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
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
              child: Image.asset(
                'assets/mimo.png',
                width: 210,
              ),
            ),
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
              height: 10,
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: CustomTextField(
                  hintText: 'password',
                  controller: passwordcontroller,
                  obscureText: true,
                  // isPassword: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                      onPressed: () {}, child: Text("Forgot Password?"))),
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(text: 'CONTINUE', onPressed: signIn),
            // SizedBox(
            //   width: 200,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //         backgroundColor: Theme.of(context).colorScheme.tertiary),
            //     onPressed: () {
            //       signIn();
            //     },
            //     child: Text('Login'),
            //   ),
            // ),
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

  void signIn() async {
    String email = emailcontroller.text;
    String password = passwordcontroller.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      print('user is successfully signed in');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CategoriesPage()));
    } else {
      print("Some error occured");
    }
  }
}
