import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditQuestionScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditQuestionScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {

  late TextEditingController questionNoController;
  late TextEditingController questionController;
  late TextEditingController answerController;

  @override
  void initState() {
    super.initState();

    questionNoController = TextEditingController(
      text: widget.data["questionNo"].toString(),
    );

    questionController = TextEditingController(
      text: widget.data["question"] ?? "",
    );

    answerController = TextEditingController(
      text: widget.data["answer"] ?? "",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Question"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: questionNoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Question No",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: questionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Question",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: answerController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Answer",
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

                  await FirebaseFirestore.instance
                      .collection("ssc_gd_questions")
                      .doc(widget.docId)
                      .update({

                    "questionNo":
                    int.parse(questionNoController.text),

                    "question":
                    questionController.text.trim(),

                    "answer":
                    answerController.text.trim(),

                  });

                  Navigator.pop(context);
                },
                child: const Text("Update Question"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}