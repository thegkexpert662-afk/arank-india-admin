import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question_model.dart';
import '../providers/question_provider.dart';


class QuestionDialog extends StatefulWidget {
  final String subjectId;
  final String chapterId;
  final QuestionModel? question;

  const QuestionDialog({
    super.key,
    required this.subjectId,
    required this.chapterId,
    this.question,
  });
  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {

  final questionController = TextEditingController();
  final optionAController = TextEditingController();
  final optionBController = TextEditingController();
  final optionCController = TextEditingController();
  final optionDController = TextEditingController();
  final explanationController = TextEditingController();
  final marksController = TextEditingController(text: "2");
  final negativeMarksController = TextEditingController(text: "0.50");


  String correctAnswer = "A";
  String difficulty = "Easy";

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

      correctAnswer = widget.question!.correctAnswer;
      difficulty = widget.question!.difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Question"),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: "Question",
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 10),

              TextField(
                controller: optionAController,
                decoration: const InputDecoration(
                  labelText: "Option A",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: optionBController,
                decoration: const InputDecoration(
                  labelText: "Option B",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: optionCController,
                decoration: const InputDecoration(
                  labelText: "Option C",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: optionDController,
                decoration: const InputDecoration(
                  labelText: "Option D",
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: correctAnswer,
                decoration: const InputDecoration(
                  labelText: "Correct Answer",
                ),
                items: const [
                  DropdownMenuItem(value: "A", child: Text("Option A")),
                  DropdownMenuItem(value: "B", child: Text("Option B")),
                  DropdownMenuItem(value: "C", child: Text("Option C")),
                  DropdownMenuItem(value: "D", child: Text("Option D")),
                ],
                onChanged: (value) {
                  setState(() {
                    correctAnswer = value!;
                  });
                },
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: difficulty,
                decoration: const InputDecoration(
                  labelText: "Difficulty",
                ),
                items: const [
                  DropdownMenuItem(value: "Easy", child: Text("Easy")),
                  DropdownMenuItem(value: "Medium", child: Text("Medium")),
                  DropdownMenuItem(value: "Hard", child: Text("Hard")),
                ],
                onChanged: (value) {
                  setState(() {
                    difficulty = value!;
                  });
                },
              ),

              const SizedBox(height: 10),

              TextField(
                controller: explanationController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Explanation",
                ),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: marksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Marks",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: negativeMarksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Negative Marks",
                ),
              ),

            ],
          ),
        ),
      ),
      actions: [

        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () async {

            if (questionController.text.trim().isEmpty) {
              return;
            }

            final question = QuestionModel(
              id: widget.question?.id ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              subjectId: widget.subjectId,
              chapterId: widget.chapterId,
              mockTestId: "", // अभी के लिए
              subject: "", // अभी के लिए
              question: questionController.text.trim(),
              optionA: optionAController.text.trim(),
              optionB: optionBController.text.trim(),
              optionC: optionCController.text.trim(),
              optionD: optionDController.text.trim(),
              correctAnswer: correctAnswer,
              explanation: explanationController.text.trim(),
              difficulty: difficulty,
              marks: int.tryParse(marksController.text) ?? 2,
              negativeMarks:
              double.tryParse(negativeMarksController.text) ?? 0.5,
              isActive: true,
            );

            final provider = context.read<QuestionProvider>();

            if (widget.question == null) {
              await provider.addQuestion(question);
            } else {
              await provider.updateQuestion(question);
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