import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/core/authentication/pages/login_page.dart';
import 'package:todo_app/core/widgets/custom_button.dart';
import 'package:todo_app/core/widgets/custom_textfield.dart';
import '../services/auth.dart';
import '../../services/database_services.dart';
import '../../../features/pages/home_page.dart';
import '../models/signup_model.dart';

// import '../../login/pages/login_page.dart'; // Update with the correct path

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final Auth _auth = Auth();
  final DatabaseService _databaseService = DatabaseService();
  String error = '';

  final formkey = GlobalKey<FormState>();
  final namecontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final c_passwordcontroller = TextEditingController();

  @override
  void dispose() {
    namecontroller.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // appBar: AppBar(
      //   leading: IconButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //       },
      //       icon: Icon(Icons.login)),
      // ),
      body: Form(
        key: formkey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Create an account',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            SizedBox(
              height: 30,
            ),
            Center(
              child: SizedBox(
                  width: 300,
                  child: CustomTextField(
                      hintText: 'Full Name', controller: namecontroller)),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: SizedBox(
                  width: 300,
                  child: CustomTextField(
                      hintText: "Email", controller: emailcontroller)),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: SizedBox(
                  width: 300,
                  child: CustomTextField(
                      hintText: 'Password', controller: passwordcontroller)),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: CustomTextField(
                    hintText: 'Confirm Password',
                    controller: c_passwordcontroller,
                    obscureText: true),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(text: 'CONTINUE', onPressed: signUp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?'),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Text('Login')),
              ],
            )
          ],
        ),
      ),
    );
  }

  void signUp() async {
    String username = namecontroller.text;
    String email = emailcontroller.text;
    String password = passwordcontroller.text;
    String cpass = c_passwordcontroller.text;
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (password != cpass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'passwords are not matching',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      // int newId = await _databaseService.getNextId();
      final signup = SignupModel(
          id: user.uid,

          // id: newId.toString(),
          name: username,
          email: email,
          password: password);
      await _databaseService.addSignUp(signup);
      print('user is successfullly created');
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CategoriesPage()));
    } else {
      print("Some error occured");
    }
  }
}
