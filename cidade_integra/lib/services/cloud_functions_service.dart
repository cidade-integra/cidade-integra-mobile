import 'package:cloud_firestore/cloud_firestore.dart';

class CloudFunctionsService {
  static Future<void> logAuditEvent({
    required String event,
    Map<String, dynamic>? payload,
    required String uid,
  }) async {
    await FirebaseFirestore.instance.collection('audit_logs').add({
      'event': event,
      'payload': payload ?? {},
      'uid': uid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
