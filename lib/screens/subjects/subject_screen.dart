import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subject Management"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(
                hintText: "Search Subject",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [

                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Category")),
                      DataColumn(label: Text("Order")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Action")),

                    ],
                    rows: const [

                      DataRow(
                        cells: [

                          DataCell(Text("Mathematics")),
                          DataCell(Text("SSC GD")),
                          DataCell(Text("1")),
                          DataCell(Text("Active")),

                          DataCell(
                            Row(
                              children: [

                                Icon(Icons.edit,color: Colors.blue),

                                SizedBox(width:10),

                                Icon(Icons.delete,color: Colors.red),

                              ],
                            ),
                          ),

                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}