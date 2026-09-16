import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VideoSolutionsScreen extends StatefulWidget {
  const VideoSolutionsScreen({super.key});

  @override
  State<VideoSolutionsScreen> createState() => _VideoSolutionsScreenState();
}

class _VideoSolutionsScreenState extends State<VideoSolutionsScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _instituteId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInstitute();
  }

  Future<void> _loadInstitute() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await _db.collection('admins').doc(uid).get();
      final data = doc.data();
      _instituteId = '${data?['instituteId'] ?? data?['appId'] ?? ''}';
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _addOrEdit({DocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final data = doc?.data() ?? <String, dynamic>{};
    final title = TextEditingController(text: '${data['title'] ?? ''}');
    final subject = TextEditingController(text: '${data['subject'] ?? ''}');
    final url = TextEditingController(text: '${data['videoUrl'] ?? ''}');
    final description = TextEditingController(text: '${data['description'] ?? ''}');
    final form = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(doc == null ? 'Add Video Solution' : 'Edit Video Solution'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Video Title'),
                    validator: (value) => value!.trim().isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'Subject / Topic'),
                  ),
                  TextFormField(
                    controller: url,
                    decoration: const InputDecoration(labelText: 'Video URL'),
                    validator: (value) => value!.trim().isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true || _instituteId == null || _instituteId!.isEmpty) {
      title.dispose();
      subject.dispose();
      url.dispose();
      description.dispose();
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final ref = doc?.reference ?? _db.collection('video_solutions').doc();

    await ref.set(
      {
        'title': title.text.trim(),
        'subject': subject.text.trim(),
        'videoUrl': url.text.trim(),
        'description': description.text.trim(),
        'instituteId': _instituteId,
        'adminUid': uid,
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
        if (doc == null) 'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    title.dispose();
    subject.dispose();
    url.dispose();
    description.dispose();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video solution saved.')),
      );
    }
  }

  Future<void> _delete(DocumentSnapshot<Map<String, dynamic>> doc) async {
    await doc.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Solutions'),
        backgroundColor: const Color(0xff3730A3),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Add Video'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_instituteId == null || _instituteId!.isEmpty) {
      return const Center(child: Text('Institute ID is not available.'));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _db
          .collection('video_solutions')
          .where('instituteId', isEqualTo: _instituteId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Unable to load videos: ${snap.error}'));
        }

        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        if (docs.isEmpty) {
          return const Center(
            child: Text('No video solutions yet. Add your first solution.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.play_circle_fill_rounded),
                ),
                title: Text(
                  '${data['title'] ?? 'Untitled'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${data['subject'] ?? ''}\n${data['videoUrl'] ?? ''}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _addOrEdit(doc: doc),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => _delete(doc),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
