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
  final _target = TextEditingController(text: '1');

  String _icon = 'emoji_events';
  String _taskType = 'mock_tests_completed';
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

  final taskTypes = const {
    'mock_tests_completed': 'Complete Mock Tests',
    'questions_completed': 'Complete Questions',
    'continue_learning_sets_completed': 'Complete Learning Sets',
    'perfect_score': 'Reach Score %',
  };

  Future<void> _save({String? id}) async {
    final title = _title.text.trim();
    final description = _description.text.trim();
    final target = int.tryParse(_target.text.trim());
    final sortOrder = int.tryParse(_sortOrder.text.trim()) ?? 0;

    if (title.isEmpty || description.isEmpty || target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title, description and a valid target are required.')));
      return;
    }

    setState(() => _saving = true);
    try {
      final data = {
        'title': title,
        'description': description,
        'icon': _icon,
        'iconColor': Colors.amber.value,
        'sortOrder': sortOrder,
        'taskType': _taskType,
        'target': target,
        'isActive': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (id == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('achievements').add(data);
      } else {
        await FirebaseFirestore.instance.collection('achievements').doc(id).update(data);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showForm({DocumentSnapshot<Map<String, dynamic>>? doc}) async {
    final data = doc?.data() ?? {};
    _title.text = (data['title'] ?? '').toString();
    _description.text = (data['description'] ?? '').toString();
    _sortOrder.text = '${data['sortOrder'] ?? 0}';
    _target.text = '${data['target'] ?? 1}';
    _icon = icons.containsKey(data['icon']) ? data['icon'].toString() : 'emoji_events';
    _taskType = taskTypes.containsKey(data['taskType']) ? data['taskType'].toString() : 'mock_tests_completed';
    _isActive = data['isActive'] != false;

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(doc == null ? 'Add Achievement' : 'Edit Achievement'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: _title, decoration: const InputDecoration(labelText: 'Achievement Name')),
                TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _taskType,
                  decoration: const InputDecoration(labelText: 'Unlock Task'),
                  items: taskTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) => setDialogState(() => _taskType = v ?? _taskType),
                ),
                TextField(
                  controller: _target,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: _taskType == 'perfect_score' ? 'Target Percentage (e.g. 90)' : 'Target Count'),
                ),
                TextField(controller: _sortOrder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sort Order')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _icon,
                  decoration: const InputDecoration(labelText: 'Icon'),
                  items: icons.entries.map((e) => DropdownMenuItem(value: e.key, child: Row(children: [Icon(e.value), const SizedBox(width: 8), Text(e.key)]))).toList(),
                  onChanged: (v) => setDialogState(() => _icon = v ?? _icon),
                ),
                SwitchListTile(title: const Text('Active'), value: _isActive, onChanged: (v) => setDialogState(() => _isActive = v)),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(onPressed: _saving ? null : () { Navigator.pop(dialogContext); _save(id: doc?.id); }, child: Text(doc == null ? 'Save' : 'Update')),
          ],
        ),
      ),
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
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _showForm(), icon: const Icon(Icons.add), label: const Text('Add Achievement')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('achievements').orderBy('sortOrder').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Unable to load achievements.\n${snapshot.error}', textAlign: TextAlign.center));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('No achievements. Tap Add Achievement to create one.'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i];
            final data = d.data();
            final icon = icons[data['icon']] ?? Icons.emoji_events;
            final active = data['isActive'] != false;
            final task = taskTypes[data['taskType']] ?? 'Task not configured';
            final target = data['target'] ?? 1;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(child: Icon(icon)),
                title: Text('${data['title'] ?? ''}'),
                subtitle: Text('${data['description'] ?? ''}\nTask: $task • Target: $target${data['taskType'] == 'perfect_score' ? '%' : ''} • Sort: ${data['sortOrder'] ?? 0}'),
                isThreeLine: true,
                trailing: Wrap(spacing: 2, children: [
                  Switch(value: active, onChanged: (v) => _toggle(d.id, v)),
                  IconButton(icon: const Icon(Icons.edit), tooltip: 'Edit', onPressed: () => _showForm(doc: d)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), tooltip: 'Delete', onPressed: () => _delete(d.id)),
                ]),
              ),
            );
          },
        );
      },
    ),
  );

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _sortOrder.dispose();
    _target.dispose();
    super.dispose();
  }
}
