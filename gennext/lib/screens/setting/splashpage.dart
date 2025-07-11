import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gennext/screens/setting/loading.dart';
import 'package:gennext/screens/auth/login.dart';
// import 'package:app/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // รอ 2 วินาทีแล้วไปหน้า HomePage
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Loading();
  }
}
