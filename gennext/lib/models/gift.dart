import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendGift({
  required String senderId,
  required String receiverId,
  required String giftType, // เช่น 'flower', 'heart'
  required String roomId,
}) async {
  final giftDoc = FirebaseFirestore.instance.collection('gifts').doc();

  await giftDoc.set({
    'senderId': senderId,
    'receiverId': receiverId,
    'giftType': giftType,
    'roomId': roomId,
    'sentAt': FieldValue.serverTimestamp(),
  });
}
