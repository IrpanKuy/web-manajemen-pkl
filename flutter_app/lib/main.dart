import 'package:flutter/material.dart';
import 'package:flutter_app/ui/auth/login.dart';
import 'package:flutter_app/ui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/home',

      routes: {
        '/login': (context) => const Login(),
        '/home': (context) => const HomePage(),
      },
      // home: Login(),
    );
  }
}
