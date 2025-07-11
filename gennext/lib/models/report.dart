import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> reportUserOrRoom({
  required String reporterId,
  required String type, // 'user' or 'room'
  required String targetId,
  required String reason,
}) async {
  final reportDoc = FirebaseFirestore.instance.collection('reports').doc();

  await reportDoc.set({
    'reporterId': reporterId,
    'type': type,
    'targetId': targetId,
    'reason': reason,
    'status': 'pending',
    'reportedAt': FieldValue.serverTimestamp(),
  });
}
