import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart'; // Add this import
import 'screens/home_screen.dart';
import 'screens/class_schedule_screen.dart';
import 'screens/study_group_screen.dart';
import 'screens/campus_event_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/splash_screen.dart';
import 'models/app_state.dart';
import 'utils/theme.dart';
import 'utils/database_helper.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_screen.dart';
import 'services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure channel buffer size
  const channel = MethodChannel('flutter/lifecycle');
  ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(channel.name, (message) async {
    // Handle lifecycle messages
    return null;
  });
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firebase Service
  await FirebaseService().initialize();
  
  // Initialize database and services only on non-web platforms
  if (!kIsWeb) {
    try {
      if (Platform.isWindows) {
        // Initialize Firebase Database for Windows
        FirebaseDatabase.instance.setPersistenceEnabled(true);
        FirebaseDatabase.instance.setPersistenceCacheSizeBytes(10000000); // 10MB
      }
      await DatabaseHelper().database;
      await NotificationService().init();
      await SyncService().initialize();
    } catch (e) {
      debugPrint('Error initializing local services: $e');
    }
  }
  
  // Initialize app state with shared preferences
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState(prefs);
  
  runApp(CampusConnectApp(appState: appState));
}

class CampusConnectApp extends StatefulWidget {
  final AppState appState;
  
  const CampusConnectApp({super.key, required this.appState});

  @override
  State<CampusConnectApp> createState() => _CampusConnectAppState();
}

class _CampusConnectAppState extends State<CampusConnectApp> {
  late bool isDarkMode;
  
  @override
  void initState() {
    super.initState();
    isDarkMode = widget.appState.isDarkMode;
    
    // Listen for changes to dark mode preference
    widget.appState.addListener(() {
      if (mounted && isDarkMode != widget.appState.isDarkMode) {
        setState(() {
          isDarkMode = widget.appState.isDarkMode;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusConnect',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // User is signed in, show the main app (replace with your main home widget)
            return MainNavigationScreen(appState: widget.appState);
          } else {
            // Not signed in
            return const AuthScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final AppState appState;
  
  const MainNavigationScreen({super.key, required this.appState});

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(appState: widget.appState),
      ClassScheduleScreen(appState: widget.appState),
      StudyGroupScreen(appState: widget.appState),
      CampusEventScreen(appState: widget.appState),
      NotesScreen(appState: widget.appState),
      ProfileScreen(appState: widget.appState),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Study Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}