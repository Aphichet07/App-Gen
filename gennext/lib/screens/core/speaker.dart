import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gennext/screens/core/home.dart';
import 'package:gennext/screens/core/homepage.dart';
import 'package:gennext/services/user_provider.dart';
import 'package:gennext/widgets/Actionbtn.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/message_box.dart';
import 'package:gennext/widgets/message_input_filed.dart';
import 'package:gennext/widgets/navbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class Talker extends StatefulWidget {
  final String roomId;
  const Talker({super.key, required this.roomId});

  @override
  State<Talker> createState() => _TalkerState();
}

class _TalkerState extends State<Talker> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool isMuted = false;
  bool isSpeakerOn = true;

  final String appId =
      'dfc291800cbf49b7952b136b8bbd55a3'; // ใส่ App ID จาก Agora
  final String token =
      '007eJxTYPh56sWv+7t9jcS+WF2M3+SS9SCK70anTv3m9z8cs0xXfFiswJCSlmxkaWhhYJCclGZimWRuaWqUZGhslmSRlJRiappozPYwPaMhkJHhgJcgAyMUgvhsDFmJ2VmJmQwMAJBhIrM='; // ใส่ Token จาก Agora หรือเว้นว่างถ้าใช้แบบไม่ต้องใช้ token

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream subscription สำหรับฟังข้อความ realtime
  StreamSubscription<QuerySnapshot>? _messageSubscription;

  // เก็บข้อความที่ได้มา (แปลงเป็น Map ง่ายต่อการใช้งาน)
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _initAgora();
    _listenMessages();
  }

  // เริ่มต้น Agora SDK และขออนุญาตไมโครโฟน
  Future<void> _initAgora() async {
    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
    await _engine.enableAudio();

    _setupEventHandlers();

    await _engine.joinChannel(
      token: token,
      channelId: widget.roomId,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  // ตั้ง Event Handler ของ Agora
  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Local user ${connection.localUid} joined channel");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Remote user $remoteUid joined channel");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("Remote user $remoteUid left channel");
              setState(() {
                _remoteUid = null;
              });
            },
      ),
    );
  }

  // ฟังข้อความ realtime จาก Firestore
  void _listenMessages() {
    _messageSubscription = _firestore
        .collection('rooms') // ชื่อ collection จริงต้องตรงกับ Firestore ของคุณ
        .doc(widget.roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          setState(() {
            // แปลง DocumentSnapshot เป็น Map<String, dynamic> เก็บใน list
            messages = snapshot.docs.map((doc) => doc.data()).toList();
          });
        });
  }

  // ส่งข้อความเข้า Firestore
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    await _firestore
        .collection('rooms')
        .doc(widget.roomId)
        .collection('messages')
        .add({
          'sender': 'User', // แนะนำเปลี่ยนเป็นชื่อผู้ใช้จริงถ้ามี
          'text': text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Map<String, dynamic>? userData;
  Future<void> _leaveRoomSilently() async {
    try {
      // ลบข้อความทั้งหมด
      final messagesRef = _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .collection('messages');

      final snapshot = await messagesRef.get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // ปิด Agora
      await _engine.leaveChannel();
      await _engine.release();

      // (ไม่ลบห้อง หากไม่มั่นใจว่าเป็นคนสุดท้ายในห้อง)
    } catch (e) {
      debugPrint('Error during silent leave: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserProvider>(context, listen: false).userData;
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _leaveRoomSilently(); // ปิดห้องเมื่อออกหน้า

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;
    return WillPopScope(
      onWillPop: () async {
        await _leaveRoomSilently();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(242, 242, 242, 1),
        appBar: AppBar(
          title: Column(
            children: [
              Center(
                child: Align(
                  alignment: Alignment.center,
                  child: const Text(
                    '  ชื่อห้อง   ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ), // ชื่อห้อง

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
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2 * (1 / 20),
              ),

              // ชื่อห้อง
              // Align(
              //   alignment: Alignment.center,
              //   child: const Text(
              //     'ชื่อห้อง',
              //     style: TextStyle(
              //       fontWeight: FontWeight.bold,
              //       fontSize: 36,
              //       color: Colors.black,
              //     ),
              //   ),
              // ),
              // Text(widget.roomId, style: TextStyle(fontSize: 20)),
              const SizedBox(height: 10),

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
                  userData != null ? userData['username'] ?? 'Guest' : 'Guest',
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Room ID : ${widget.roomId}",
                style: TextStyle(fontSize: 20),
              ),

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
                  child: messages.isEmpty
                      ? const Center(child: Text('ไม่มีข้อความ'))
                      : ListView.builder(
                          reverse: true, // ให้ข้อความใหม่ขึ้นบน
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final data = messages[index];
                            return MessageBox(
                              user: data['sender'] ?? 'ไม่ทราบชื่อ',
                              message: data['text'] ?? '',
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // Input field สำหรับพิมพ์ข้อความและส่ง (ต้องแก้ MessageInputField ให้รับ onSend)
              MessageInputField(
                roomId: widget.roomId,
                onSend: _sendMessage, // ส่งข้อความผ่าน callback
              ),

              const SizedBox(height: 20),

              // ปุ่มเปิด/ปิดไมค์ และ เปิด/ปิดลำโพง
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: IconButton(
                      icon: Icon(
                        isMuted ? Icons.mic_off : Icons.mic,
                        color: isMuted ? Colors.red : Colors.green,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          isMuted = !isMuted;
                        });
                        _engine.muteLocalAudioStream(isMuted);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: IconButton(
                      icon: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.hearing,
                        color: isSpeakerOn ? Colors.blue : Colors.grey,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          isSpeakerOn = !isSpeakerOn;
                        });
                        _engine.setEnableSpeakerphone(isSpeakerOn);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: ActionBTN(
                  label: 'ออกจากห้อง',
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
                                if (!mounted) return;

                                Navigator.of(context).pop();

                                try {
                                  _leaveRoomAndNavigate();
                                } catch (e) {
                                  debugPrint('Error leaving room: $e');
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomNavBar(),
      ),
    );
  }

  Future<void> _leaveRoomAndNavigate() async {
    if (!mounted) return;

    try {
      final messagesRef = _firestore
          .collection('rooms')
          .doc(widget.roomId)
          .collection('messages');

      final snapshot = await messagesRef.get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('rooms').doc(widget.roomId).delete();
      await _engine.leaveChannel();
      await _engine.release();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const Home(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error leaving room: $e');
    }
  }
}
