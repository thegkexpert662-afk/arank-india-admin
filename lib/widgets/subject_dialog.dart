import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../providers/subject_provider.dart';
import 'package:provider/provider.dart';

class SubjectDialog extends StatefulWidget {
  final SubjectModel? subject;

  const SubjectDialog({
    super.key,
    this.subject,
  });

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _orderController = TextEditingController();

  bool isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
      _categoryController.text = widget.subject!.category;
      _orderController.text = widget.subject!.order.toString();
      isActive = widget.subject!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.subject == null ? "Add Subject" : "Edit Subject",
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Subject Name",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: "Category",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _orderController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Order",
              ),
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              value: isActive,
              title: const Text("Active"),
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
            final subject = SubjectModel(
              id: widget.subject?.id ?? "",
              name: _nameController.text.trim(),
              category: _categoryController.text.trim(),
              order: int.tryParse(_orderController.text) ?? 0,
              isActive: isActive,
            );

            final provider = context.read<SubjectProvider>();

            if (widget.subject == null) {
              await provider.addSubject(subject);
            } else {
              await provider.updateSubject(subject);
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