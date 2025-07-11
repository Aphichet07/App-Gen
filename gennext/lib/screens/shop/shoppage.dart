import 'package:flutter/material.dart';
import 'package:gennext/screens/setting/profile_config.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/goods.dart';
import 'package:gennext/widgets/navbar.dart';

class Shop extends StatelessWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      appBar: AppBar(
        backgroundColor: Color(0xFFF2F2F2),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: GestureDetector(
              child: Icon(Icons.account_circle, color: Colors.black),
              onTap: () => {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ProfileConfig(),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                ),
              }, //
            ),
          ),
        ],
      ),
      drawer: DrawerSide(),
      body: SafeArea(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Shop",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 60),
                Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.only(left: 40),
                          child: Goods(),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.only(left: 40),
                          child: Goods(),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsetsGeometry.only(left: 40),
                          child: Goods(),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.only(left: 40),
                          child: Goods(),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => {},
                    child: Text(
                      "จ่ายเงิน",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
