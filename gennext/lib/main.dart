import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gennext/screens/blog/blog.dart';
import 'package:gennext/screens/core/newhome.dart';
import 'package:gennext/screens/core/newlisten.dart';
import 'package:gennext/screens/core/newspeaker.dart';
import 'package:gennext/screens/setting/search.dart';
import 'package:gennext/screens/setting/splashpage.dart';
import 'package:gennext/services/user_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: Blogpage()),
    );
  }
}
