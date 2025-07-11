import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveVoiceMessage({
  required String speakerId,
  required String audioUrl,
  required String topic,
}) async {
  final msgDoc = FirebaseFirestore.instance.collection('voice_messages').doc();

  await msgDoc.set({
    'speakerId': speakerId,
    'audioUrl': audioUrl,
    'topic': topic,
    'playedCount': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
