import 'package:flutter/material.dart';
import 'upload_questions_screen.dart';
import '../../models/mock_test_model.dart';
import '../../services/mock_test_service.dart';
import 'add_mock_test_screen.dart';
import '../../services/mock_question_service.dart';

class MockTestListScreen extends StatelessWidget {
  MockTestListScreen({super.key});
  final MockQuestionService questionService = MockQuestionService();

  final MockTestService service = MockTestService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mock Tests"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMockTestScreen(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<MockTestModel>>(
        stream: service.getMockTests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No Mock Tests Found"),
            );
          }

          final mockTests = snapshot.data!;

          return ListView.builder(
            itemCount: mockTests.length,
            itemBuilder: (context, index) {
              final test = mockTests[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(test.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${test.totalQuestions} Questions • "
                            "${test.duration} Minutes • "
                            "${test.totalMarks} Marks",
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Text(
                            test.isPublished
                                ? "🟢 Published"
                                : "🔴 Unpublished",
                            style: TextStyle(
                              color: test.isPublished
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Switch(
                            value: test.isPublished,
                            onChanged: (value) async {
                              if (value) {
                                final questions = await questionService
                                    .getQuestionsByMockTestFuture(test.id);

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

                                final total = questions.length;

                                if (maths != 25 ||
                                    reasoning != 25 ||
                                    gk != 25 ||
                                    (hindi != 25 && english != 25) ||
                                    total != 125) {

                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Cannot Publish"),
                                      content: Text(
                                        "Mathematics : $maths/25\n"
                                            "Reasoning : $reasoning/25\n"
                                            "General Knowledge : $gk/25\n"
                                            "Hindi : $hindi/25\n"
                                            "English : $english/25\n"
                                            "Total : $total/100",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );

                                  return;
                                }
                              }

                              await service.publishMockTest(test.id, value);
                            },
                          )
                        ],
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UploadQuestionsScreen(
                                mockTestId: test.id,
                                mockTestName: test.title,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.upload_file),
                        label: const Text(
                          "Upload Questions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == "delete") {
                        await service.deleteMockTest(test.id);
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
          );
        },
      ),
    );
  }
}