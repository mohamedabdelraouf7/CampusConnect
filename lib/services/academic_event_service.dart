import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/academic_event_model.dart';

class AcademicEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Collection reference
  CollectionReference get _eventsCollection => 
      _firestore.collection('users').doc(_auth.currentUser?.uid).collection('academic_events');
  
  // Stream of academic events
  Stream<List<AcademicEvent>> getEvents() {
    return _eventsCollection
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get events for a specific date range
  Stream<List<AcademicEvent>> getEventsInRange(DateTime start, DateTime end) {
    return _eventsCollection
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get upcoming events
  Stream<List<AcademicEvent>> getUpcomingEvents() {
    final now = DateTime.now();
    return _eventsCollection
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .limit(10)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get overdue events
  Stream<List<AcademicEvent>> getOverdueEvents() {
    final now = DateTime.now();
    return _eventsCollection
        .where('dueDate', isLessThan: Timestamp.fromDate(now))
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
  
  // Add a new academic event
  Future<void> addEvent(AcademicEvent event) async {
    await _eventsCollection.doc(event.id).set(event.toFirestore());
  }
  
  // Update an academic event
  Future<void> updateEvent(AcademicEvent event) async {
    await _eventsCollection.doc(event.id).update(event.toFirestore());
  }
  
  // Delete an academic event
  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }
  
  // Mark an event as completed
  Future<void> markAsCompleted(String eventId, bool completed) async {
    await _eventsCollection.doc(eventId).update({
      'isCompleted': completed,
      'updatedAt': Timestamp.now(),
    });
  }
  
  // Get events for a specific course
  Stream<List<AcademicEvent>> getEventsForCourse(String courseCode) {
    return _eventsCollection
        .where('courseCode', isEqualTo: courseCode)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get events by type
  Stream<List<AcademicEvent>> getEventsByType(AcademicEventType type) {
    return _eventsCollection
        .where('type', isEqualTo: type.toString())
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get upcoming exams
  Stream<List<AcademicEvent>> getUpcomingExams() {
    final now = DateTime.now();
    return _eventsCollection
        .where('type', isEqualTo: AcademicEventType.exam.toString())
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
  
  // Get upcoming assignments
  Stream<List<AcademicEvent>> getUpcomingAssignments() {
    final now = DateTime.now();
    return _eventsCollection
        .where('type', isEqualTo: AcademicEventType.assignment.toString())
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .where('isCompleted', isEqualTo: false)
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AcademicEvent.fromFirestore(doc))
          .toList();
    });
  }
} 