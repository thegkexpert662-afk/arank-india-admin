import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class ContinueLearningScreen extends StatefulWidget {
  const ContinueLearningScreen({super.key});

  @override
  State<ContinueLearningScreen> createState() => _ContinueLearningScreenState();
}

class _ContinueLearningScreenState extends State<ContinueLearningScreen> {
  final _db = FirebaseFirestore.instance;
  bool _busy = false;

  Future<String?> _createSet() async {
    final title = TextEditingController();
    final subject = TextEditingController();
    final description = TextEditingController();
    final order = TextEditingController(text: '0');
    bool active = true;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, dialogSetState) => AlertDialog(
          title: const Text('Create Learning Set'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _field(title, 'Set Title *', hint: 'GK Set 1'),
                  _field(subject, 'Subject *', hint: 'GK / Hindi / Maths / Reasoning / Current Affairs'),
                  _field(description, 'Description', maxLines: 2),
                  _field(order, 'Sort Order', keyboard: TextInputType.number),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active'),
                    value: active,
                    onChanged: (value) => dialogSetState(() => active = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final titleValue = title.text.trim();
                final subjectValue = subject.text.trim();
                if (titleValue.isEmpty || subjectValue.isEmpty) return;

                Navigator.of(dialogContext).pop({
                  'title': titleValue,
                  'subject': subjectValue,
                  'description': description.text.trim(),
                  'sortOrder': int.tryParse(order.text.trim()) ?? 0,
                  'isActive': active,
                });
              },
              child: const Text('Create & Upload Excel'),
            ),
          ],
        ),
      ),
    );

    title.dispose();
    subject.dispose();
    description.dispose();
    order.dispose();

    if (result == null || !mounted) return null;

    // Let the dialog route finish its removal before changing the Firestore
    // stream. This avoids Flutter's dependents.isEmpty assertion on some
    // Flutter versions/platforms.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return null;

    final ref = await _db.collection('continue_learning').add({
      ...result,
      'questionCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> _uploadExcel(String setId) async {
    if (_busy) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty || result.files.first.bytes == null) return;

      if (mounted) setState(() => _busy = true);

      final decoder = SpreadsheetDecoder.decodeBytes(result.files.first.bytes!, update: false);
      if (decoder.tables.isEmpty) throw Exception('No worksheet found.');

      final sheet = decoder.tables.values.first;
      final rows = sheet.rows;
      if (rows.length <= 1) throw Exception('Excel file has no questions.');

      final collection = _db.collection('continue_learning').doc(setId).collection('questions');
      int uploaded = 0;
      WriteBatch batch = _db.batch();
      int batchCount = 0;

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        String cell(int index) => index < row.length ? '${row[index] ?? ''}'.trim() : '';
        final question = cell(0);
        if (question.isEmpty) continue;

        final doc = collection.doc();
        batch.set(doc, {
          'questionNo': uploaded + 1,
          'question': question,
          'optionA': cell(1),
          'optionB': cell(2),
          'optionC': cell(3),
          'optionD': cell(4),
          'correctAnswer': cell(5),
          'explanation': cell(6),
          'difficulty': cell(7),
          'marks': double.tryParse(cell(8)) ?? 1,
          'negativeMarks': double.tryParse(cell(9)) ?? 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        uploaded++;
        batchCount++;
        if (batchCount == 450) {
          await batch.commit();
          batch = _db.batch();
          batchCount = 0;
        }
      }

      if (batchCount > 0) await batch.commit();

      await _db.collection('continue_learning').doc(setId).set({
        'questionCount': uploaded,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$uploaded questions uploaded successfully.'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteSet(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete learning set?'),
        content: const Text('The set will be removed. Questions in its subcollection should also be cleaned up.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await _db.collection('continue_learning').doc(id).delete();
  }

  Widget _field(TextEditingController controller, String label, {String? hint, int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      ),
    );
  }

  Future<void> _showEditSet(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final d = doc.data() ?? {};
    final title = TextEditingController(text: '${d['title'] ?? ''}');
    final subject = TextEditingController(text: '${d['subject'] ?? ''}');
    final description = TextEditingController(text: '${d['description'] ?? ''}');
    final order = TextEditingController(text: '${d['sortOrder'] ?? 0}');

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Learning Set'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(children: [
              _field(title, 'Set Title *'),
              _field(subject, 'Subject *'),
              _field(description, 'Description', maxLines: 2),
              _field(order, 'Sort Order', keyboard: TextInputType.number),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (title.text.trim().isEmpty || subject.text.trim().isEmpty) return;
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _db.collection('continue_learning').doc(doc.id).update({
        'title': title.text.trim(),
        'subject': subject.text.trim(),
        'description': description.text.trim(),
        'sortOrder': int.tryParse(order.text.trim()) ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    title.dispose();
    subject.dispose();
    description.dispose();
    order.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Continue Learning Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : () async {
          final id = await _createSet();
          if (id != null && mounted) await _uploadExcel(id);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Learning Set'),
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.collection('continue_learning').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

                final docs = [...(snapshot.data?.docs ?? [])];
                docs.sort((a, b) => ((a.data()['sortOrder'] as num?) ?? 0).compareTo((b.data()['sortOrder'] as num?) ?? 0));
                if (docs.isEmpty) return const Center(child: Text('No learning sets. Tap + Add Learning Set.'));

                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const Text('Subject-wise Learning', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Create a set and upload 100–150 questions from Excel. You can upload or replace questions any time.'),
                    const SizedBox(height: 18),
                    ...docs.map((doc) => _setCard(doc)),
                  ],
                );
              },
            ),
    );
  }

  Widget _setCard(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final subject = '${d['subject'] ?? ''}';
    final title = '${d['title'] ?? 'Untitled Set'}';
    final count = (d['questionCount'] as num?)?.toInt() ?? 0;
    final active = d['isActive'] != false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(child: Icon(_subjectIcon(subject))),
          title: Text('$subject  •  $title', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('$count Questions${d['description'] == null || '${d['description']}'.isEmpty ? '' : '  •  ${d['description']}'}'),
          trailing: Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Switch(value: active, onChanged: _busy ? null : (v) => _db.collection('continue_learning').doc(doc.id).update({'isActive': v})),
              IconButton(tooltip: 'Edit Set', icon: const Icon(Icons.edit), onPressed: _busy ? null : () => _showEditSet(doc)),
              FilledButton.icon(
                onPressed: _busy ? null : () => _uploadExcel(doc.id),
                icon: const Icon(Icons.upload_file, size: 19),
                label: const Text('Upload Excel'),
              ),
              IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete, color: Colors.red), onPressed: _busy ? null : () => _deleteSet(doc.id)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _subjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('math')) return Icons.calculate_rounded;
    if (s.contains('reason')) return Icons.psychology_rounded;
    if (s.contains('hindi')) return Icons.translate_rounded;
    if (s.contains('current')) return Icons.newspaper_rounded;
    return Icons.menu_book_rounded;
  }
}
