import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _sortOrder = TextEditingController(text: '0');
  String _icon = 'emoji_events';
  bool _isActive = true;
  bool _saving = false;

  final icons = const {
    'emoji_events': Icons.emoji_events,
    'local_fire_department': Icons.local_fire_department,
    'workspace_premium': Icons.workspace_premium,
    'military_tech': Icons.military_tech,
    'star': Icons.star,
    'school': Icons.school,
    'quiz': Icons.quiz,
    'bolt': Icons.bolt,
    'trending_up': Icons.trending_up,
  };

  Future<void> _save() async {
    final title = _title.text.trim();
    final description = _description.text.trim();
    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and description are required.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('achievements').add({
        'title': title,
        'description': description,
        'icon': _icon,
        'iconColor': Colors.amber.value,
        'sortOrder': int.tryParse(_sortOrder.text.trim()) ?? 0,
        'isActive': _isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _title.clear();
      _description.clear();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showAdd() async {
    _title.clear();
    _description.clear();
    _sortOrder.text = '0';
    _icon = 'emoji_events';
    _isActive = true;
    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Add Achievement'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Achievement Name')),
          TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _sortOrder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sort Order')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: _icon, decoration: const InputDecoration(labelText: 'Icon'), items: icons.entries.map((e) => DropdownMenuItem(value: e.key, child: Row(children: [Icon(e.value), const SizedBox(width: 8), Text(e.key)]))).toList(), onChanged: (v) => setDialogState(() => _icon = v ?? _icon)),
          SwitchListTile(title: const Text('Active'), value: _isActive, onChanged: (v) => setDialogState(() => _isActive = v)),
        ])),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), ElevatedButton(onPressed: _saving ? null : () { Navigator.pop(dialogContext); _save(); }, child: const Text('Save'))],
      )),
    );
  }

  Future<void> _delete(String id) async {
    await FirebaseFirestore.instance.collection('achievements').doc(id).delete();
  }

  Future<void> _toggle(String id, bool value) async {
    await FirebaseFirestore.instance.collection('achievements').doc(id).update({'isActive': value, 'updatedAt': FieldValue.serverTimestamp()});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Achievements Management')),
    floatingActionButton: FloatingActionButton.extended(onPressed: _showAdd, icon: const Icon(Icons.add), label: const Text('Add')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('achievements').orderBy('sortOrder').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Unable to load achievements.\n${snapshot.error}', textAlign: TextAlign.center));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No achievements. Tap Add to create one.'));
        return ListView.builder(itemCount: docs.length, itemBuilder: (_, i) {
          final d = docs[i]; final data = d.data(); final icon = icons[data['icon']] ?? Icons.emoji_events; final active = data['isActive'] != false;
          return Card(margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text('${data['title'] ?? ''}'), subtitle: Text('${data['description'] ?? ''}\nSort: ${data['sortOrder'] ?? 0}'), isThreeLine: true, trailing: Row(mainAxisSize: MainAxisSize.min, children: [Switch(value: active, onChanged: (v) => _toggle(d.id, v)), IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(d.id))])));
        });
      },
    ),
  );

  @override
  void dispose() { _title.dispose(); _description.dispose(); _sortOrder.dispose(); super.dispose(); }
}
