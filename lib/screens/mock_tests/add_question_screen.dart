import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/question_model.dart';
import '../../services/mock_question_service.dart';

class AddQuestionScreen extends StatefulWidget {
  final String mockTestId;
  final QuestionModel? question;

  const AddQuestionScreen({
    super.key,
    required this.mockTestId,
    this.question,
  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  final explanationController = TextEditingController();

  final marksController = TextEditingController(text: "2");
  final negativeMarksController = TextEditingController(text: "0.5");

  final service = MockQuestionService();

  String subject = "Mathematics";
  String correctAnswer = "A";
  @override
  void initState() {
    super.initState();

    if (widget.question != null) {
      questionController.text = widget.question!.question;
      optionAController.text = widget.question!.optionA;
      optionBController.text = widget.question!.optionB;
      optionCController.text = widget.question!.optionC;
      optionDController.text = widget.question!.optionD;
      explanationController.text = widget.question!.explanation;

      marksController.text = widget.question!.marks.toString();
      negativeMarksController.text =
          widget.question!.negativeMarks.toString();

      subject = widget.question!.subject;
      correctAnswer = widget.question!.correctAnswer;
    }
  }

  Future<void> saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    final question = QuestionModel(
      id: widget.question?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),

      subjectId: "",
      chapterId: "",

      mockTestId: widget.mockTestId,
      subject: subject,

      question: questionController.text.trim(),
      optionA: optionAController.text.trim(),
      optionB: optionBController.text.trim(),
      optionC: optionCController.text.trim(),
      optionD: optionDController.text.trim(),

      correctAnswer: correctAnswer,

      explanation: explanationController.text.trim(),

      difficulty: "Medium",

      marks: int.parse(marksController.text),

      negativeMarks:
      double.parse(negativeMarksController.text),

      isActive: true,
    );

    if (widget.question == null) {
      await service.addQuestion(question);
    } else {
      await service.updateQuestion(question);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget field(
      TextEditingController controller,
      String label,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        validator: (v) =>
        v == null || v.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Question"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              DropdownButtonFormField<String>(
                value: subject,
                decoration: const InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Mathematics",
                    child: Text("Mathematics"),
                  ),
                  DropdownMenuItem(
                    value: "Reasoning",
                    child: Text("Reasoning"),
                  ),
                  DropdownMenuItem(
                    value: "General Knowledge",
                    child: Text("General Knowledge"),
                  ),
                  DropdownMenuItem(
                    value: "Hindi",
                    child: Text("Hindi"),
                  ),
                  DropdownMenuItem(
                    value: "English",
                    child: Text("English"),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    subject = v!;
                  });
                },
              ),

              const SizedBox(height: 15),

              field(questionController, "Question"),

              field(optionAController, "Option A"),
              field(optionBController, "Option B"),
              field(optionCController, "Option C"),
              field(optionDController, "Option D"),

              DropdownButtonFormField<String>(
                value: correctAnswer,
                decoration: const InputDecoration(
                  labelText: "Correct Answer",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "A", child: Text("A")),
                  DropdownMenuItem(value: "B", child: Text("B")),
                  DropdownMenuItem(value: "C", child: Text("C")),
                  DropdownMenuItem(value: "D", child: Text("D")),
                ],
                onChanged: (v) {
                  setState(() {
                    correctAnswer = v!;
                  });
                },
              ),

              const SizedBox(height: 15),

              field(explanationController, "Explanation"),
              field(marksController, "Marks"),
              field(negativeMarksController, "Negative Marks"),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: saveQuestion,
                child: const Text("Save Question"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}