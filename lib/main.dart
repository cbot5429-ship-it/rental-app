import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';

// 👇 Global Notifier: The app will listen to this to know when to switch themes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dbxsriopvtqdddbuysek.supabase.co',
    anonKey: 'sb_publishable_1NZ66jkf6WF2vrB9p3mT5A__kxWLRme',
  );

  // 👇 Load the saved theme from the user's device
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme');
  if (savedTheme == 'light') themeNotifier.value = ThemeMode.light;
  if (savedTheme == 'dark') themeNotifier.value = ThemeMode.dark;

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 Listen to the theme changes and rebuild the app
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Rental App',
          debugShowCheckedModeBanner: false,
          
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey.shade50,
          ),
          
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
          ),
          
          themeMode: currentMode, // Apply the current theme
          home: const AuthGate(),
        );
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}