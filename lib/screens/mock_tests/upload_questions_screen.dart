import 'package:flutter/material.dart';
import '../../models/question_model.dart';
import '../../services/question_service.dart';
import 'add_question_screen.dart';
import '../../services/mock_question_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';


class UploadQuestionsScreen extends StatelessWidget {
  final String mockTestId;
  final String mockTestName;

  UploadQuestionsScreen({
    super.key,
    required this.mockTestId,
    required this.mockTestName,
  });

  final MockQuestionService service = MockQuestionService();

  Future<void> importExcel(BuildContext context) async {
    try {
      debugPrint("mockTestId = $mockTestId");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null) return;

      if (result.files.single.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to read Excel file"),
          ),
        );
        return;
      }



      final bytes = result.files.single.bytes!;

      debugPrint("File Name: ${result.files.single.name}");
      debugPrint("File Size: ${bytes.length}");

      debugPrint("Reading Excel...");

      final decoder = SpreadsheetDecoder.decodeBytes(
        bytes,
        update: false,
      );
      int uploaded = 0;

      for (final sheetName in decoder.tables.keys) {
        final table = decoder.tables[sheetName];

        if (table == null) continue;

        for (int i = 1; i < table.rows.length; i++) {
          final row = table.rows[i];

          if (row.length < 11) continue;

          final question = QuestionModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            subjectId: "",
            chapterId: "",
            mockTestId: mockTestId,

            question: row[0]?.toString() ?? "",
            optionA: row[1]?.toString() ?? "",
            optionB: row[2]?.toString() ?? "",
            optionC: row[3]?.toString() ?? "",
            optionD: row[4]?.toString() ?? "",
            correctAnswer: row[5]?.toString() ?? "A",
            explanation: row[6]?.toString() ?? "",
            subject: row[7]?.toString() ?? "",

            marks: int.tryParse(row[9]?.toString() ?? "2") ?? 2,
            negativeMarks: double.tryParse(row[10]?.toString() ?? "0.5") ?? 0.5,
            difficulty: row.length > 11
                ? row[11]?.toString() ?? "Easy"
                : "Easy",
            isActive: true,
          );

          await service.addQuestion(question);
          uploaded++;
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$uploaded Questions Imported Successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, s) {
      debugPrint("IMPORT ERROR: $e");
      debugPrint("$s");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Import Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mockTestName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => importExcel(context),
                icon: const Icon(Icons.upload_file),
                label: const Text("Import Excel"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddQuestionScreen(
                        mockTestId: mockTestId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add Question",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<QuestionModel>>(
                stream: service.getQuestionsByMockTest(mockTestId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No Questions Added"),
                    );
                  }

                  final questions = snapshot.data!;

                  final maths = questions
                      .where((q) => q.subject.trim().toUpperCase() == "MATHEMATICS")
                      .length;

                  final reasoning = questions
                      .where((q) => q.subject.trim().toUpperCase() == "REASONING")
                      .length;

                  final gk = questions
                      .where((q) => q.subject.trim().toUpperCase() == "GENERAL KNOWLEDGE")
                      .length;

                  final hindi = questions
                      .where((q) => q.subject.trim().toUpperCase() == "HINDI")
                      .length;

                  final english = questions
                      .where((q) => q.subject.trim().toUpperCase() == "ENGLISH")
                      .length;
                  return Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [

                              const Text(
                                "Mock Test Progress",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),

                              const SizedBox(height: 15),

                              ListTile(
                                leading: const Icon(Icons.quiz, color: Colors.blue),
                                title: const Text("Total Questions"),
                                trailing: Text(
                                  "${questions.length} / 100",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              ListTile(
                                leading: const Icon(Icons.calculate,color: Colors.orange),
                                title: const Text("Mathematics"),
                                trailing: Text("$maths / 25"),
                              ),

                              ListTile(
                                leading: const Icon(Icons.psychology,color: Colors.purple),
                                title: const Text("Reasoning"),
                                trailing: Text("$reasoning / 25"),
                              ),

                              ListTile(
                                leading: const Icon(Icons.public,color: Colors.green),
                                title: const Text("General Knowledge"),
                                trailing: Text("$gk / 25"),
                              ),

                              ListTile(
                                leading: const Icon(Icons.language,color: Colors.red),
                                title: const Text("Hindi"),
                                trailing: Text("$hindi / 25"),
                              ),

                              ListTile(
                                leading: const Icon(Icons.language, color: Colors.blue),
                                title: const Text("English"),
                                trailing: Text("$english / 25"),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: ListView.builder(
                          itemCount: questions.length,
                          itemBuilder: (context, index) {
                            final q = questions[index];

                            return Card(
                              child: ListTile(
                                title: Text(
                                  "Q${index + 1}. ${q.question}",
                                ),
                                subtitle: Text("Correct: ${q.correctAnswer}"),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == "edit") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddQuestionScreen(
                                            mockTestId: mockTestId,
                                            question: q,
                                          ),
                                        ),
                                      );
                                    }

                                    if (value == "delete") {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Delete Question"),
                                          content: const Text(
                                            "Are you sure you want to delete this question?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await service.deleteMockQuestion(q.id);

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Question deleted successfully"),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: "edit",
                                      child: Text("Edit"),
                                    ),
                                    PopupMenuItem(
                                      value: "delete",
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}