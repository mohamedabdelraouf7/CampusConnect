import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/class_model.dart';
import '../models/event_model.dart';
import '../models/study_group_model.dart';
import '../models/note_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper({String name = 'campus_connect.db'}) => _instance;
  
  DatabaseHelper._internal() {
    if (Platform.isWindows || Platform.isLinux) {
      // Initialize FFI for Windows/Linux
      sqfliteFfiInit();
      // Change the default factory
      databaseFactory = databaseFactoryFfi;
    }
  }
  
  static Database? _database;
  
  Future<Database> get database async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'campus_connect.db');
    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _createDb(Database db, int version) async {
    // Create classes table
    await db.execute('''
      CREATE TABLE classes(
        id TEXT PRIMARY KEY,
        courseCode TEXT,
        name TEXT,
        professor TEXT,
        location TEXT,
        dayOfWeek INTEGER,
        startTimeHour INTEGER,
        startTimeMinute INTEGER,
        endTimeHour INTEGER,
        endTimeMinute INTEGER,
        notes TEXT
      )
    ''');
    
    // Create events table
    await db.execute('''
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        dateTime TEXT,
        location TEXT,
        organizer TEXT,
        attendees TEXT,
        imageUrl TEXT,
        category TEXT,
        maxAttendees INTEGER
      )
    ''');
    
    // Create study groups table
    await db.execute('''
      CREATE TABLE study_groups(
        id TEXT PRIMARY KEY,
        topic TEXT,
        courseCode TEXT,
        courseName TEXT,
        dateTime INTEGER,
        time TEXT,
        location TEXT,
        description TEXT,
        createdBy TEXT,
        maxParticipants INTEGER,
        participants TEXT,
        isJoined INTEGER
      )
    ''');
    
    // Create notes table
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        title TEXT,
        content TEXT,
        dateCreated TEXT,
        dateModified TEXT,
        color INTEGER,
        isPinned INTEGER
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the new 'name' column
      await db.execute('ALTER TABLE classes ADD COLUMN name TEXT');
      
      // Copy data from courseName to name
      await db.execute('UPDATE classes SET name = courseName');
      
      // Drop the old courseName column
      // Note: SQLite doesn't support DROP COLUMN directly, so we need to:
      // 1. Create a temporary table with the new schema
      // 2. Copy data to the temp table
      // 3. Drop the old table
      // 4. Rename the temp table
      await db.execute('''
        CREATE TABLE classes_temp(
          id TEXT PRIMARY KEY,
          courseCode TEXT,
          name TEXT,
          professor TEXT,
          location TEXT,
          dayOfWeek INTEGER,
          startTime TEXT,
          endTime TEXT,
          notes TEXT
        )
      ''');
      
      await db.execute('''
        INSERT INTO classes_temp 
        SELECT id, courseCode, name, professor, location, dayOfWeek, startTime, endTime, notes 
        FROM classes
      ''');
      
      await db.execute('DROP TABLE classes');
      await db.execute('ALTER TABLE classes_temp RENAME TO classes');
    }
    if (oldVersion < 3) {
      final eventColumns = (await db.rawQuery("PRAGMA table_info(events)")).map((c) => c['name'] as String).toSet();
      if (!eventColumns.contains('dateTime')) {
        await db.execute("ALTER TABLE events ADD COLUMN dateTime TEXT");
      }
      if (!eventColumns.contains('attendees')) {
        await db.execute("ALTER TABLE events ADD COLUMN attendees TEXT");
      }
      if (!eventColumns.contains('imageUrl')) {
        await db.execute("ALTER TABLE events ADD COLUMN imageUrl TEXT");
      }
      if (!eventColumns.contains('category')) {
        await db.execute("ALTER TABLE events ADD COLUMN category TEXT");
      }
      if (!eventColumns.contains('maxAttendees')) {
        await db.execute("ALTER TABLE events ADD COLUMN maxAttendees INTEGER");
      }
      // --- STUDY_GROUPS TABLE ---
      final groupColumns = (await db.rawQuery("PRAGMA table_info(study_groups)")).map((c) => c['name'] as String).toSet();
      if (!groupColumns.contains('dateTime')) {
        await db.execute("ALTER TABLE study_groups ADD COLUMN dateTime INTEGER");
      }
      if (!groupColumns.contains('participants')) {
        await db.execute("ALTER TABLE study_groups ADD COLUMN participants TEXT");
      }
      if (!groupColumns.contains('isJoined')) {
        await db.execute("ALTER TABLE study_groups ADD COLUMN isJoined INTEGER");
      }
      // --- CLASSES TABLE ---
      final classColumns = (await db.rawQuery("PRAGMA table_info(classes)")).map((c) => c['name'] as String).toSet();
      if (!classColumns.contains('startTimeHour')) {
        await db.execute("ALTER TABLE classes ADD COLUMN startTimeHour INTEGER");
      }
      if (!classColumns.contains('startTimeMinute')) {
        await db.execute("ALTER TABLE classes ADD COLUMN startTimeMinute INTEGER");
      }
      if (!classColumns.contains('endTimeHour')) {
        await db.execute("ALTER TABLE classes ADD COLUMN endTimeHour INTEGER");
      }
      if (!classColumns.contains('endTimeMinute')) {
        await db.execute("ALTER TABLE classes ADD COLUMN endTimeMinute INTEGER");
      }
    }
    if (oldVersion < 4) {
      // Add missing columns for notes and study groups
      final noteColumns = (await db.rawQuery("PRAGMA table_info(notes)")).map((c) => c['name'] as String).toSet();
      if (!noteColumns.contains('dateModified')) {
        await db.execute("ALTER TABLE notes ADD COLUMN dateModified TEXT");
      }
      if (!noteColumns.contains('isPinned')) {
        await db.execute("ALTER TABLE notes ADD COLUMN isPinned INTEGER");
      }
      
      // Add createdBy column to study_groups if it doesn't exist
      final groupColumns = (await db.rawQuery("PRAGMA table_info(study_groups)")).map((c) => c['name'] as String).toSet();
      if (!groupColumns.contains('createdBy')) {
        await db.execute("ALTER TABLE study_groups ADD COLUMN createdBy TEXT");
      }
      
      // Add organizer column to events if it doesn't exist
      final eventColumns = (await db.rawQuery("PRAGMA table_info(events)")).map((c) => c['name'] as String).toSet();
      if (!eventColumns.contains('organizer')) {
        await db.execute("ALTER TABLE events ADD COLUMN organizer TEXT");
      }
    }
    if (oldVersion < 5) {
      // Ensure notes table has all required columns
      final noteColumns = (await db.rawQuery("PRAGMA table_info(notes)")).map((c) => c['name'] as String).toSet();
      
      // Add isPinned column if it doesn't exist
      if (!noteColumns.contains('isPinned')) {
        await db.execute("ALTER TABLE notes ADD COLUMN isPinned INTEGER DEFAULT 0");
      }
      
      // Add dateModified column if it doesn't exist
      if (!noteColumns.contains('dateModified')) {
        await db.execute("ALTER TABLE notes ADD COLUMN dateModified TEXT");
        // Copy dateCreated to dateModified for existing notes
        await db.execute("UPDATE notes SET dateModified = dateCreated WHERE dateModified IS NULL");
      }
    }
  }
  
  // Class CRUD operations
  Future<int> insertClass(ClassModel classModel) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.insert('classes', classModel.toJson());
  }
  
  Future<List<ClassModel>> getClasses() async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classes');
    return List.generate(maps.length, (i) => ClassModel.fromJson(maps[i]));
  }
  
  Future<int> updateClass(ClassModel classModel) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.update(
      'classes',
      classModel.toJson(),
      where: 'id = ?',
      whereArgs: [classModel.id],
    );
  }
  
  Future<int> deleteClass(String id) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.delete(
      'classes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Event CRUD operations
  Future<int> insertEvent(EventModel event) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.insert(
      'events',
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<EventModel>> getEvents() async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) => EventModel.fromJson(maps[i]));
  }
  
  Future<int> updateEvent(EventModel event) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.update(
      'events',
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }
  
  Future<int> deleteEvent(String id) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Study Group CRUD operations
  Future<int> insertStudyGroup(StudyGroupModel group) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.insert(
      'study_groups',
      group.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  Future<List<StudyGroupModel>> getStudyGroups() async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('study_groups');
    return List.generate(maps.length, (i) => StudyGroupModel.fromJson(maps[i]));
  }
  
  Future<int> updateStudyGroup(StudyGroupModel group) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.update(
      'study_groups',
      group.toJson(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }
  
  Future<int> deleteStudyGroup(String id) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.delete(
      'study_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Note CRUD operations
  Future<int> insertNote(NoteModel note) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.insert('notes', note.toJson());
  }
  
  Future<List<NoteModel>> getNotes() async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
  }
  
  Future<List<NoteModel>> getNotesByCourse(String courseId) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );
    return List.generate(maps.length, (i) => NoteModel.fromJson(maps[i]));
  }
  
  Future<int> updateNote(NoteModel note) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.update(
      'notes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
  
  Future<int> deleteNote(String id) async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // Utility methods
  Future<void> clearDatabase() async {
    if (kIsWeb) throw UnsupportedError('Local database is not supported on web.');
    Database db = await database;
    await db.delete('classes');
    await db.delete('events');
    await db.delete('study_groups');
    await db.delete('notes');
  }
}