import 'package:flutter/material.dart';
import 'package:gennext/screens/core/home.dart';
import 'package:gennext/screens/core/listener.dart';
import 'package:gennext/screens/core/newhome.dart';
import 'package:gennext/screens/setting/setting.dart';
import 'package:gennext/screens/shop/shoppage.dart';
import 'package:gennext/screens/core/speaker.dart';
import 'package:gennext/services/firebase_service.dart';
import 'package:gennext/services/user_provider.dart';
import 'package:provider/provider.dart';
import "dart:math";

class DrawerSide extends StatelessWidget {
  const DrawerSide({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;
    final FireStoreServices fs = FireStoreServices();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF221F44), Color(0xFF3A337B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Image.asset(
                        'images/qlementine-icons--user-16.png',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ), // เพิ่มช่องว่างระหว่างรูปกับข้อความ
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // 👈 สำคัญมาก!
                      children: [
                        Text(
                          userData != null
                              ? userData['username'] ?? 'Guest'
                              : 'Guest',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'User ID',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    color: Colors.white54,
                    thickness: 1,
                    height: 10,
                    indent: 0,
                    endIndent: 30, // ให้เส้นไม่ยาวสุดจอ
                  ),
                ),

                Column(
                  children: [
                    //home icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => NewHome(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              'images/heroicons--home-solid.png',
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'โฮม',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    //talker icon
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('ต้องการจะสร้างห้อง'),
                              content: const Text(
                                'คุณต้องการจะสร้างห้องใช่ไหม?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('ยกเลิก'),
                                  onPressed: () {
                                    Navigator.of(context).pop(); // ปิด dialog
                                  },
                                ),
                                TextButton(
                                  child: const Text('ใช่'),
                                  onPressed: () async {
                                    Navigator.of(
                                      context,
                                    ).pop(); // ปิด dialog ก่อน
                                    final List<String> zone = [
                                      'ภาคกลาง',
                                      'ภาคเหนือ',
                                      'ภาคอิสาน',
                                      'ภาคใต้',
                                    ];
                                    final random = Random();
                                    final selectedZone =
                                        zone[random.nextInt(zone.length)];

                                    final roomId = await fs.createRoom(
                                      selectedZone,
                                    );
                                    // ไปยังหน้า Talker พร้อมส่ง roomId
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            Talker(roomId: roomId),
                                        transitionsBuilder:
                                            (_, animation, __, child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                        transitionDuration: const Duration(
                                          milliseconds: 400,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },

                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              'images/iconoir--microphone-solid.png',
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'พูด',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    //listener icon
                    GestureDetector(
                      onTap: () {
                        final List<String> zone = [
                          'ภาคกลาง',
                          'ภาคเหนือ',
                          'ภาคอิสาน',
                          'ภาคใต้',
                        ];
                        final random = Random();
                        final selectedZone = zone[random.nextInt(zone.length)];

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) =>
                                ListenerScreen(zone: selectedZone),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                              'images/uil--assistive-listening-systems.png',
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'ฟัง',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    //listener icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => Shop(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset('images/solar--shop-bold.png'),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'ร้านค้า',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    //listener icon
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => Setting(),
                            transitionsBuilder: (_, animation, __, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 400,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: Image.asset('images/uil--setting.png'),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'ตั้งค่า',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height * 0.5 * (7 / 8),
                    ),

                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              'images/mingcute--question-fill.png',
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'สอบถามเพิ่มเติม',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
