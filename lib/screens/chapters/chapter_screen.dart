import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/chapter_dialog.dart';
import '../../providers/chapter_provider.dart';
import '../../providers/subject_provider.dart';
import '../../models/chapter_model.dart';

class ChapterScreen extends StatefulWidget {
  const ChapterScreen({super.key});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {

  String? selectedSubject;

  @override
  Widget build(BuildContext context) {

    final subjectProvider = context.watch<SubjectProvider>();
    final chapterProvider = context.watch<ChapterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chapter Management"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (selectedSubject == null) return;

          showDialog(
            context: context,
            builder: (_) => ChapterDialog(
              subjectId: selectedSubject!,
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

                return DropdownMenuItem(
                  value: subject.id,
                  child: Text(subject.name),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedSubject = value;
                });

                if (value != null) {
                  chapterProvider.loadChapters(value);
                }

              },
            ),

            const SizedBox(height: 20),

            Expanded(

              child: chapterProvider.isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )

                  : ListView.builder(

                itemCount: chapterProvider.chapters.length,

                itemBuilder: (context,index){

                  ChapterModel chapter =
                  chapterProvider.chapters[index];

                  return Card(

                    child: ListTile(

                      title: Text(chapter.name),

                      subtitle: Text(
                        "Order : ${chapter.order}",
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => ChapterDialog(
                                  subjectId: chapter.subjectId,
                                  chapter: chapter,
                                ),
                              );
                            },
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              chapterProvider.deleteChapter(
                                chapter.subjectId,
                                chapter.id,
                              );
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