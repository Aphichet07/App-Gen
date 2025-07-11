import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> createRoom({
  required String speakerId,
  required String topic,
}) async {
  final roomDoc = FirebaseFirestore.instance.collection('rooms').doc();

  await roomDoc.set({
    'roomId': roomDoc.id,
    'speakerId': speakerId,
    'topic': topic,
    'status': 'active',
    'listenerIds': [],
    'startedAt': FieldValue.serverTimestamp(),
  });

  return roomDoc.id;
}
