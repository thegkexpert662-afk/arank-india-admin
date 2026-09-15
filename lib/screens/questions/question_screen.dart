import 'package:flutter/material.dart';
import '../../widgets/question_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subject_provider.dart';
import '../../providers/chapter_provider.dart';
import '../../providers/question_provider.dart';

import '../../widgets/question_dialog.dart';


class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {

  String? selectedSubject;
  String? selectedChapter;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SubjectProvider>().loadSubjects();
    });
  }
  Future<void> importExcel({
    required String subjectId,
    required String chapterId,
    required BuildContext context,
  }) async {
    // Step 1
    // Open File Picker

    // Step 2
    // Read Excel

    // Step 3
    // Convert Rows into QuestionModel

    // Step 4
    // Bulk Upload Firebase

    // Step 5
    // Refresh Question List

    // Step 6
    // Show Success Report
  }

  @override
  Widget build(BuildContext context) {

    final subjectProvider = context.watch<SubjectProvider>();
    final chapterProvider = context.watch<ChapterProvider>();
    final questionProvider = context.watch<QuestionProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: "Import Excel",
            onPressed: () async {

              print("Import Button Clicked");


              if (selectedSubject == null || selectedChapter == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please select Subject and Chapter first",
                    ),
                  ),
                );
                return;
              }

              await context.read<QuestionProvider>().importExcel(
                subjectId: selectedSubject!,
                chapterId: selectedChapter!,
                context: context,
              );
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedSubject == null || selectedChapter == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Please select Subject and Chapter first",
                ),
              ),
            );
            return;
          }

          showDialog(
            context: context,
            builder: (_) => QuestionDialog(
              subjectId: selectedSubject!,
              chapterId: selectedChapter!,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),



      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [

            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: const InputDecoration(
                labelText: "Select Subject",
                border: OutlineInputBorder(),
              ),
              items: subjectProvider.subjects.map((subject) {
                return DropdownMenuItem<String>(
                  value: subject.id,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubject = value;
                  selectedChapter = null;
                });

                if (value != null) {
                  chapterProvider.loadChapters(value);
                }
              },
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedChapter,
              decoration: const InputDecoration(
                labelText: "Select Chapter",
                border: OutlineInputBorder(),
              ),
              items: chapterProvider.chapters.map((chapter) {
                return DropdownMenuItem<String>(
                  value: chapter.id,
                  child: Text(chapter.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedChapter = value;
                });

                if (selectedSubject != null && value != null) {
                  questionProvider.loadQuestions(
                    selectedSubject!,
                    value,
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: questionProvider.isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : questionProvider.questions.isEmpty
                  ? const Center(
                child: Text(
                  "No Questions Found",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: questionProvider.questions.length,
                itemBuilder: (context, index) {
                  final question = questionProvider.questions[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(question.question),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Answer : ${question.correctAnswer}"),
                          Text("Difficulty : ${question.difficulty}"),
                          Text("Marks : ${question.marks}"),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => QuestionDialog(
                                  subjectId: question.subjectId,
                                  chapterId: question.chapterId,
                                  question: question,
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
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
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                await questionProvider.deleteQuestion(
                                  question.subjectId,
                                  question.chapterId,
                                  question.id,
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Question deleted successfully"),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
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