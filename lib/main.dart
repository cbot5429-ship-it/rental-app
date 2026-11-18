import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';
import 'screens/property_list_screen.dart';
import 'screens/property_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/inbox_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

// Global Notifier: The app will listen to this to know when to switch themes
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dbxsriopvtqdddbuysek.supabase.co',
    anonKey: 'sb_publishable_1NZ66jkf6WF2vrB9p3mT5A__kxWLRme',
  );

  // Load the saved theme from the user's device
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
    // Listen to the theme changes and rebuild the app
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Rental App',
          debugShowCheckedModeBanner: false,

          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: currentMode,
          home: const AuthGate(),
          routes: {
            '/property_list': (context) => const PropertyListScreen(
              initialQuery: '',
              listingType: 'rent',
            ),
            '/property_detail': (context) => const PropertyDetailScreen(
              property: null, // This will be overridden
            ),
            '/add_property': (context) => const AddPropertyScreen(),
          },
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
        // Fall back to the session restored at startup so a signed-in user does
        // not see the login screen flash while the auth stream warms up.
        final session = snapshot.data?.session ?? supabase.auth.currentSession;
        if (session != null) {
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}

/// App shell that holds the persistent bottom navigation and the tab screens.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _BottomNav.screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _index = index),
        items: _BottomNav.items,
      ),
    );
  }
}

// Bottom navigation configuration
class _BottomNav {
  static const List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: 'Search',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline),
      activeIcon: Icon(Icons.favorite),
      label: 'Favorites',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message_outlined),
      activeIcon: Icon(Icons.message),
      label: 'Inbox',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  /// One screen per item in [items], in the same order.
  static final List<Widget> screens = [
    const HomeScreen(),
    const PropertyListScreen(initialQuery: '', listingType: 'rent'),
    const FavoritesScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];
}