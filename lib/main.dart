import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/chapter_provider.dart';
import 'firebase_options.dart';
import 'providers/subject_provider.dart';
import 'screens/login/login_screen.dart';
import 'providers/question_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => QuestionProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => SubjectProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ChapterProvider(),
          ),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ARank India Admin',
      home: const LoginScreen(),
    );
  }
}