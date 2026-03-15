import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'screens/auth/login_screen.dart';
import 'theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fhqiewinlrphsaottdwe.supabase.co/',
    anonKey: 'sb_publishable_bqccpo7V4lW_80gLJlcpaA_enoJKY1q',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Emergency Assist",

      // Light Theme
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.red,
      ),

      // Dark Theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
      ),

      themeMode: themeNotifier.themeMode,

      home: const LoginScreen(),
    );
  }
}