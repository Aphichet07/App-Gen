import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gennext/screens/core/newhome.dart';
import 'package:gennext/services/firebase_service.dart';
import 'package:gennext/widgets/Actionbtn.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/gradientbtn.dart';
import 'package:gennext/widgets/message_box.dart';
import 'package:gennext/widgets/message_input_filed.dart';
import 'package:gennext/widgets/navbar.dart';
import 'package:permission_handler/permission_handler.dart';

class NewListenerScreen extends StatefulWidget {
  final String? zone;

  const NewListenerScreen({super.key, required this.zone});

  @override
  State<NewListenerScreen> createState() => _NewListenerScreenState();
}

class _NewListenerScreenState extends State<NewListenerScreen> {
  final FireStoreServices _firestoreServices = FireStoreServices();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late RtcEngine _engine;
  final String appId = 'dfc291800cbf49b7952b136b8bbd55a3';
  final String token =
      '007eJxTYPh56sWv+7t9jcS+WF2M3+SS9SCK70anTv3m9z8cs0xXfFiswJCSlmxkaWhhYJCclGZimWRuaWqUZGhslmSRlJRiappozPYwPaMhkJHhgJcgAyMUgvhsDFmJ2VmJmQwMAJBhIrM=';

  String? channelId;
  bool isLoading = true;

  final List<String> randomQuestions = [
    'วันนี้รู้สึกยังไงบ้าง?',
    'มีอะไรอยากเล่าไหม?',
    'มีเรื่องอะไรทำให้ยิ้มได้บ้างวันนี้?',
    'เคยรู้สึกโดดเดี่ยวไหม?',
    'สิ่งที่คุณหวังตอนนี้คืออะไร?',
    'อยากบอกอะไรกับใครสักคนไหม?',
  ];

  @override
  void initState() {
    super.initState();
    _initAndJoinRandomRoom();
  }

  Future<void> _showNoRoomDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ไม่พบห้อง'),
        content: const Text('ขออภัย ไม่มีห้องว่างให้เข้าฟังในขณะนี้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> _initAndJoinRandomRoom() async {
    print("Start joining room...");
    print("Agora config:");
    print("AppId: $appId");
    print("Token: $token");

    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    await _engine.enableAudio();
    await _engine.muteLocalAudioStream(false); // ไม่ต้อง mute local audio

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Joined channel: ${connection.channelId}');
          _engine.setEnableSpeakerphone(true);
        },
      ),
    );
    print("000000000000000000000000000000000000000000000000000");
    String? randomRoomId = await _firestoreServices.joinRandomRoom(
      zone: widget.zone,
    );

    print("ROOM ID: $randomRoomId");

    if (randomRoomId == null) {
      print("NO ROOM FOUND");
      setState(() {
        isLoading = false;
      });
      await _showNoRoomDialog();
      return;
    }

    await _engine.joinChannel(
      token: token,
      channelId: randomRoomId,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
      ),
    );

    setState(() {
      channelId = randomRoomId;
      isLoading = false;
    });

    print("JOINED ROOM SUCCESSFULLY");
  }

  Future<void> _changeRoom() async {
    if (channelId != null) {
      await _engine.leaveChannel();
      await _firestoreServices.leaveRoom(channelId!);
    }
    _initAndJoinRandomRoom();
  }

  Future<void> WhoSpeaker() async {
    ;
  }

  Future<void> _sendRandomMessage() async {
    if (channelId == null) return;

    final rand = Random();
    final msg = randomQuestions[rand.nextInt(randomQuestions.length)];

    await _firestoreServices.sendMessage(channelId!, msg);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || channelId == null) return;

    await _firestore
        .collection('rooms')
        .doc(channelId!)
        .collection('messages')
        .add({
          'sender': 'User',
          'text': text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  @override
  void dispose() {
    if (channelId != null) {
      _firestoreServices.leaveRoom(channelId!);
    }
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
      appBar: AppBar(
        // ชื่อห้อง
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('ยืนยันการออกจากห้อง'),
                    content: const Text('คุณต้องการจะออกจากห้องใช่ไหม?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('ยกเลิก'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('ใช่'),
                        onPressed: () async {
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
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      drawer: DrawerSide(),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text(
                    "ชื่อห้อง",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Room ID : " + channelId.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 5),

                  Container(
                    width: 80,
                    height: 20,

                    decoration: BoxDecoration(
                      color: Color.fromRGBO(217, 217, 217, 1),
                      borderRadius: BorderRadius.circular(7),
                      border: BoxBorder.all(strokeAlign: 1),
                    ),
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 6),
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.pink, size: 8),
                          Text(
                            "ความสัมพันธ์",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 19),
                  // รูป user icon
                  Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    child: Image.asset('images/qlementine-icons--user-16.png'),
                  ),

                  const SizedBox(height: 10),

                  // ชื่อผู้ใช้
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Guest',
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),

                  const SizedBox(height: 10),

                  // แสดงข้อความ realtime ในกล่อง scroll
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 60),
                    child: Container(
                      width: 300,
                      height: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.brown),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: channelId == null
                          ? const Center(child: Text('ไม่มีข้อความ'))
                          : StreamBuilder<QuerySnapshot>(
                              stream: _firestoreServices.listenToMessages(
                                channelId!,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('เกิดข้อผิดพลาด');
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final docs = snapshot.data!.docs;

                                if (docs.isEmpty) {
                                  return const Center(
                                    child: Text('ไม่มีข้อความ'),
                                  );
                                }

                                return ListView.builder(
                                  reverse: true,
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final data =
                                        docs[docs.length - 1 - index].data()
                                            as Map<String, dynamic>;
                                    return MessageBox(
                                      user: data['sender'] ?? 'ไม่ทราบชื่อ',
                                      message: data['text'] ?? '',
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Input field สำหรับพิมพ์ข้อความและส่ง (ต้องแก้ MessageInputField ให้รับ onSend)
                  MessageInputField(
                    roomId: channelId,
                    onSend: _sendMessage, // ส่งข้อความผ่าน callback
                  ),

                  const SizedBox(height: 51),

                  Row(
                    spacing: 39,
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.only(left: 75),
                        child: Container(
                          width: 120,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(210, 118, 70, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              horizontal: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swipe_left_outlined,
                                  size: 12,
                                  color: Colors.black,
                                ),
                                Text(
                                  "สุ่มคำถาม",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: 120,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(210, 118, 70, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Icon(
                                Icons.monetization_on_outlined,
                                size: 12,
                                color: Colors.black,
                              ),
                              Text(
                                "ให้กำลังใจ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 21),
                  // ปุ่มเปลี่ยนห้อง
                  GestureDetector(
                    onTap: _changeRoom,
                    child: Container(
                      width: 120,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(210, 118, 70, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.autorenew_sharp,
                            size: 12,
                            color: Colors.black,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "เปลี่ยนห้อง",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
