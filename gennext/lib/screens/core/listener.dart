import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gennext/services/firebase_service.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/gradientbtn.dart';
import 'package:gennext/widgets/message_box.dart';
import 'package:gennext/widgets/message_input_filed.dart';
import 'package:gennext/widgets/navbar.dart';
import 'package:permission_handler/permission_handler.dart';

class ListenerScreen extends StatefulWidget {
  final String? zone;

  const ListenerScreen({super.key, required this.zone});

  @override
  State<ListenerScreen> createState() => _ListenerScreenState();
}

class _ListenerScreenState extends State<ListenerScreen> {
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
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle, color: Colors.black),
          ),
        ],
      ),
      drawer: DrawerSide(),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2 * (1 / 6),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      channelId != null
                          ? 'กำลังฟังห้อง: $channelId'
                          : 'ไม่พบห้องว่าง',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    child: Image.asset('images/qlementine-icons--user-16.png'),
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'คุณ (ผู้ฟัง)',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ข้อความในห้อง (ฟังข้อความแบบ real-time)
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

                  const SizedBox(height: 20),
                  // ปุ่มสุ่มส่งข้อความ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GradientBTN(
                        label: 'สุ่มคำถาม',
                        onPressed: _sendRandomMessage,
                      ),
                      GradientBTN(
                        label: 'ให้กำลังใจ',
                        onPressed: () {
                          // ฟังก์ชันยังไม่กำหนด
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ปุ่มเปลี่ยนห้อง
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GradientBTN(
                        label: 'เปลี่ยนห้อง',
                        onPressed: _changeRoom,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
