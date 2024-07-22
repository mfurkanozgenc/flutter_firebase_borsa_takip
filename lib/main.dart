import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/firebase_options.dart';
import 'package:project/router.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    runApp(const MainApp());
  } catch (e) {
    print('HATAAA : $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'Borsa Takip',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: false),
        routerConfig: router);
  }
}
