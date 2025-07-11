// import 'dart:ui';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gennext/screens/core/listener.dart';
// import 'package:gennext/screens/core/speaker.dart';
// import 'package:gennext/services/firebase_service.dart';
// import 'package:gennext/services/user_provider.dart';
// import 'package:gennext/widgets/Actionbtn.dart';
// import 'package:gennext/widgets/drawer.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage>
//     with SingleTickerProviderStateMixin {
//   double _opacity = 0.0;
//   final FireStoreServices fs = FireStoreServices();
//   bool isCreatingRoom = false;
//   int activeRoomsCount = 0;
//   int onlineUsersCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     Provider.of<UserProvider>(context, listen: false).loadUserData();
//     // Fade in

//     Future.delayed(const Duration(milliseconds: 500), () {
//       setState(() {
//         _opacity = 1.0;
//       });
//     });
//   }

//   Future<void> _initializeFirebase() async {
//     try {
//       await fs.initializeAuth();
//     } catch (e) {
//       print('Error initializing Firebase: $e');
//     }
//   }

//   Future<void> _loadStats() async {
//     try {
//       // Load active rooms count
//       final roomsQuery = await FirebaseFirestore.instance
//           .collection('rooms')
//           .where('isActive', isEqualTo: true)
//           .get();

//       setState(() {
//         activeRoomsCount = roomsQuery.docs.length;
//         // Estimate online users (this could be improved with real-time user tracking)
//         onlineUsersCount = roomsQuery.docs.fold(0, (sum, doc) {
//           final data = doc.data();
//           final listeners = data['listenerUids'] as List? ?? [];
//           return sum + listeners.length + 1; // +1 for speaker
//         });
//       });
//     } catch (e) {
//       print('Error loading stats: $e');
//     }
//   }

//   Widget buildStatCard(List<Map<String, String>> items) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 600),
//           curve: Curves.easeInOut,
//           width: 270,
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.white.withOpacity(0.2)),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.transparent,
//                 blurRadius: 6,
//                 offset: Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: items.map((item) {
//               final label = item['label'] ?? '';
//               final value = item['value'] ?? '';
//               return Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Row(
//                   children: [
//                     Text(
//                       '$label: ',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromRGBO(43, 39, 85, 1),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         value,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Color.fromRGBO(43, 39, 85, 1),
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget buildActionButton(String label, VoidCallback onPressed) {
//   //   return ElevatedButton(
//   //     onPressed: onPressed,
//   //     style: ElevatedButton.styleFrom(
//   //       backgroundColor: Color(0xFF1F223C),
//   //       shadowColor: Colors.black45,
//   //       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//   //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//   //     ),
//   //     child: Text(
//   //       label,
//   //       style: TextStyle(
//   //         fontSize: 14,
//   //         fontWeight: FontWeight.bold,
//   //         color: Colors.white,
//   //       ),
//   //     ),
//   //   );
//   // }
//   // Color.fromRGBO(201, 214, 255, 1),
//   // Color.fromRGBO(226, 226, 226, 1)

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       // backgroundColor: Color(0xFFF2F2F2),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: Icon(Icons.menu, color: Colors.black),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: Icon(Icons.account_circle, color: Colors.black),
//           ),
//         ],
//       ),
//       drawer: DrawerSide(),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color.fromRGBO(149, 172, 248, 1),
//               Color.fromRGBO(226, 226, 226, 1), // สีเข้มนิด
//             ],
//           ),
//         ),
//         child: AnimatedOpacity(
//           duration: Duration(milliseconds: 800),
//           opacity: _opacity,
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               child: Column(
//                 children: [
//                   Image.asset(
//                     'images/new_Logo_NoBG.png',
//                     width: 250,
//                     height: 250,
//                   ),
//                   const SizedBox(height: 20),
//                   buildStatCard([
//                     {'label': 'ออนไลน์', 'value': '578'},
//                     {'label': 'คนพูด', 'value': '52'},
//                     {'label': 'คนฟัง', 'value': '526'},
//                   ]),

//                   const SizedBox(height: 40),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ActionBTN(
//                         label: 'พูด',
//                         onPressed: () async {
//                           // สร้างห้องใน Firestore
//                           final roomId = await fs.createRoom();

//                           // ไปยังหน้า Talker พร้อมส่ง roomId
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => Talker(roomId: roomId),
//                             ),
//                           );
//                         },
//                       ),
//                       ActionBTN(
//                         label: 'ฟัง',
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const ListenerScreen(),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




// /*import 'package:flutter/material.dart';
// import 'package:gennext/screens/listener.dart';
// import 'package:gennext/screens/speaker.dart';
// import 'package:gennext/widgets/drawer.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({super.key});

//   @override
//   State<Homepage> createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
//   double _opacity = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     // Fade in
//     Future.delayed(const Duration(milliseconds: 500), () {
//       setState(() {
//         _opacity = 1.0;
//       });
//     });
//   }

//   Widget buildStatCard(String label, String value) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 600),
//       curve: Curves.easeInOut,
//       width: 270,
//       height: 40,
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF1F223C), Color(0xFF2C3053)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 6,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildActionButton(String label, VoidCallback onPressed) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Color(0xFF1F223C),
//         shadowColor: Colors.black45,
//         padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF2F2F2),
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
//             child: Icon(Icons.account_circle, color: Colors.black),
//           ),
//         ],
//       ),
//       drawer: DrawerSide(),
//       body: AnimatedOpacity(
//         duration: Duration(milliseconds: 800),
//         opacity: _opacity,
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             child: Column(
//               children: [
//                 Image.asset('images/new_Logo_NoBG.png', width: 250, height: 250),
//                 const SizedBox(height: 20),
//                 buildStatCard('ออนไลน์', '578'),
//                 buildStatCard('คนพูด', '52'),
//                 buildStatCard('คนฟัง', '526'),
//                 const SizedBox(height: 40),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     buildActionButton('พูด', () {
//                       Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const Talker()));
//                     }),
//                     buildActionButton('ฟัง', () {
//                       Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const ListenerScreen()));
//                     }),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//  */