import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  void showUserDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("User Details"),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      child: Text(
                        ((data["name"] ?? "U") as String)
                            .substring(0, 1)
                            .toUpperCase(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Name"),
                    subtitle: Text(data["name"] ?? "-"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Mobile"),
                    subtitle: Text(data["phone"] ?? "-"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("Email"),
                    subtitle: Text(data["email"] ?? "-"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.location_city),
                    title: const Text("State"),
                    subtitle: Text(data["state"] ?? "-"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text("District"),
                    subtitle: Text(data["district"] ?? "-"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: const Text("Status"),
                    subtitle: Text(
                      data["isActive"] == true
                          ? "Active"
                          : "Inactive",
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(
      String userId,
      Map<String, dynamic> data,
      ) {

    final nameController =
    TextEditingController(text: data["name"]);

    final emailController =
    TextEditingController(text: data["email"]);

    final upiController =
    TextEditingController(text: data["upiId"] ?? "");

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text("Edit User"),

          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: upiController,
                  decoration: const InputDecoration(
                    labelText: "UPI ID",
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                  ),
                ),

              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {

                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(userId)
                    .update({

                  "name": nameController.text.trim(),
                  "email": emailController.text.trim(),
                  "upiId": upiController.text.trim(),

                });

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),

          ],
        );
      },
    );
  }
  Future<void> toggleUserStatus(
      String userId,
      bool currentStatus,
      ) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({
      "isActive": !currentStatus,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          currentStatus
              ? "User Blocked"
              : "User Activated",
        ),
      ),
    );
  }
  void showBlockDialog(
      String userId,
      bool currentStatus,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            currentStatus ? "Block User" : "Activate User",
          ),
          content: Text(
            currentStatus
                ? "Are you sure you want to block this user?"
                : "Do you want to activate this user?",
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                currentStatus ? Colors.red : Colors.green,
              ),
              onPressed: () async {
                Navigator.pop(context);

                await toggleUserStatus(
                  userId,
                  currentStatus,
                );
              },
              child: Text(
                currentStatus ? "Block" : "Activate",
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUser(String userId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User deleted successfully"),
      ),
    );
  }
  void confirmDelete(String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete User"),
          content: const Text(
            "Are you sure you want to permanently delete this user?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await deleteUser(userId);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  final TextEditingController searchController = TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

          TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: "Search User",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              search = value.toLowerCase();
            });
          },
        ),

        const SizedBox(height: 20),

        Expanded(
          child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("No Users Found"),
              );
            }

            final users = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final name = (data["name"] ?? "").toString().toLowerCase();
              final phone = (data["phone"] ?? "").toString().toLowerCase();

              return name.contains(search) || phone.contains(search);
            }).toList();

            final totalUsers = users.length;

            final activeUsers = users.where((user) {
              final data = user.data() as Map<String, dynamic>;
              return data["isActive"] == true;
            }).length;

            final inactiveUsers = totalUsers - activeUsers;


            final todayJoined = users.where((user) {
              final data = user.data() as Map<String, dynamic>;

              if (data["createdAt"] == null) return false;

              final DateTime created =
              (data["createdAt"] as Timestamp).toDate();

              final DateTime now = DateTime.now();

              return created.year == now.year &&
                  created.month == now.month &&
                  created.day == now.day;
            }).length;

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.blue.shade100,
                        child: ListTile(
                          leading: const Icon(Icons.people),
                          title: const Text("Total Users"),
                          subtitle: Text(totalUsers.toString()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Card(
                        color: Colors.green.shade100,
                        child: ListTile(
                          leading: const Icon(Icons.check_circle),
                          title: const Text("Active"),
                          subtitle: Text(activeUsers.toString()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Card(
                        color: Colors.red.shade100,
                        child: ListTile(
                          leading: const Icon(Icons.block),
                          title: const Text("Inactive"),
                          subtitle: Text(inactiveUsers.toString()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),

                    Expanded(
                      child: Card(
                        color: Colors.orange.shade100,
                        child: ListTile(
                          leading: const Icon(
                            Icons.person_add,
                            color: Colors.orange,
                          ),
                          title: const Text("Today Joined"),
                          subtitle: Text(todayJoined.toString()),
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("No")),
                        DataColumn(label: Text("Avatar")),
                        DataColumn(label: Text("Name")),
                        DataColumn(label: Text("Mobile")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("State")),
                        DataColumn(label: Text("District")),
                        DataColumn(label: Text("Registered")),
                        DataColumn(label: Text("Last Login")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: List.generate(users.length, (index) {
                        final data = users[index].data() as Map<String, dynamic>;

                        final Timestamp? createdAt = data["createdAt"] as Timestamp?;
                        final Timestamp? lastLogin = data["lastLogin"] as Timestamp?;

                        final String registeredDate = createdAt == null
                            ? "-"
                            : DateFormat("dd MMM yyyy").format(createdAt.toDate());

                        final String lastLoginDate = lastLogin == null
                            ? "-"
                            : DateFormat("dd MMM yyyy HH:mm").format(lastLogin.toDate());

                        return DataRow(
                          cells: [
                            DataCell(Text("${index + 1}")),

                            DataCell(
                              CircleAvatar(
                                child: Text(
                                  ((data["name"] ?? "U") as String)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                ),
                              ),
                            ),

                            DataCell(Text(data["name"] ?? "")),
                            DataCell(Text(data["phone"] ?? "")),
                            DataCell(Text(data["email"] ?? "")),
                            DataCell(Text(data["state"] ?? "")),
                            DataCell(Text(data["district"] ?? "")),
                            DataCell(Text(registeredDate)),
                            DataCell(Text(lastLoginDate)),


                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                  IconButton(
                                    tooltip: "View",
                                    icon: const Icon(
                                      Icons.visibility,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      showUserDetails(data);
                                    },
                                  ),

                                  IconButton(
                                    tooltip: "Edit",
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () {
                                      showEditDialog(
                                        users[index].id,
                                        data,
                                      );
                                    },
                                  ),

                                  IconButton(
                                    tooltip: data["isActive"] == true
                                        ? "Block"
                                        : "Activate",
                                    icon: Icon(
                                      data["isActive"] == true
                                          ? Icons.block
                                          : Icons.check_circle,
                                      color: data["isActive"] == true
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    onPressed: () {
                                      showBlockDialog(
                                        users[index].id,
                                        data["isActive"] == true,
                                      );
                                    },
                                  ),

                                  IconButton(
                                    tooltip: "Delete",
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      confirmDelete(users[index].id);
                                    },
                                  ),

                                ],
                              ),
                            ),

                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
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