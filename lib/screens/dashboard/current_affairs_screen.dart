import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CurrentAffairsScreen extends StatefulWidget {
  const CurrentAffairsScreen({super.key});

  @override
  State<CurrentAffairsScreen> createState() => _CurrentAffairsScreenState();
}

class _CurrentAffairsScreenState extends State<CurrentAffairsScreen> {
  final _db = FirebaseFirestore.instance;
  bool _busy = false;

  Future<void> _showEditor({DocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final data = doc?.data() ?? {};
    final title = TextEditingController(text: '${data['title'] ?? ''}');
    final summary = TextEditingController(text: '${data['summary'] ?? ''}');
    final content = TextEditingController(text: '${data['content'] ?? ''}');
    final date = TextEditingController(text: '${data['dateText'] ?? ''}');
    bool active = data['isActive'] != false;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(doc == null ? 'Add Current Affairs' : 'Edit Current Affairs'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _field(title, 'Headline *', hint: 'ISRO launches next-generation communication satellite'),
                  _field(summary, 'Short Summary *', maxLines: 2),
                  _field(
                    content,
                    'Full Content *',
                    maxLines: 10,
                    hint: 'Write each point as a separate paragraph. Leave one blank line between paragraphs.',
                  ),
                  _field(date, 'Date', hint: '16 July 2026'),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show on Student App'),
                    value: active,
                    onChanged: (value) => setDialogState(() => active = value),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty || summary.text.trim().isEmpty || content.text.trim().isEmpty) return;
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() => _busy = true);
      try {
        final payload = <String, dynamic>{
          'title': title.text.trim(),
          'summary': summary.text.trim(),
          'content': content.text.trim(),
          'dateText': date.text.trim(),
          'isActive': active,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (doc == null) {
          payload['createdAt'] = FieldValue.serverTimestamp();
          await _db.collection('current_affairs').add(payload);
        } else {
          await _db.collection('current_affairs').doc(doc.id).update(payload);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current Affairs saved successfully.')),
          );
        }
      } finally {
        if (mounted) setState(() => _busy = false);
      }
    }

    title.dispose();
    summary.dispose();
    content.dispose();
    date.dispose();
  }

  Future<void> _delete(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Current Affairs?'),
        content: const Text('This item will be removed from the student app.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await _db.collection('current_affairs').doc(doc.id).delete();
  }

  Widget _field(TextEditingController controller, String label, {String? hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Affairs Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : () => _showEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add Current Affairs'),
      ),
      body: _busy
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db.collection('current_affairs').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                final docs = [...(snapshot.data?.docs ?? [])];
                docs.sort((a, b) => _time(b).compareTo(_time(a)));
                if (docs.isEmpty) return const Center(child: Text('No Current Affairs yet. Tap + Add Current Affairs.'));

                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    const Text('Current Affairs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text('Manage the headline, summary and paragraph-wise content shown in the student app.'),
                    const SizedBox(height: 18),
                    ...docs.map(_card),
                  ],
                );
              },
            ),
    );
  }

  Widget _card(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final active = d['isActive'] != false;
    final title = '${d['title'] ?? 'Untitled'}';
    final summary = '${d['summary'] ?? ''}';
    final date = '${d['dateText'] ?? ''}';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.newspaper_rounded)),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${date.isEmpty ? '' : '$date  •  '}$summary', maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Switch(value: active, onChanged: _busy ? null : (v) => doc.reference.update({'isActive': v})),
            IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit', onPressed: _busy ? null : () => _showEditor(doc: doc)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Delete', onPressed: _busy ? null : () => _delete(doc)),
          ],
        ),
      ),
    );
  }

  DateTime _time(DocumentSnapshot<Map<String, dynamic>> doc) {
    final value = doc.data()?['createdAt'];
    return value is Timestamp ? value.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
  }
}
