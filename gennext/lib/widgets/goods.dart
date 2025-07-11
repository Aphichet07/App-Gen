import 'package:flutter/material.dart';

class Goods extends StatelessWidget {
  const Goods({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 130,
      color: Colors.amber,
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 8),
            Image.asset('images/new_Logo_NoBG.png', width: 100, height: 50),
            SizedBox(height: 3),
            Text(
              "Flower",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 3),
            Text(
              "39 บาท",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
