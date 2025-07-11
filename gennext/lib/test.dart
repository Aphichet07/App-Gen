import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      body: Column(
        children: [SizedBox(height: MediaQuery.of(context).size.height * 0.5)],
      ),
    );
  }
}
