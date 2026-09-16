import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AppConfigService {
  static final _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static String _newAppId() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    return 'ARANK-${now.substring(now.length - 8)}';
  }

  static Future<DocumentReference<Map<String, dynamic>>> ensureAppConfig() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Admin session not found');

    final adminRef = _db.collection('admins').doc(user.uid);
    final adminSnap = await adminRef.get();
    final existingAppId = adminSnap.data()?['appId']?.toString();
    if (existingAppId != null && existingAppId.isNotEmpty) {
      return _db.collection('apps').doc(existingAppId);
    }

    final appId = _newAppId();
    final appRef = _db.collection('apps').doc(appId);
    await appRef.set({
      'appId': appId,
      'ownerAdminUid': user.uid,
      'appName': 'ARank India',
      'supportEmail': 'contact@kopersay.in',
      'mobile': '+91 7319796868',
      'logoUrl': '',
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await adminRef.set({
      'adminUid': user.uid,
      'appId': appId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return appRef;
  }

  static Future<String> uploadLogo(String appId, List<int> bytes) async {
    final ref = _storage.ref('app_logos/$appId/logo');
    await ref.putData(bytes as dynamic);
    return ref.getDownloadURL();
  }
}
