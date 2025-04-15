import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database - conditionally based on platform
  if (!kIsWeb) {
    await DatabaseHelper().database;
    
    // Initialize notification service - only for non-web platforms
    await NotificationService().init();
  }
  
  // Initialize app state with shared preferences
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState(prefs);
  
  runApp(CampusConnectApp(appState: appState));
}

class CampusConnectApp extends StatefulWidget {
  final AppState appState;
  
  const CampusConnectApp({Key? key, required this.appState}) : super(key: key);

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
      home: MainNavigationScreen(appState: widget.appState),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final AppState appState;
  
  const MainNavigationScreen({Key? key, required this.appState}) : super(key: key);

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