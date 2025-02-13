import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:provider/provider.dart';
import 'package:todo_app/features/pages/home_page.dart';
import 'package:todo_app/features/controller/user_provider.dart';

import 'base/provider/theme_provider.dart';
import 'features/controller/category_provider.dart';
import 'core/authentication/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('userBox');
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CategoryProvider()),
    ChangeNotifierProvider(create: (context) => UserProvider()),
    ChangeNotifierProvider(create: (context) => ThemeProvider()),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      debugShowCheckedModeBanner: false,

      home: _getInitialPage(),
   
    );
  }
}

Widget _getInitialPage() {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return CategoriesPage();
  } else {
    return Login();
  }
}
