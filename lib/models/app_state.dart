import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'class_model.dart';
import 'event_model.dart';
import 'study_group_model.dart';
import 'note_model.dart';
import 'notification_model.dart';
import '../utils/database_helper.dart';
import '../services/firebase_service.dart';
import 'announcement_model.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  final DatabaseHelper dbHelper = DatabaseHelper();
  
  List<ClassModel> classes = [];
  List<EventModel> events = [];
  List<StudyGroupModel> studyGroups = [];
  List<NoteModel> notes = [];
  List<NotificationModel> notifications = [];
  
  // User preferences
  bool _isDarkMode = false;
  String userName = 'Student';
  String userEmail = 'student@example.com';
  
  bool get isDarkMode => _isDarkMode;
  
  set isDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      savePreferences();
      notifyListeners();
    }
  }
  
  // Notification preferences
  bool enableClassReminders = true;
  bool enableEventReminders = true;
  bool enableStudyGroupReminders = true;
  bool enableDeadlineReminders = true;
  int classReminderMinutes = 30;
  int eventReminderMinutes = 60;
  int studyGroupReminderMinutes = 60;
  List<int> deadlineReminderTimes = [60, 1440, 4320]; // 1 hour, 1 day, 3 days
  
  // Constructor that properly initializes the prefs variable
  AppState(this.prefs) {
    _loadPreferences();
    _loadLocalData();
    _initializeFirebase();
  }
  
  final FirebaseService firebaseService = FirebaseService();
  List<AnnouncementModel> announcements = [];
  
  // Add this method to initialize Firebase
  Future<void> _initializeFirebase() async {
    await firebaseService.initialize();
    _setupFirebaseListeners();
  }
  
  // Add this method to set up Firebase listeners
  void _setupFirebaseListeners() {
    // Listen for study group changes
    firebaseService.getStudyGroupsStream().listen((groups) {
      studyGroups = groups;
      notifyListeners();
    });
    
    // Listen for event changes
    firebaseService.getEventsStream().listen((eventsList) {
      events = eventsList;
      notifyListeners();
    });
    
    // Listen for announcements
    firebaseService.getAnnouncementsStream().listen((announcementsList) {
      announcements = announcementsList;
      notifyListeners();
    });
  }
  
  // Load data from local database
  Future<void> _loadLocalData() async {
    try {
      classes = await dbHelper.getClasses();
      
      // Only load these from local if we're offline
      if (studyGroups.isEmpty) {
        studyGroups = await dbHelper.getStudyGroups();
      }
      
      if (events.isEmpty) {
        events = await dbHelper.getEvents();
      }
      
      notes = await dbHelper.getNotes();
      notifyListeners();
    } catch (e) {
      print('Error loading local data: $e');
    }
  }
  
  // Fix the addStudyGroupNote method - it was nested inside _loadPreferences
  void addStudyGroupNote(String groupId, String title, String content, String authorName) {
    firebaseService.addStudyGroupNote(groupId, title, content, authorName);
  }
  
  void _loadPreferences() {
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    userName = prefs.getString('userName') ?? 'Student';
    userEmail = prefs.getString('userEmail') ?? 'student@example.com';
    
    // Load notification preferences
    enableClassReminders = prefs.getBool('enableClassReminders') ?? true;
    enableEventReminders = prefs.getBool('enableEventReminders') ?? true;
    enableStudyGroupReminders = prefs.getBool('enableStudyGroupReminders') ?? true;
    enableDeadlineReminders = prefs.getBool('enableDeadlineReminders') ?? true;
    classReminderMinutes = prefs.getInt('classReminderMinutes') ?? 30;
    eventReminderMinutes = prefs.getInt('eventReminderMinutes') ?? 60;
    studyGroupReminderMinutes = prefs.getInt('studyGroupReminderMinutes') ?? 60;
    deadlineReminderTimes = prefs.getStringList('deadlineReminderTimes')?.map(int.parse).toList() ?? [60, 1440, 4320];

    // Load notifications from SharedPreferences
    final notificationsJson = prefs.getStringList('notifications') ?? [];
    notifications = notificationsJson
        .map((json) => NotificationModel.fromJson(jsonDecode(json)))
        .toList();
  }
  
  // Save preferences
  Future<void> savePreferences() async {
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('userName', userName);
    await prefs.setString('userEmail', userEmail);
    
    // Save notification preferences
    await prefs.setBool('enableClassReminders', enableClassReminders);
    await prefs.setBool('enableEventReminders', enableEventReminders);
    await prefs.setBool('enableStudyGroupReminders', enableStudyGroupReminders);
    await prefs.setBool('enableDeadlineReminders', enableDeadlineReminders);
    await prefs.setInt('classReminderMinutes', classReminderMinutes);
    await prefs.setInt('eventReminderMinutes', eventReminderMinutes);
    await prefs.setInt('studyGroupReminderMinutes', studyGroupReminderMinutes);
    await prefs.setStringList('deadlineReminderTimes', deadlineReminderTimes.map((e) => e.toString()).toList());
  }
  
  Future<void> _loadData() async {
    if (kIsWeb) {
      // For web, either load data from a different source or use empty lists
      classes = [];
      events = [];
      studyGroups = [];
      notes = [];
      return;
    }
    
    // Load data from SQLite for non-web platforms
    classes = await dbHelper.getClasses();
    events = await dbHelper.getEvents();
    studyGroups = await dbHelper.getStudyGroups();
    notes = await dbHelper.getNotes();
  }
  
  // Save notifications
  Future<void> saveNotifications() async {
    final notificationsJson = notifications
        .map((notification) => jsonEncode(notification.toJson()))
        .toList();
    await prefs.setStringList('notifications', notificationsJson);
  }
  
  // Class methods
  Future<void> addClass(ClassModel classModel) async {
    await dbHelper.insertClass(classModel);
    classes = await dbHelper.getClasses();
  }
  
  Future<void> updateClass(ClassModel classModel) async {
    await dbHelper.updateClass(classModel);
    classes = await dbHelper.getClasses();
  }
  
  Future<void> deleteClass(String id) async {
    await dbHelper.deleteClass(id);
    classes = await dbHelper.getClasses();
  }
  
  Future<void> saveClasses() async {
    // This method is kept for backward compatibility
    // Now we save each class individually when it's added/updated/deleted
  }
  
  // Event methods
  Future<void> addEvent(EventModel event) async {
    await dbHelper.insertEvent(event);
    events = await dbHelper.getEvents();
  }
  
  Future<void> updateEvent(EventModel event) async {
    await dbHelper.updateEvent(event);
    events = await dbHelper.getEvents();
  }
  
  Future<void> deleteEvent(String id) async {
    await dbHelper.deleteEvent(id);
    events = await dbHelper.getEvents();
  }
  
  Future<void> saveEvents() async {
    // This method is kept for backward compatibility
    // Now we save each event individually when it's added/updated/deleted
  }
  
  // Study group methods
  Future<void> addStudyGroup(StudyGroupModel studyGroup) async {
    await dbHelper.insertStudyGroup(studyGroup);
    studyGroups = await dbHelper.getStudyGroups();
  }
  
  Future<void> updateStudyGroup(StudyGroupModel studyGroup) async {
    await dbHelper.updateStudyGroup(studyGroup);
    studyGroups = await dbHelper.getStudyGroups();
  }
  
  Future<void> deleteStudyGroup(String id) async {
    await dbHelper.deleteStudyGroup(id);
    studyGroups = await dbHelper.getStudyGroups();
  }
  
  Future<void> saveStudyGroups() async {
    // This method is kept for backward compatibility
    // Now we save each study group individually when it's added/updated/deleted
  }
  
  // Note methods
  Future<void> addNote(NoteModel note) async {
    await dbHelper.insertNote(note);
    notes = await dbHelper.getNotes();
  }
  
  Future<void> updateNote(NoteModel note) async {
    await dbHelper.updateNote(note);
    notes = await dbHelper.getNotes();
  }
  
  Future<void> deleteNote(String id) async {
    await dbHelper.deleteNote(id);
    notes = await dbHelper.getNotes();
  }
  
  // Helper methods
  List<dynamic> getUpcomingItems() {
    final now = DateTime.now();
    final oneWeekLater = now.add(const Duration(days: 7));
    
    // Get upcoming classes for today
    final todayClasses = classes.where((c) => c.dayOfWeek == now.weekday).toList();
    
    // Get upcoming events within the next week
    final upcomingEvents = events.where((e) => 
      e.dateTime.isAfter(now) && e.dateTime.isBefore(oneWeekLater)
    ).toList();
    
    // Get upcoming study groups within the next week
    final upcomingStudyGroups = studyGroups.where((sg) => 
      sg.dateTime.isAfter(now) && sg.dateTime.isBefore(oneWeekLater)
    ).toList();
    
    // Combine and sort all items
    final allItems = [...todayClasses, ...upcomingEvents, ...upcomingStudyGroups];
    
    // Sort by date/time
    allItems.sort((a, b) {
      DateTime timeA;
      DateTime timeB;
      
      if (a is ClassModel) {
        // Convert class time to today's date
        final now = DateTime.now();
        timeA = DateTime(
          now.year, 
          now.month, 
          now.day,
          a.startTime.hour,
          a.startTime.minute,
        );
      } else if (a is EventModel) {
        timeA = a.dateTime;
      } else if (a is StudyGroupModel) {
        timeA = a.dateTime;
      } else {
        // Default case
        timeA = now;
      }
      
      if (b is ClassModel) {
        // Convert class time to today's date
        final now = DateTime.now();
        timeB = DateTime(
          now.year, 
          now.month, 
          now.day,
          b.startTime.hour,
          b.startTime.minute,
        );
      } else if (b is EventModel) {
        timeB = b.dateTime;
      } else if (b is StudyGroupModel) {
        timeB = b.dateTime;
      } else {
        // Default case
        timeB = now;
      }
      
      return timeA.compareTo(timeB);
    });
    
    return allItems;
  }
}