import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FireStoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<String> createRoom(String? zone) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        await _auth.signInAnonymously();
        user = _auth.currentUser!;
      }
      final roomId = const Uuid().v4().substring(0, 6);
      final doc = await _db.collection('rooms').doc(roomId).set({
        'speakerUid': user.uid,
        'speakerName':
            user.displayName ?? 'Anonymous${user.uid.substring(0, 6)}',
        'listenerUids': <String>[],
        'listenerNames': <String>[],
        'micStatus': true,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'maxListeners': 20,
        'zone': zone ?? 'unknown',
        'tag': 'ประจำวัน',
      });

      return roomId;
    } catch (e) {
      print('Error creating room');
      rethrow;
    }
  }

  Future<String?> joinRandomRoom({String? zone}) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        await _auth.signInAnonymously();
        user = _auth.currentUser!;
      }

      Query query = _db
          .collection('rooms')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (zone != null) {
        query = query.where('zone', isEqualTo: zone);
      }

      final roomSelect = await query.get();

      if (roomSelect.docs.isEmpty) return null;

      for (var roomdoc in roomSelect.docs) {
        final roomdata = roomdoc.data() as Map<String, dynamic>;

        final listuserID = List<String>.from(roomdata['listenerUids'] ?? []);
        final maxListener = (roomdata['maxListeners'] ?? 10) as int;

        if (listuserID.length < maxListener && !listuserID.contains(user.uid)) {
          await roomdoc.reference.update({
            'listenerUids': FieldValue.arrayUnion([user.uid]),
            'listenerNames': FieldValue.arrayUnion([
              user.displayName ?? 'Anonymous${user.uid.substring(0, 6)}',
            ]),
          });

          return roomdoc.id;
        }
      }

      return null;
    } catch (e) {
      print("Error joining random room: $e");
      return null;
    }
  }

  Future<void> sendMessage(String roomId, String text) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        await _auth.signInAnonymously();
        user = _auth.currentUser!;
      }

      await _db.collection('rooms').doc(roomId).collection('messages').add({
        'sender': user.displayName ?? 'Anonymous${user.uid.substring(0, 6)}',
        'senderUid': user.uid,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // เปิด/ปิดไมค์
  Future<void> toggleMic(String roomId, bool status) async {
    try {
      await _db.collection('rooms').doc(roomId).update({'micStatus': status});
    } catch (e) {
      print('Error toggling mic: $e');
      rethrow;
    }
  }

  // ฟังข้อความใหม่
  Stream<QuerySnapshot> listenToMessages(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ฟังสถานะห้อง
  Stream<DocumentSnapshot> listenToRoom(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots();
  }

  // ออกจากห้อง
  Future<void> leaveRoom(String roomId) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      final roomDoc = await _db.collection('rooms').doc(roomId).get();
      if (!roomDoc.exists) return;

      final roomData = roomDoc.data()!;
      final speakerUid = roomData['speakerUid'];

      if (speakerUid == user.uid) {
        // ถ้าเป็นคนพูด ให้ปิดห้อง
        await roomDoc.reference.update({'isActive': false});
      } else {
        // ถ้าเป็นคนฟัง ให้เอาออกจากรายชื่อ
        await roomDoc.reference.update({
          'listenerUids': FieldValue.arrayRemove([user.uid]),
          'listenerNames': FieldValue.arrayRemove([
            user.displayName ?? 'Anonymous${user.uid.substring(0, 6)}',
          ]),
        });
      }
    } catch (e) {
      print('Error leaving room: $e');
    }
  }

  // ล้างห้องเก่าที่ไม่ได้ใช้งาน
  Future<void> cleanupOldRooms() async {
    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));

      final oldRooms = await _db
          .collection('rooms')
          .where('createdAt', isLessThan: Timestamp.fromDate(oneHourAgo))
          .get();

      for (var room in oldRooms.docs) {
        await room.reference.update({'isActive': false});
      }
    } catch (e) {
      print('Error cleaning up old rooms: $e');
    }
  }

  // ตรวจสอบสถานะการเชื่อมต่อ
  Future<bool> checkConnection() async {
    try {
      await _db.collection('test').doc('connection').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // เริ่มต้น Firebase Auth
  Future<void> initializeAuth() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } catch (e) {
      print('Error initializing auth: $e');
    }
  }
}
