import 'package:flutter/material.dart';
import 'edit_question_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReasoningQuestionsScreen extends StatefulWidget {
  const ReasoningQuestionsScreen({super.key});

  @override
  State<ReasoningQuestionsScreen> createState() =>
      _ReasoningQuestionsScreenState();
}

class _ReasoningQuestionsScreenState
    extends State<ReasoningQuestionsScreen> {

  bool uploading = false;
  double progress = 0;
  String selectedFile = "No file selected";
  String status = "Waiting for Excel file...";
  String sortBy = "Latest";

  Future<void> uploadQuestions(SpreadsheetDecoder decoder) async {
    setState(() {
      status = "Uploading questions...";
    });

    if (decoder.tables.isEmpty) {
      throw Exception("No worksheet found in Excel file.");
    }

    final sheet = decoder.tables.values.first;
    final lastQuestion = await FirebaseFirestore.instance
        .collection("reasoning")
        .orderBy("questionNo", descending: true)
        .limit(1)
        .get();

    int nextQuestionNo = 1;

    if (lastQuestion.docs.isNotEmpty) {
      nextQuestionNo =
          (lastQuestion.docs.first["questionNo"] ?? 0) + 1;
    }

    for (int i = 1; i < sheet.rows.length; i++) {

      final row = sheet.rows[i];

      print(row);

      final question =
      row.isNotEmpty ? (row[0]?.toString() ?? "") : "";

      final answer =
      row.length > 1 ? (row[1]?.toString() ?? "") : "";
      final explanation =
      row.length > 2 ? (row[2]?.toString() ?? "") : "";

      if (question.isEmpty || answer.isEmpty) {
        continue;
      }

      await FirebaseFirestore.instance
          .collection("reasoning")
          .add({
        "questionNo": nextQuestionNo++,
        "question": question,
        "answer": answer,
        "explanation": explanation,

        // Status
        "isActive": true,
        "isFeatured": false,
        "isNew": true,

        // Analytics
        "views": 0,
        "shares": 0,
        "readCount": 0,
        "reportCount": 0,
        "likeCount": 0,
        "bookmarkCount": 0,

        // Share
        "shareUrl": "",
        "questionId": "",

        // Time
        "createdAt": FieldValue.serverTimestamp(),
      });

      setState(() {
        status = "Questions uploaded successfully";
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Questions Uploaded Successfully"),
      ),
    );
  }



  Future<void> pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null) return;

      final bytes = result.files.first.bytes;

      if (bytes == null) {
        throw Exception("File bytes are null");
      }

      setState(() {
        selectedFile = result.files.first.name;
        status = "Excel file selected successfully";
      });

      print("File Name : ${result.files.first.name}");
      print("Bytes : ${bytes.length}");

      final decoder = SpreadsheetDecoder.decodeBytes(
        bytes,
        update: false,
      );

      await uploadQuestions(decoder);

    } catch (e) {

      setState(() {
        status = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Upload"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [

                    const Icon(
                      Icons.upload_file,
                      size: 70,
                      color: Colors.blue,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Upload Excel File",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      selectedFile,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: uploading ? null : pickExcelFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload Excel"),
                    ),

                    const SizedBox(height: 20),

                    uploading
                        ? Column(
                      children: [

                        LinearProgressIndicator(
                          value: progress,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "${(progress * 100).toStringAsFixed(0)} %",
                        ),
                      ],
                    )
                        : const SizedBox(),

                    const SizedBox(height: 20),


                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text("Status"),
                subtitle: Text(status),
              ),
            ),


            const SizedBox(height: 20),



            Row(
              children: [

                const Expanded(
                  child: Text(
                    "Uploaded Questions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 150,  // इसे 180, 200 या 220 रख सकते हो
                  child: DropdownButtonFormField<String>(
                    value: sortBy,
                    decoration: const InputDecoration(
                      labelText: "Sort By",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Latest",
                        child: Text("Latest"),
                      ),
                      DropdownMenuItem(
                        value: "Question Number",
                        child: Text("Question No"),
                      ),
                      DropdownMenuItem(
                        value: "Most Viewed",
                        child: Text("Viewed"),
                      ),
                      DropdownMenuItem(
                        value: "Most Shared",
                        child: Text("Shared"),
                      ),
                      DropdownMenuItem(
                        value: "Most Read",
                        child: Text("Read"),
                      ),
                      DropdownMenuItem(
                        value: "Most Liked",
                        child: Text("Liked"),
                      ),
                      DropdownMenuItem(
                        value: "Most Bookmarked",
                        child: Text("Bookmarked"),
                      ),
                      DropdownMenuItem(
                        value: "Most Reported",
                        child: Text("Reported"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        sortBy = value!;
                      });
                    },
                  ),
                ),

              ],
            ),

            const SizedBox(height: 10),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("reasoning")
                    .orderBy(

                  sortBy == "Latest"
                      ? "createdAt"
                      : sortBy == "Question Number"
                      ? "questionNo"
                      : sortBy == "Most Viewed"
                      ? "views"
                      : sortBy == "Most Shared"
                      ? "shares"
                      : sortBy == "Most Read"
                      ? "readCount"
                      : sortBy == "Most Liked"
                      ? "likeCount"
                      : sortBy == "Most Bookmarked"
                      ? "bookmarkCount"
                      : "reportCount",

                  descending: true,
                )
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No Questions Uploaded"),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      final data =
                      docs[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [

                                  CircleAvatar(
                                    child: Text("${index + 1}"),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      data["question"] ?? "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditQuestionScreen(
                                            docId: docs[index].id,
                                            data: data,
                                          ),
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

                                      final confirm =
                                      await showDialog<bool>(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Delete Question"),
                                            content: const Text(
                                              "Are you sure?",
                                            ),
                                            actions: [

                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context,
                                                      false);
                                                },
                                                child: const Text("No"),
                                              ),

                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context,
                                                      true);
                                                },
                                                child: const Text("Yes"),
                                              ),

                                            ],
                                          );
                                        },
                                      );

                                      if (confirm == true) {

                                        await FirebaseFirestore
                                            .instance
                                            .collection(
                                            "reasoning")
                                            .doc(docs[index].id)
                                            .delete();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Question Deleted"),
                                          ),
                                        );
                                      }
                                    },
                                  ),

                                ],
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Answer : ${data["answer"] ?? ""}",
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Explanation : ${data["explanation"] ?? ""}",
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [

                                  Chip(
                                    avatar: const Icon(
                                      Icons.visibility,
                                      size: 18,
                                    ),
                                    label: Text(
                                        "${data["views"] ?? 0}"),
                                  ),

                                  Chip(
                                    avatar: const Icon(
                                      Icons.share,
                                      size: 18,
                                    ),
                                    label: Text(
                                        "${data["shares"] ?? 0}"),
                                  ),

                                  Chip(
                                    avatar: const Icon(
                                      Icons.menu_book,
                                      size: 18,
                                    ),
                                    label: Text(
                                        "${data["readCount"] ?? 0}"),
                                  ),

                                  Chip(
                                    avatar: const Icon(
                                      Icons.flag,
                                      size: 18,
                                    ),
                                    label: Text(
                                        "${data["reportCount"] ?? 0}"),
                                  ),

                                  Chip(
                                    avatar: const Icon(
                                      Icons.favorite,
                                      size: 18,
                                    ),
                                    label: Text(
                                        "${data["likeCount"] ?? 0}"),
                                  ),

                                  Chip(
                                    avatar: const Icon(
                                      Icons.bookmark,
                                      size: 18,
                                    ),
                                    label: Text(
                                        "${data["bookmarkCount"] ?? 0}"),
                                  ),

                                ],
                              ),

                            ],
                          ),
                        ),
                      );
                    },
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