import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dbxsriopvtqdddbuysek.supabase.co',
    anonKey: 'sb_publishable_1NZ66jkf6WF2vrB9p3mT5A__kxWLRme',
  );

  // --- Temporary connection test (remove after it passes) ---
  try {
    await Supabase.instance.client.from('properties').select().limit(1);
    debugPrint('✅ Supabase connected');
  } catch (e) {
    debugPrint('❌ Supabase connection failed: $e');
  }

  runApp(const MyApp());
}

/// Global reference to the Supabase client — used everywhere in the app.
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
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