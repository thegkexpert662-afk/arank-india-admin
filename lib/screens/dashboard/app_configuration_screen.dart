import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/app_config_service.dart';

class AppConfigurationScreen extends StatefulWidget {
  const AppConfigurationScreen({super.key});

  @override
  State<AppConfigurationScreen> createState() => _AppConfigurationScreenState();
}

class _AppConfigurationScreenState extends State<AppConfigurationScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _logoUrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String _appId = '';
  DocumentReference<Map<String, dynamic>>? _appRef;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ref = await AppConfigService.ensureAppConfig();
      final snap = await ref.get();
      final data = snap.data() ?? {};
      _appRef = ref;
      _appId = ref.id;
      _name.text = '${data['appName'] ?? 'ARank India'}';
      _email.text = '${data['supportEmail'] ?? ''}';
      _mobile.text = '${data['mobile'] ?? ''}';
      _logoUrl.text = '${data['logoUrl'] ?? ''}';
    } catch (e) {
      if (mounted) _show('Unable to load app configuration: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final ref = _appRef;
    if (ref == null) return;
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _mobile.text.trim().isEmpty) {
      _show('App name, support email and mobile are required.');
      return;
    }
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      await ref.set({
        'appId': _appId,
        'ownerAdminUid': uid,
        'appName': _name.text.trim(),
        'supportEmail': _email.text.trim(),
        'mobile': _mobile.text.trim(),
        'logoUrl': _logoUrl.text.trim(),
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _show('App configuration saved.');
    } catch (e) {
      _show('Save failed: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _mobile.dispose();
    _logoUrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Student App / App Configuration'),
        backgroundColor: const Color(0xff3730A3),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Student App Configuration', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          const Text('This configuration is owned by the signed-in admin. Other admins cannot use this App ID.', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: .08), borderRadius: BorderRadius.circular(12)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('Generated Unique App ID', style: TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              SelectableText(_appId, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              const Text('Students configure this ID once. The app remembers it locally.', style: TextStyle(color: Colors.grey)),
                            ]),
                          ),
                          const SizedBox(height: 22),
                          TextField(controller: _name, decoration: _dec('App Name', Icons.apps_outlined)),
                          const SizedBox(height: 16),
                          TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: _dec('Support Email', Icons.email_outlined)),
                          const SizedBox(height: 16),
                          TextField(controller: _mobile, keyboardType: TextInputType.phone, decoration: _dec('Mobile', Icons.phone_outlined)),
                          const SizedBox(height: 16),
                          TextField(controller: _logoUrl, decoration: _dec('Logo URL (optional)', Icons.image_outlined)),
                          const SizedBox(height: 8),
                          const Text('Logo upload can be connected to Storage next; this field keeps the configuration ready for a remote logo.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 24),
                          SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
                            label: Text(_saving ? 'Saving...' : 'Save App Configuration'),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
