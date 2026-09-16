import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      final uid = _auth.currentUser?.uid;
      if (uid == null) return 'Unable to identify this account.';

      final global = await _db.collection('service_controls').doc('global').get();
      if (global.exists && global.data()?['adminPanel'] == false) {
        await _auth.signOut();
        return 'Admin Panel is currently disabled by Master Admin.';
      }

      final admin = await _db.collection('admins').doc(uid).get();
      if (admin.exists) {
        final data = admin.data() ?? {};
        if (data['isActive'] == false) { await _auth.signOut(); return 'Your Admin account has been disabled by Master Admin.'; }
        final appId = (data['instituteId'] ?? data['appId'] ?? '').toString();
        if (appId.isNotEmpty) {
          final app = await _db.collection('apps').doc(appId).get();
          if (app.exists && app.data()?['isActive'] == false) { await _auth.signOut(); return 'Your Institute is currently disabled by Master Admin.'; }
        }
        final adminServices = await _db.collection('admin_service_controls').doc(uid).get();
        final controls = adminServices.data() ?? {};
        if (controls['adminPanel'] == false) { await _auth.signOut(); return 'Admin Panel access is disabled for this Admin by Master Admin.'; }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential': case 'wrong-password': case 'user-not-found': return 'Email or password is incorrect.';
        case 'user-disabled': return 'This account has been disabled.';
        default: return e.message ?? 'Login failed.';
      }
    } catch (e) { return 'Unable to verify Admin access. Please try again.'; }
  }
}
