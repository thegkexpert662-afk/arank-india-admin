import 'package:flutter/material.dart';
import '../subjects/subject_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ARank India Admin"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Center(
                child: Text(
                  "ARank India Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("Subjects"),
              onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SubjectScreen(),
                ),
              );},
            ),

            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text("Chapters"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text("Questions"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Users"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: const [

            DashboardCard(
              title: "Subjects",
              count: "4",
              icon: Icons.menu_book,
              color: Colors.blue,
            ),

            DashboardCard(
              title: "Chapters",
              count: "3",
              icon: Icons.library_books,
              color: Colors.orange,
            ),

            DashboardCard(
              title: "Questions",
              count: "0",
              icon: Icons.quiz,
              color: Colors.green,
            ),

            DashboardCard(
              title: "Users",
              count: "0",
              icon: Icons.people,
              color: Colors.purple,
            ),

          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: color),
            const SizedBox(height: 15),
            Text(
              count,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}