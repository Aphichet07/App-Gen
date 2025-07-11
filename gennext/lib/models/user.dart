import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createUser({
  required String uid,
  required String name,
  required String role, // 'speaker' or 'listener'
  required int age,
  required String region,
}) async {
  final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

  await userDoc.set({
    'name': name,
    'role': role,
    'age': age,
    'region': region,
    'reputation': 0,
    'createdAt': FieldValue.serverTimestamp(),
  });
}
