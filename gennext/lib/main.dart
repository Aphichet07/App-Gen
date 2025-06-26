import 'package:flutter/material.dart';
import 'package:gennext/screens/homepage.dart';
import 'package:gennext/screens/loading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Homepage());
  }
}
