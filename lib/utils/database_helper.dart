import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/class_model.dart';
import '../models/event_model.dart';
import '../models/study_group_model.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper({String name = 'campus_connect.db'}) => _instance;
  
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'campus_connect.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }
  
  Future<void> _createDb(Database db, int version) async {
    // Create classes table
    await db.execute('''
      CREATE TABLE classes(
        id TEXT PRIMARY KEY,
        courseCode TEXT,
        courseName TEXT,
        professor TEXT,
        location TEXT,
        dayOfWeek INTEGER,
        startTime TEXT,
        endTime TEXT,
        notes TEXT
      )
    ''');
    
    // Create events table
    await db.execute('''
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        location TEXT,
        date TEXT,
        startTime TEXT,
        endTime TEXT,
        category TEXT,
        isRsvped INTEGER
      )
    ''');
    
    // Create study groups table
    await db.execute('''
      CREATE TABLE study_groups(
        id TEXT PRIMARY KEY,
        topic TEXT,
        courseCode TEXT,
        courseName TEXT,
        date TEXT,
        time TEXT,
        location TEXT,
        description TEXT,
        maxParticipants INTEGER,
        currentParticipants INTEGER
      )
    ''');
    
    // Create notes table
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        dateCreated TEXT,
        lastModified TEXT,
        courseId TEXT,
        color INTEGER
      )
    ''');
  }
  
  // Class CRUD operations
  Future<int> insertClass(ClassModel classModel) async {
    Database db = await database;
    return await db.insert('classes', classModel.toJson());
  }
  
  Future<List<ClassModel>> getClasses() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) => ClassModel.fromJson(maps[i]));
  }
  
  Future<int> updateClass(ClassModel classModel) async {
    Database db = await database;
    return await db.update(
      'classes',
      classModel.toJson(),
      where: 'id = ?',
      whereArgs: [classModel.id],
    );
  }
  
  Future<int> deleteClass(String id) async {
    Database db = await database;
    return await db.delete(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Event CRUD operations
  Future<int> insertEvent(EventModel event) async {
    Database db = await database;
    return await db.insert('events', event.toJson());
  }
  
  Future<List<EventModel>> getEvents() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) => EventModel.fromJson(maps[i]));
  }
  
  Future<int> updateEvent(EventModel event) async {
    Database db = await database;
    return await db.update(
      'events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }
  
  Future<int> deleteEvent(String id) async {
    Database db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Study Group CRUD operations
  Future<int> insertStudyGroup(StudyGroupModel group) async {
    Database db = await database;
    return await db.insert('study_groups', group.toJson());
  }
  
  Future<List<StudyGroupModel>> getStudyGroups() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_groups');
    return List.generate(maps.length, (i) => StudyGroupModel.fromJson(maps[i]));
  }
  
  Future<int> updateStudyGroup(StudyGroupModel group) async {
    Database db = await database;
    return await db.update(
      'study_groups',
      group.toJson(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }
  
  Future<int> deleteStudyGroup(String id) async {
    Database db = await database;
    return await db.delete(
      'study_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Note CRUD operations
  Future<int> insertNote(NoteModel note) async {
    Database db = await database;
    return await db.insert('notes', note.toJson());
  }
  
  Future<List<NoteModel>> getNotes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
  }
  
  Future<List<NoteModel>> getNotesByCourse(String courseId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
  }
  
  Future<int> updateNote(NoteModel note) async {
    Database db = await database;
    return await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  Future<int> deleteNote(String id) async {
    Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Utility methods
  Future<void> clearDatabase() async {
    Database db = await database;
    await db.delete('classes');
    await db.delete('events');
    await db.delete('study_groups');
    await db.delete('notes');
  }
}