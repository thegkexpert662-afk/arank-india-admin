import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/continue_learning_model.dart';
import '../../providers/continue_learning_provider.dart';

class ContinueLearningScreen extends StatefulWidget {
  const ContinueLearningScreen({super.key});
  @override
  State<ContinueLearningScreen> createState() => _ContinueLearningScreenState();
}

class _ContinueLearningScreenState extends State<ContinueLearningScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ContinueLearningProvider>().load());
  }

  Future<void> _edit([ContinueLearningModel? item]) async {
    final title = TextEditingController(text: item?.title ?? '');
    final subtitle = TextEditingController(text: item?.subtitle ?? '');
    final description = TextEditingController(text: item?.description ?? '');
    final subject = TextEditingController(text: item?.subject ?? '');
    final chapter = TextEditingController(text: item?.chapter ?? '');
    final thumbnail = TextEditingController(text: item?.thumbnailUrl ?? '');
    final progress = TextEditingController(text: (((item?.progress ?? 0) * 100).round()).toString());
    final button = TextEditingController(text: item?.buttonText ?? 'Continue');
    final targetId = TextEditingController(text: item?.targetId ?? '');
    final order = TextEditingController(text: (item?.sortOrder ?? 0).toString());
    String targetType = item?.targetType ?? 'mockTest';
    bool active = item?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(item == null ? 'Add Continue Learning' : 'Edit Continue Learning'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(children: [
                _field(title, 'Title *'),
                _field(subtitle, 'Subtitle'),
                _field(description, 'Description', maxLines: 3),
                _field(subject, 'Subject'),
                _field(chapter, 'Chapter'),
                _field(thumbnail, 'Thumbnail URL'),
                _field(progress, 'Progress % (0-100)', keyboard: TextInputType.number),
                _field(button, 'Button text'),
                DropdownButtonFormField<String>(
                  value: targetType,
                  decoration: const InputDecoration(labelText: 'Target type'),
                  items: const [
                    DropdownMenuItem(value: 'mockTest', child: Text('Mock Test')),
                    DropdownMenuItem(value: 'none', child: Text('No navigation')),
                  ],
                  onChanged: (v) => setDialogState(() => targetType = v ?? 'mockTest'),
                ),
                _field(targetId, 'Target ID (Mock Test ID)'),
                _field(order, 'Sort order', keyboard: TextInputType.number),
                SwitchListTile(
                  title: const Text('Active'),
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final p = ((double.tryParse(progress.text) ?? 0).clamp(0, 100) / 100).toDouble();
                if (title.text.trim().isEmpty) return;
                final model = ContinueLearningModel(
                  id: item?.id ?? '',
                  title: title.text.trim(),
                  subtitle: subtitle.text.trim(),
                  description: description.text.trim(),
                  subject: subject.text.trim(),
                  chapter: chapter.text.trim(),
                  thumbnailUrl: thumbnail.text.trim(),
                  icon: item?.icon ?? 'menu_book',
                  progress: p,
                  buttonText: button.text.trim().isEmpty ? 'Continue' : button.text.trim(),
                  targetType: targetType,
                  targetId: targetId.text.trim(),
                  isActive: active,
                  sortOrder: int.tryParse(order.text) ?? 0,
                );
                await context.read<ContinueLearningProvider>().save(model);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    for (final c in [title, subtitle, description, subject, chapter, thumbnail, progress, button, targetId, order]) { c.dispose(); }
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1, TextInputType? keyboard}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(controller: c, maxLines: maxLines, keyboardType: keyboard, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ContinueLearningProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Continue Learning Management')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Add')),
      body: p.loading
          ? const Center(child: CircularProgressIndicator())
          : p.items.isEmpty
              ? const Center(child: Text('No Continue Learning items. Add one from +'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: p.items.length,
                  itemBuilder: (_, i) {
                    final x = p.items[i];
                    final pct = (x.progress * 100).round();
                    return Card(
                      child: ListTile(
                        leading: x.thumbnailUrl.isNotEmpty
                            ? Image.network(x.thumbnailUrl, width: 58, height: 58, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.menu_book))
                            : const Icon(Icons.menu_book),
                        title: Text(x.title.isEmpty ? '(Untitled)' : x.title),
                        subtitle: Text('${x.subject}${x.chapter.isEmpty ? '' : ' • ${x.chapter}'} • $pct%'),
                        trailing: Wrap(spacing: 0, children: [
                          Switch(value: x.isActive, onChanged: (v) => p.toggle(x.id, v)),
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _edit(x)),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => p.delete(x.id)),
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}
