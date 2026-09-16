import 'package:flutter/material.dart';
import '../subjects/subject_screen.dart';
import '../mock_tests/mock_test_list_screen.dart';
import '../questions/question_screen.dart';
import '../../screens/admin/reward_claims_screen.dart';
import '../../screens/admin/question_upload_screen.dart';
import '../../screens/admin/hindiquestions_screen.dart';
import '../../screens/admin/maths_screen.dart';
import '../../screens/admin/reasoning_screen.dart';
import 'home_banner_screen.dart';
import 'continue_learning_screen.dart';
import 'current_affairs_screen.dart';
import 'achievements_screen.dart';
import 'contact_settings_screen.dart';
import 'app_configuration_screen.dart';
import 'video_solutions_screen.dart';
import '../users/users_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  void _open(BuildContext context, Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  @override
  Widget build(BuildContext context) {
    final cards = <DashboardCardData>[
      DashboardCardData(title: 'Subjects', count: '4', icon: Icons.menu_book_rounded, colors: const [Color(0xff2563EB), Color(0xff60A5FA)], onTap: () => _open(context, const SubjectScreen())),
      DashboardCardData(title: 'Mock Tests', count: '0', icon: Icons.assignment_rounded, colors: const [Color(0xffF97316), Color(0xffFDBA74)], onTap: () => _open(context, MockTestListScreen())),
      DashboardCardData(title: 'Video Solutions', count: 'NEW', icon: Icons.play_circle_fill_rounded, colors: const [Color(0xff0891B2), Color(0xff67E8F9)], onTap: () => _open(context, const VideoSolutionsScreen())),
      DashboardCardData(title: 'Questions', count: '0', icon: Icons.quiz_rounded, colors: const [Color(0xff059669), Color(0xff34D399)], onTap: () => _open(context, const QuestionScreen())),
      DashboardCardData(title: 'Users', count: '0', icon: Icons.people_alt_rounded, colors: const [Color(0xff7C3AED), Color(0xffA78BFA)], onTap: () => _open(context, const UsersScreen())),
      DashboardCardData(title: 'Continue Learning', count: '0', icon: Icons.play_lesson_rounded, colors: const [Color(0xff0891B2), Color(0xff67E8F9)], onTap: () => _open(context, const ContinueLearningScreen())),
      DashboardCardData(title: 'Achievements', count: '0', icon: Icons.emoji_events_rounded, colors: const [Color(0xffD97706), Color(0xffFCD34D)], onTap: () => _open(context, const AchievementsScreen())),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('ARank India Admin'), backgroundColor: const Color(0xff3730A3), foregroundColor: Colors.white),
      drawer: Drawer(child: ListView(children: [
        const DrawerHeader(decoration: BoxDecoration(color: Color(0xff3730A3)), child: Center(child: Text('ARank India Admin', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)))),
        ListTile(leading: const Icon(Icons.dashboard), title: const Text('Dashboard'), onTap: () => Navigator.pop(context)),
        ListTile(leading: const Icon(Icons.app_settings_alt_outlined), title: const Text('Create Student App / App Configuration'), onTap: () => _open(context, const AppConfigurationScreen())),
        ListTile(leading: const Icon(Icons.campaign), title: const Text('Home Banner'), onTap: () => _open(context, const HomeBannerScreen())),
        ListTile(leading: const Icon(Icons.play_circle_fill_rounded), title: const Text('Video Solutions'), onTap: () => _open(context, const VideoSolutionsScreen())),
        ListTile(leading: const Icon(Icons.play_lesson), title: const Text('Continue Learning'), onTap: () => _open(context, const ContinueLearningScreen())),
        ListTile(leading: const Icon(Icons.newspaper_rounded), title: const Text('Current Affairs'), onTap: () => _open(context, const CurrentAffairsScreen())),
        ListTile(leading: const Icon(Icons.emoji_events), title: const Text('Achievements'), onTap: () => _open(context, const AchievementsScreen())),
        ListTile(leading: const Icon(Icons.contact_support_outlined), title: const Text('Contact Settings'), onTap: () => _open(context, const ContactSettingsScreen())),
        ListTile(leading: const Icon(Icons.menu_book), title: const Text('Subjects'), onTap: () => _open(context, const SubjectScreen())),
        ListTile(leading: const Icon(Icons.assignment), title: const Text('Mock Tests'), onTap: () => _open(context, MockTestListScreen())),
        ListTile(leading: const Icon(Icons.quiz), title: const Text('Questions'), onTap: () => _open(context, const QuestionScreen())),
        ListTile(leading: const Icon(Icons.upload_file), title: const Text('G.K. Questions'), onTap: () => _open(context, const QuestionUploadScreen())),
        ListTile(leading: const Icon(Icons.upload_file), title: const Text('Hindi Questions'), onTap: () => _open(context, const HindiQuestionsScreen())),
        ListTile(leading: const Icon(Icons.upload_file), title: const Text('Maths Questions'), onTap: () => _open(context, const MathsQuestionsScreen())),
        ListTile(leading: const Icon(Icons.upload_file), title: const Text('Reasoning Questions'), onTap: () => _open(context, const ReasoningQuestionsScreen())),
        ListTile(leading: const Icon(Icons.card_giftcard), title: const Text('Reward Claims'), onTap: () => _open(context, const RewardClaimsScreen())),
        ListTile(leading: const Icon(Icons.people), title: const Text('Users'), onTap: () => _open(context, const UsersScreen())),
        const ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
      ])),
      body: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xffF8FAFC), Color(0xffEEF2FF), Color(0xffF0FDFA)])), child: LayoutBuilder(builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1100 ? 3 : constraints.maxWidth >= 650 ? 2 : 1;
        return GridView.builder(padding: const EdgeInsets.all(24), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 22, mainAxisSpacing: 22, childAspectRatio: 1.55), itemCount: cards.length, itemBuilder: (context, index) => DashboardCard(data: cards[index]));
      })),
    );
  }
}

class DashboardCardData { final String title, count; final IconData icon; final List<Color> colors; final VoidCallback onTap; const DashboardCardData({required this.title, required this.count, required this.icon, required this.colors, required this.onTap}); }
class DashboardCard extends StatelessWidget {
  final DashboardCardData data;
  const DashboardCard({super.key, required this.data});
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(onTap: data.onTap, borderRadius: BorderRadius.circular(24), child: Ink(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: data.colors), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: data.colors.first.withOpacity(.25), blurRadius: 18, offset: const Offset(0, 9))]), child: Stack(children: [Positioned(right: -25, top: -25, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.12)))), Positioned(right: 20, bottom: 18, child: Icon(data.icon, size: 72, color: Colors.white.withOpacity(.18))), Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: Colors.white.withOpacity(.20), borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white.withOpacity(.28))), child: Icon(data.icon, color: Colors.white, size: 31)), const SizedBox(height: 14), Text(data.count, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(data.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Row(children: [Text('Open', style: TextStyle(color: Colors.white.withOpacity(.88), fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(width: 5), const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16)])]))]))));
}
