import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/mock_test_model.dart';
import '../../services/mock_test_service.dart';

class AddMockTestScreen extends StatefulWidget {
  const AddMockTestScreen({super.key});

  @override
  State<AddMockTestScreen> createState() => _AddMockTestScreenState();
}

class _AddMockTestScreenState extends State<AddMockTestScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final durationController = TextEditingController();
  final totalQuestionsController = TextEditingController();
  final totalMarksController = TextEditingController();
  final negativeMarksController = TextEditingController();

  bool isPublished = false;

  final MockTestService service = MockTestService();

  Future<void> saveMockTest() async {
    if (!_formKey.currentState!.validate()) return;

    final mockTest = MockTestModel(
      id: "",
      title: titleController.text.trim(),
      duration: int.parse(durationController.text),
      totalQuestions: int.parse(totalQuestionsController.text),
      totalMarks: int.parse(totalMarksController.text),
      negativeMarks: double.parse(negativeMarksController.text),
      isPublished: isPublished,
      createdAt: Timestamp.now(),
    );

    await service.addMockTest(mockTest);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mock Test Added Successfully"),
      ),
    );
  }

  Widget buildField(
      String label,
      TextEditingController controller,
      TextInputType type,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Mock Test"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              buildField(
                "Mock Test Name",
                titleController,
                TextInputType.text,
              ),

              buildField(
                "Duration (Minutes)",
                durationController,
                TextInputType.number,
              ),

              buildField(
                "Total Questions",
                totalQuestionsController,
                TextInputType.number,
              ),

              buildField(
                "Total Marks",
                totalMarksController,
                TextInputType.number,
              ),

              buildField(
                "Negative Marks",
                negativeMarksController,
                TextInputType.number,
              ),

              SwitchListTile(
                title: const Text("Publish"),
                value: isPublished,
                onChanged: (value) {
                  setState(() {
                    isPublished = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveMockTest,
                child: const Text("Save Mock Test"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}