import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RewardClaimsScreen extends StatelessWidget {
  const RewardClaimsScreen({super.key});




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reward Claims"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reward_claims")
            .orderBy("claimRequestedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Reward Claims"),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data =
              docs[index].data() as Map<String, dynamic>;
              final status = data["claimStatus"] ?? "pending";
              final TextEditingController reasonController =
              TextEditingController();

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data["studentName"] ?? ""),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₹${data["rewardAmount"]}"),
                      Text("Status: ${data["claimStatus"]}"),
                      const SizedBox(height: 8),

                      Row(
                        children: [

                          ElevatedButton(
                            onPressed: status == "pending"
                                ? () async {
                              reasonController.clear();

                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Reject Reward"),
                                    content: TextField(
                                      controller: reasonController,
                                      decoration: const InputDecoration(
                                        hintText: "Enter rejection reason",
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );

                              await docs[index].reference.update({
                                "claimStatus": "approved",
                                "adminApproved": true,
                                "claimApprovedAt": FieldValue.serverTimestamp(),
                              });

                              await FirebaseFirestore.instance
                                  .collection("mock_results")
                                  .doc("${data["userId"]}_${data["mockTestId"]}")
                                  .update({
                                "claimStatus": "approved",
                                "claimApproved": true,
                              });
                            }
                                : null,
                            child: const Text("Approve"),
                          ),

                          const SizedBox(width: 8),

                          ElevatedButton(
                            onPressed: status == "pending"
                                ? () async {
                              await docs[index].reference.update({
                                "claimStatus": "rejected",
                                "adminApproved": false,
                                "rejectionReason": reasonController.text.trim(),
                              });

                              await FirebaseFirestore.instance
                                  .collection("mock_results")
                                  .doc("${data["userId"]}_${data["mockTestId"]}")
                                  .update({
                                "claimStatus": "rejected",
                                "claimApproved": false,
                              });
                            }
                                : null,
                            child: const Text("Reject"),
                          ),

                          const SizedBox(width: 8),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await docs[index].reference.delete();
                            },
                          ),

                          const SizedBox(height: 8),

                          if (status == "approved")
                            const Text(
                              "✅ Reward Approved",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          if (status == "rejected")
                            const Text(
                              "❌ Reward Rejected",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (status == "rejected")
                            Text(
                              "Reason: ${data["rejectionReason"] ?? "No reason provided"}",
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
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
    );
  }
}