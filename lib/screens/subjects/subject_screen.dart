import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/subject_provider.dart';
import '../../models/subject_model.dart';
import '../../widgets/subject_dialog.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SubjectProvider>().loadSubjects();
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<SubjectProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Subject Management"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const SubjectDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: provider.isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: provider.subjects.length,
        itemBuilder: (context, index) {

          SubjectModel subject =
          provider.subjects[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            child: ListTile(
              title: Text(subject.name),

              subtitle: Text(
                subject.category,
              ),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => SubjectDialog(
                          subject: subject,
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
                      provider.deleteSubject(
                        subject.id,
                      );
                    },
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}