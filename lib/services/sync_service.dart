import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/database_helper.dart';
import 'firebase_service.dart';
import '../models/study_group_model.dart';
import '../models/event_model.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  
  final DatabaseHelper _localDb = DatabaseHelper();
  final FirebaseService _firebaseService = FirebaseService();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isOnline = false;
  
  SyncService._internal();
  
  Future<void> initialize() async {
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
    
    // Check initial connection status
    final connectivityResult = await Connectivity().checkConnectivity();
    _updateConnectionStatus(connectivityResult);
  }
  
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    // If we just came back online, sync data
    if (!wasOnline && _isOnline) {
      syncData();
    }
  }
  
  Future<void> syncData() async {
    if (!_isOnline) return;
    
    await _syncStudyGroups();
    await _syncEvents();
  }
  
  Future<void> _syncStudyGroups() async {
    // Get local study groups that might have been modified offline
    final localGroups = await _localDb.getStudyGroups();
    
    // Push each local group to Firebase
    for (var group in localGroups) {
      await _firebaseService.addOrUpdateStudyGroup(group);
    }
  }
  
  Future<void> _syncEvents() async {
    // Get local events that might have been modified offline
    final localEvents = await _localDb.getEvents();
    
    // Push each local event to Firebase
    for (var event in localEvents) {
      await _firebaseService.addOrUpdateEvent(event);
    }
  }
  
  void dispose() {
    _connectivitySubscription.cancel();
  }
}