import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gennext/screens/core/newhome.dart';
import 'package:gennext/screens/core/homepage.dart';
import 'package:gennext/services/user_provider.dart';
import 'package:gennext/widgets/Actionbtn.dart';
import 'package:gennext/widgets/drawer.dart';
import 'package:gennext/widgets/message_box.dart';
import 'package:gennext/widgets/message_input_filed.dart';
import 'package:gennext/widgets/navbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewTalker extends StatefulWidget {
  final String roomId;
  const NewTalker({super.key, required this.roomId});

  @override
  State<NewTalker> createState() => _NewTalkerState();
}

class _NewTalkerState extends State<NewTalker> {
  late RtcEngine _engine;
  int? _remoteUid;
  bool isMuted = false;
  bool isSpeakerOn = true;
  FlutterSoundRecorder _localRecorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;

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
    _initAgora().then((_) {
      _startRecordingWhileLive();
    });
    _listenMessages();
  }

  // เริ่มต้น Agora SDK และขออนุญาตไมโครโฟน
  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.storage].request();

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

  Future<void> _startRecordingWhileLive() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/live_record_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _localRecorder.openRecorder();
    await _localRecorder.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS, // ใช้ไฟล์ .aac
    );

    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
    });

    debugPrint("🎙 เริ่มอัดเสียงระหว่าง Live ที่ $filePath");
  }

  Future<void> _stopRecording() async {
    await _localRecorder.stopRecorder();
    await _localRecorder.closeRecorder();

    setState(() {
      _isRecording = false;
    });

    debugPrint("หยุดอัดแล้วที่ $_recordedFilePath");
  }

  Future<void> _uploadToFirebase() async {
    if (_recordedFilePath == null) return;

    final file = File(_recordedFilePath!);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('live_recordings')
        .child('${DateTime.now().millisecondsSinceEpoch}.aac');

    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    debugPrint('Upload สำเร็จ: $downloadUrl');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserProvider>(context, listen: false).userData;
  }

  @override
  void dispose() async {
    _messageSubscription?.cancel();
    _leaveRoomSilently(); // ปิดห้องเมื่อออกหน้า
    await _stopRecording();
    await _uploadToFirebase();
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
        ),

        body: SafeArea(
          child: Column(
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
                "Room ID : " + widget.roomId.toString(),
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
                  userData != null ? userData['username'] ?? 'Guest' : 'Guest',
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
                  width: 237,
                  height: 159,
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

              const SizedBox(height: 113),

              // ปุ่มเปิด/ปิดไมค์ และ เปิด/ปิดลำโพง
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ปุ่มไมค์
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMuted = !isMuted;
                      });
                      _engine.muteLocalAudioStream(isMuted);
                    },
                    child: Container(
                      width: 67,
                      height: 67,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(210, 118, 71, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMuted ? Icons.mic_off : Icons.mic,
                        color: Colors.black,
                        size: 45,
                      ),
                    ),
                  ),

                  // ปุ่มลำโพง
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSpeakerOn = !isSpeakerOn;
                      });
                      _engine.setEnableSpeakerphone(isSpeakerOn);
                    },
                    child: Container(
                      width: 67,
                      height: 67,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(210, 118, 71, 1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.hearing,
                        color: Colors.black,
                        size: 45,
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isRecording ? null : _startRecordingWhileLive,
                    child: const Text("เริ่มอัดเสียง"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: !_isRecording ? _uploadToFirebase : null,
                    child: const Text("อัปโหลดเสียง"),
                  ),
                ],
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
      await _stopRecording();

      await _firestore.collection('rooms').doc(widget.roomId).delete();
      await _engine.leaveChannel();
      await _engine.release();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const NewHome(),
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
