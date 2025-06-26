import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  Widget logoShower() {
    return Scaffold(body: Center(child: Image.asset('images/Logo_NoBG.png')));
  }

  @override
  Widget build(BuildContext context) {
    return logoShower();
  }
}
