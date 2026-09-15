import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chapter_model.dart';
import '../providers/chapter_provider.dart';

class ChapterDialog extends StatefulWidget {
  final String subjectId;
  final ChapterModel? chapter;

  const ChapterDialog({
    super.key,
    required this.subjectId,
    this.chapter,
  });

  @override
  State<ChapterDialog> createState() => _ChapterDialogState();
}

class _ChapterDialogState extends State<ChapterDialog> {
  final _nameController = TextEditingController();
  final _orderController = TextEditingController();

  bool isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.chapter != null) {
      _nameController.text = widget.chapter!.name;
      _orderController.text = widget.chapter!.order.toString();
      isActive = widget.chapter!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.chapter == null
            ? "Add Chapter"
            : "Edit Chapter",
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Chapter Name",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Order",
              ),
            ),

            SwitchListTile(
              title: const Text("Active"),
              value: isActive,
              onChanged: (v) {
                setState(() {
                  isActive = v;
                });
              },
            ),
          ],
        ),
      ),
      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () async {

            if (_nameController.text.trim().isEmpty) {
              return;
            }

            final chapter = ChapterModel(
              id: widget.chapter?.id ??
                  _nameController.text
                      .trim()
                      .toLowerCase()
                      .replaceAll(" ", "_"),
              subjectId: widget.subjectId,
              name: _nameController.text.trim(),
              order: int.tryParse(_orderController.text) ?? 0,
              isActive: isActive,
            );

            final provider =
            context.read<ChapterProvider>();

            if (widget.chapter == null) {
              await provider.addChapter(chapter);
            } else {
              await provider.updateChapter(chapter);
            }

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}