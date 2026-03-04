import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:todo/features/home/home_screen.dart';
import 'package:todo/features/login/login_provider.dart';
import 'package:todo/features/login/login_screen.dart';
import 'package:todo/features/home/providers/todo_provider.dart'
    as todo_provider;
import 'package:todo/services/notification_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().init();
  await NotificationService().requestPermissions();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LoginProvider()),
        ChangeNotifierProvider(
          create: (context) => todo_provider.TodoProvider(),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: MaterialApp(
          title: 'TODO',
          debugShowCheckedModeBanner: false,
          home: FirebaseAuth.instance.currentUser != null
              ? const HomeScreen()
              : const LoginScreen(),
        ),
      ),
    );
  }
}
