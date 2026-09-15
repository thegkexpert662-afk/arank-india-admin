import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailsScreen({
    super.key,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [

                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                ListTile(
                  title: const Text("Name"),
                  subtitle: Text(userData["name"] ?? ""),
                ),

                ListTile(
                  title: const Text("Mobile"),
                  subtitle: Text(userData["phone"] ?? ""),
                ),

                ListTile(
                  title: const Text("Email"),
                  subtitle: Text(userData["email"] ?? ""),
                ),

                ListTile(
                  title: const Text("State"),
                  subtitle: Text(userData["state"] ?? ""),
                ),

                ListTile(
                  title: const Text("District"),
                  subtitle: Text(userData["district"] ?? ""),
                ),

                ListTile(
                  title: const Text("UPI ID"),
                  subtitle: Text(userData["upiId"] ?? ""),
                ),

                ListTile(
                  title: const Text("Profile Completed"),
                  subtitle: Text(
                    (userData["profileCompleted"] ?? false)
                        ? "Yes"
                        : "No",
                  ),
                ),

                ListTile(
                  title: const Text("UID"),
                  subtitle: Text(userData["uid"] ?? ""),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}