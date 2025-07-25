import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gennext/screens/core/newlisten.dart';
import 'package:gennext/screens/core/speaker.dart';
import 'package:gennext/screens/setting/profile_config.dart';
import 'package:gennext/services/firebase_service.dart';
import 'package:gennext/services/user_provider.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/navbar.dart';
import 'package:gennext/widgets/rounded_inputfield.dart';
import 'package:provider/provider.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final RoomController = TextEditingController();

  @override
  void dispose() {
    RoomController.dispose();

    super.dispose();
  }

  Future<void> _searchRoom() async {
    final roomID = RoomController.text.trim();
    final userData = Provider.of<UserProvider>(context, listen: false).userData;
    final FireStoreServices fs = FireStoreServices();

    try {
      final doc = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomID)
          .get();
      print("DOC : " + doc.toString());
      if (doc.exists) {
        // พบห้อง
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewListenerScreen(zone: 'ภาคกลาง'),
          ),
        );
      } else {
        // ไม่พบห้อง
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ไม่พบห้อง'),
            content: const Text('กรุณาตรวจสอบชื่อห้องอีกครั้ง'),
            actions: [
              TextButton(
                child: const Text('ตกลง'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(242, 242, 242, 1),
      body: Stack(
        children: [
          // พื้นหลังส่วนหัว
          Container(
            height: 226,
            decoration: BoxDecoration(
              color: Color.fromRGBO(210, 118, 71, 1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
          ),

          // เนื้อหาภายใน SafeArea
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // คำทักทาย
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi Username",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "How are you today?",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),

                      // ไอคอนโปรไฟล์
                      Icon(
                        Icons.account_circle_outlined,
                        size: 72,
                        color: Colors.white,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // ช่องค้นหา
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: RoomController,
                            textInputAction: TextInputAction
                                .search, // เปลี่ยนปุ่มเป็น "ค้นหา"
                            onSubmitted: (value) {
                              _searchRoom(); // เรียกฟังก์ชันค้นหา
                            },
                            decoration: InputDecoration(
                              hintText: 'Search Room ID',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromRGBO(242, 242, 242, 1),
//       appBar: AppBar(
//         backgroundColor: Color(0xFFF2F2F2),
//         elevation: 0,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: Colors.black),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: GestureDetector(
//               child: Icon(Icons.account_circle, color: Colors.black),
//               onTap: () => {
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (_, __, ___) => ProfileConfig(),
//                     transitionsBuilder: (_, animation, __, child) {
//                       return FadeTransition(opacity: animation, child: child);
//                     },
//                     transitionDuration: const Duration(milliseconds: 400),
//                   ),
//                 ),
//               }, //
//             ),
//           ),
//         ],
//       ),
//       drawer: DrawerSide(),
//       body: SafeArea(
//         child: SafeArea(
//           child: Center(
//             child: Column(
//               children: [
//                 SizedBox(height: 20),
//                 Text(
//                   "Search",
//                   style: TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 SizedBox(
//                   width: 300,
//                   height: 40,
//                   child: RoundedInputfield(
//                     hintText: "รหัสห้อง",
//                     icon: Icons.room_rounded,
//                     controller: RoomController,
//                   ),
//                 ),

//                 SizedBox(height: 20),
//                 SizedBox(
//                   width: 90,
//                   height: 30,
//                   child: ElevatedButton(
//                     onPressed: _searchRoom,
//                     child: Text(
//                       "ค้นหา",
//                       // style: TextStyle(
//                       //   fontSize: 14,
//                       //   fontWeight: FontWeight.bold,
//                       //   color: Colors.black,
//                       // ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavBar(),
//     );
//   }
// }
