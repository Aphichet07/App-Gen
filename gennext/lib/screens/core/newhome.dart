import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gennext/screens/core/listener.dart';
import 'package:gennext/screens/core/speaker.dart';
import 'package:gennext/screens/setting/profile_config.dart';
import 'package:gennext/services/firebase_service.dart';
import 'package:gennext/services/user_provider.dart';
import 'package:gennext/widgets/Actionbtn.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/navbar.dart';
import 'package:provider/provider.dart';

class NewHome extends StatefulWidget {
  const NewHome({super.key});

  @override
  State<NewHome> createState() => _NewHomeState();
}

class _NewHomeState extends State<NewHome> with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  final FireStoreServices fs = FireStoreServices();
  bool isCreatingRoom = false;
  int activeRoomsCount = 0;
  int onlineUsersCount = 0;
  String? _selectedZone;

  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUserData();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  Future<void> _initializeFirebase() async {
    try {
      await fs.initializeAuth();
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final roomsQuery = await FirebaseFirestore.instance
          .collection('rooms')
          .where('isActive', isEqualTo: true)
          .get();

      setState(() {
        activeRoomsCount = roomsQuery.docs.length;
        onlineUsersCount = roomsQuery.docs.fold(0, (sum, doc) {
          final data = doc.data();
          final listeners = data['listenerUids'] as List? ?? [];
          return sum + listeners.length + 1;
        });
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _loadStats();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: Colors.black),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: GestureDetector(
                child: Icon(Icons.account_circle, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProfileConfig(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        drawer: DrawerSide(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Text(
                  "WELCOME",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(46, 30, 66, 1),
                  ),
                ),
                Text(
                  "TO JAKJAI",
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(46, 30, 66, 1),
                  ),
                ),
                SizedBox(height: 60.h),
                Image.asset('images/4630062.jpg', width: 325.w, height: 250.h),
                SizedBox(height: 28.h),
                ActionChoice(
                  onZoneSelected: (zone) {
                    setState(() {
                      _selectedZone = zone;
                    });
                  },
                ),
                SizedBox(height: 28.h),
                Column(
                  children: [
                    SizedBox(
                      width: 183.w,
                      height: 55.h,
                      child: ActionBTN(
                        label: 'พูด',
                        onPressed: () async {
                          if (_selectedZone == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('กรุณาเลือกภูมิภาคก่อน')),
                            );
                            return;
                          }
                          final roomId = await fs.createRoom(_selectedZone);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Talker(roomId: roomId),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 17.h),
                    SizedBox(
                      width: 183.w,
                      height: 55.h,
                      child: ActionBTN(
                        label: 'ฟัง',
                        onPressed: () async {
                          if (_selectedZone == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('กรุณาเลือกภูมิภาคก่อน')),
                            );
                            return;
                          }
                          final roomId = await fs.createRoom(_selectedZone);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Talker(roomId: roomId),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }
}

class ActionChoice extends StatefulWidget {
  final Function(String?) onZoneSelected;
  const ActionChoice({super.key, required this.onZoneSelected});

  @override
  State<ActionChoice> createState() => _ActionChoiceState();
}

class _ActionChoiceState extends State<ActionChoice> {
  String? _selectedZone;
  final List<String> zone = ['ภาคกลาง', 'ภาคเหนือ', 'ภาคอิสาน', 'ภาคใต้'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'เลือกภูมิภาค',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10.0),
        Wrap(
          spacing: 17.w,
          children: zone.map((z) {
            return ChoiceChip(
              backgroundColor: Color.fromRGBO(246, 218, 207, 1),
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              label: Text(z),
              selected: _selectedZone == z,
              onSelected: (bool selected) {
                setState(() {
                  _selectedZone = selected ? z : null;
                  widget.onZoneSelected(_selectedZone);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
