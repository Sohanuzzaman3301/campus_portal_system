1. import 'dart:io';
   import 'package:path/path.dart';
   import 'package:path_provider/path_provider.dart';
   import 'package:sqflite_common_ffi/sqflite_ffi.dart';
   
   class DatabaseConfig {
     static Future<void> initializeDatabase() async {
   
       if (Platform.isAndroid || Platform.isIOS) {
         // Use default factory for mobile platforms
         // No need to initialize anything special
         return;
       } else {
         // For desktop/web platforms, use FFI
         sqfliteFfiInit();
         databaseFactory = databaseFactoryFfi;
       }
   
     }
   
     static Future<String> getDatabasePath(String dbName) async {
   
       if (Platform.isAndroid || Platform.isIOS) {
         final documentsDirectory = await getApplicationDocumentsDirectory();
         return join(documentsDirectory.path, dbName);
       } else {
         return join(await getDatabasesPath(), dbName);
       }
   
     }
   
     static Future<Database> openDatabase(
   
       String path, {
       required int version,
       required OnDatabaseCreateFn onCreate,
       OnDatabaseVersionChangeFn? onUpgrade,
   
     }) async {
   
       return await databaseFactory.openDatabase(
         path,
         options: OpenDatabaseOptions(
           version: version,
           onCreate: onCreate,
           onUpgrade: onUpgrade,
         ),
       );
   
     }
   }

2.

import 'package:campus_portal_system/database/database_config.dart';
import 'package:sqflite/sqflite.dart';
import 'major_database_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  late final MajorDatabaseHelper majorDatabaseHelper;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('campus_portal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      print('\n=== Starting Database Initialization ===');
      await DatabaseConfig.initializeDatabase();
      final path = await DatabaseConfig.getDatabasePath(filePath);
      print('Database path: $path');

      final db = await openDatabase(
        path,
        version: 2,
        onCreate: _createAllTables,
        onUpgrade: (db, oldVersion, newVersion) async {
          print('Upgrading database from v$oldVersion to v$newVersion');
          await _createAllTables(db, newVersion);
        },
      );
    
      await _verifyDatabaseStructure(db);
      return db;
    } catch (e, stackTrace) {
      _logDatabaseError('Database initialization error', e, stackTrace);
      rethrow;
    }

  }

  Future<void> _createAllTables(Database db, int version) async {
    try {
      print('\n=== Creating All Database Tables ===');
      await _createAuthTables(db);
      await _createAcademicTables(db);
      await _createLibraryTables(db);
      print('=== All Tables Created Successfully ===\n');
    } catch (e, stackTrace) {
      _logDatabaseError('Table creation error', e, stackTrace);
      rethrow;
    }
  }

  // Table Creation Methods
  Future<void> _createAuthTables(Database db) async {
    print('Creating users table...');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      role TEXT NOT NULL,
      is_verified BOOLEAN DEFAULT 0,
      student_id TEXT,
      instructor_id TEXT,
      FOREIGN KEY (student_id) REFERENCES students (student_id),
      FOREIGN KEY (instructor_id) REFERENCES instructors (instructor_id)
    )
    ''');
    print('✓ Users table created');
  }

  Future<void> _createAcademicTables(Database db) async {
    // Create majors table first
    print('Creating majors table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS majors (
        major_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        department TEXT NOT NULL
      )
    ''');
    print('✓ Majors table created');

    // Create instructors table
    print('Creating instructors table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS instructors (
        instructor_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        department TEXT,
        major_id TEXT,
        FOREIGN KEY (major_id) REFERENCES majors (major_id)
      )
    ''');
    print('✓ Instructors table created');
    
    // Create courses table with major reference
    print('Creating courses table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS courses (
        course_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        major_id TEXT NOT NULL,
        instructor_id TEXT,
        credits INTEGER NOT NULL,
        semester TEXT NOT NULL,
        FOREIGN KEY (major_id) REFERENCES majors (major_id),
        FOREIGN KEY (instructor_id) REFERENCES instructors (instructor_id)
      )
    ''');
    print('✓ Courses table created');
    
    // Update students table to include major reference
    print('Creating students table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS students (
        student_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        major_id TEXT,
        FOREIGN KEY (major_id) REFERENCES majors (major_id)
      )
    ''');
    print('✓ Students table created');
    
    // Create enrollments table
    print('Creating enrollments table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS enrollments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT,
        course_id TEXT,
        enrollment_date TEXT,
        status TEXT,
        grade TEXT,
        FOREIGN KEY (student_id) REFERENCES students (student_id),
        FOREIGN KEY (course_id) REFERENCES courses (course_id)
      )
    ''');
    print('✓ Enrollments table created');

  }

  Future<void> _createLibraryTables(Database db) async {
    // Create books table
    print('Creating books table...');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS books (
      book_id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      author TEXT NOT NULL,
      description TEXT,
      cover_url TEXT,
      isbn TEXT,
      category TEXT
    )
    ''');
    print('✓ Books table created');

    // Create borrow transactions table
    print('Creating borrow_transactions table...');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS borrow_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      book_id TEXT,
      borrower_id TEXT,
      borrow_date TEXT,
      return_date TEXT,
      FOREIGN KEY (book_id) REFERENCES books (book_id),
      FOREIGN KEY (borrower_id) REFERENCES students (student_id)
    )
    ''');
    print('✓ Borrow transactions table created');

  }

  // Library Operations
  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final db = await database;
    return await db.query('books');
  }

  Future<String> insertBook(Map<String, dynamic> book) async {
    final db = await database;
    await db.insert('books', book);
    return book['book_id'];
  }

  Future<void> insertBooks(List<Map<String, dynamic>> books) async {
    final db = await database;
    final batch = db.batch();
    for (final book in books) {
      batch.insert('books', book, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<int> borrowBook(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('borrow_transactions', transaction);
  }

  Future<int> returnBook(String bookId, String borrowerId) async {
    final db = await database;
    return await db.update(
      'borrow_transactions',
      {'return_date': DateTime.now().toIso8601String()},
      where: 'book_id = ? AND borrower_id = ? AND return_date IS NULL',
      whereArgs: [bookId, borrowerId],
    );
  }

  // Database Management
  Future<void> deleteDatabase() async {
    try {
      print('Attempting to delete database...');
      final path = await DatabaseConfig.getDatabasePath('campus_portal.db');
      await databaseFactory.deleteDatabase(path);
      _database = null;
      print('Database deleted successfully');
    } catch (e) {
      print('Error deleting database: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Helper Methods
  Future<void> _verifyDatabaseStructure(Database db) async {
    print('\n=== Verifying Database Structure ===');
    final tables = await db.query(
      'sqlite_master',
      where: 'type = ? AND name NOT LIKE ?',
      whereArgs: ['table', 'sqlite_%'],
    );

    final expectedTables = {
      'users',
      'instructors',
      'courses',
      'students',
      'enrollments',
      'books',
      'borrow_transactions'
    };
    
    final actualTables = tables.map((t) => t['name'] as String).toSet();
    _printTableVerification(expectedTables, actualTables);
    await _printTableStructures(db, actualTables);
    
    if (actualTables.length < expectedTables.length) {
      throw Exception(
          'Database initialization incomplete: Missing tables detected');
    }

  }

  void _printTableVerification(Set<String> expected, Set<String> actual) {
    print('\nTable Verification Results:');
    print('Expected tables count: ${expected.length}');
    print('Actual tables count: ${actual.length}');

    if (actual.length < expected.length) {
      print('\n⚠️ Missing Tables Detected:');
      final missingTables = expected.difference(actual);
      for (var table in missingTables) {
        print('❌ Missing table: $table');
      }
    }

  }

  Future<void> _printTableStructures(Database db, Set<String> tables) async {
    print('\nExisting Tables:');
    for (var table in tables) {
      final tableInfo = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', table],
      );
      print('✓ $table');
      print('  Structure: ${tableInfo.first['sql']}');
    }
    print('=== Database Verification Complete ===\n');
  }

  void _logDatabaseError(String message, Object error, StackTrace stackTrace) {
    print('\n=== Database Error ===');
    print('Error type: ${error.runtimeType}');
    print('Error message: $error');
    print('Stack trace:\n$stackTrace');
    print('=== End Database Error ===\n');
  }

  // Majors Operations
  Future<List<Map<String, dynamic>>> getAllMajors() async {
    final db = await database;
    return await db.query('majors');
  }

  Future<Map<String, dynamic>?> getMajorById(String majorId) async {
    final db = await database;
    final results = await db.query(
      'majors',
      where: 'major_id = ?',
      whereArgs: [majorId],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insertMajor(Map<String, dynamic> major) async {
    final db = await database;
    await db.insert('majors', major);
  }

  Future<void> seedDefaultMajors() async {
    print('\n=== Seeding Default Majors ===');
    final defaultMajors = [
      {
        'major_id': 'CS',
        'name': 'Computer Science',
        'description': 'Study of computation and information processing',
        'department': 'School of Computing'
      },
      {
        'major_id': 'EE',
        'name': 'Electrical Engineering',
        'description': 'Study of electrical systems and electronics',
        'department': 'School of Engineering'
      },
      {
        'major_id': 'BUS',
        'name': 'Business Administration',
        'description': 'Study of business management and operations',
        'department': 'School of Business'
      },
      {
        'major_id': 'MATH',
        'name': 'Mathematics',
        'description': 'Study of numbers, quantities, and shapes',
        'department': 'School of Sciences'
      },
    ];

    try {
      final db = await database;
      final batch = db.batch();
    
      for (var major in defaultMajors) {
        batch.insert('majors', major,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    
      await batch.commit(noResult: true);
      print('✓ Default majors seeded successfully');
    } catch (e) {
      print('Error seeding default majors: $e');
    }

  }

  // Course Operations
  Future<List<Map<String, dynamic>>> getCoursesByMajor(String majorId) async {
    final db = await database;
    return await db.query(
      'courses',
      where: 'major_id = ?',
      whereArgs: [majorId],
    );
  }

  Future<void> insertCourse(Map<String, dynamic> course) async {
    final db = await database;
    await db.insert('courses', course);
  }

  MajorDatabaseHelper get getMajorDatabaseHelper => majorDatabaseHelper;
}

3. import 'package:campus_portal_system/database/database_config.dart';
   import 'package:sqflite/sqflite.dart';
   import 'major_database_helper.dart';
   
   class DatabaseHelper {
     static final DatabaseHelper instance = DatabaseHelper._init();
     static Database? _database;
   
     DatabaseHelper._init();
   
     late final MajorDatabaseHelper majorDatabaseHelper;
   
     Future<Database> get database async {
   
       if (_database != null) return _database!;
       _database = await _initDB('campus_portal.db');
       return _database!;
   
     }
   
     Future<Database> _initDB(String filePath) async {
   
       try {
         print('\n=== Starting Database Initialization ===');
         await DatabaseConfig.initializeDatabase();
         final path = await DatabaseConfig.getDatabasePath(filePath);
         print('Database path: $path');
       
         final db = await openDatabase(
           path,
           version: 2,
           onCreate: _createAllTables,
           onUpgrade: (db, oldVersion, newVersion) async {
             print('Upgrading database from v$oldVersion to v$newVersion');
             await _createAllTables(db, newVersion);
           },
         );
       
         await _verifyDatabaseStructure(db);
         return db;
       } catch (e, stackTrace) {
         _logDatabaseError('Database initialization error', e, stackTrace);
         rethrow;
       }
   
     }
   
     Future<void> _createAllTables(Database db, int version) async {
   
       try {
         print('\n=== Creating All Database Tables ===');
         await _createAuthTables(db);
         await _createAcademicTables(db);
         await _createLibraryTables(db);
         print('=== All Tables Created Successfully ===\n');
       } catch (e, stackTrace) {
         _logDatabaseError('Table creation error', e, stackTrace);
         rethrow;
       }
   
     }
   
     // Table Creation Methods
     Future<void> _createAuthTables(Database db) async {
   
       print('Creating users table...');
       await db.execute('''
       CREATE TABLE IF NOT EXISTS users (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         name TEXT NOT NULL,
         email TEXT UNIQUE NOT NULL,
         password TEXT NOT NULL,
         role TEXT NOT NULL,
         is_verified BOOLEAN DEFAULT 0,
         student_id TEXT,
         instructor_id TEXT,
         FOREIGN KEY (student_id) REFERENCES students (student_id),
         FOREIGN KEY (instructor_id) REFERENCES instructors (instructor_id)
       )
       ''');
       print('✓ Users table created');
   
     }
   
     Future<void> _createAcademicTables(Database db) async {
   
       // Create majors table first
       print('Creating majors table...');
       await db.execute('''
         CREATE TABLE IF NOT EXISTS majors (
           major_id TEXT PRIMARY KEY,
           name TEXT NOT NULL,
           description TEXT,
           department TEXT NOT NULL
         )
       ''');
       print('✓ Majors table created');
       
       // Create instructors table
       print('Creating instructors table...');
       await db.execute('''
         CREATE TABLE IF NOT EXISTS instructors (
           instructor_id TEXT PRIMARY KEY,
           name TEXT NOT NULL,
           department TEXT,
           major_id TEXT,
           FOREIGN KEY (major_id) REFERENCES majors (major_id)
         )
       ''');
       print('✓ Instructors table created');
       
       // Create courses table with major reference
       print('Creating courses table...');
       await db.execute('''
         CREATE TABLE IF NOT EXISTS courses (
           course_id TEXT PRIMARY KEY,
           name TEXT NOT NULL,
           description TEXT,
           major_id TEXT NOT NULL,
           instructor_id TEXT,
           credits INTEGER NOT NULL,
           semester TEXT NOT NULL,
           FOREIGN KEY (major_id) REFERENCES majors (major_id),
           FOREIGN KEY (instructor_id) REFERENCES instructors (instructor_id)
         )
       ''');
       print('✓ Courses table created');
       
       // Update students table to include major reference
       print('Creating students table...');
       await db.execute('''
         CREATE TABLE IF NOT EXISTS students (
           student_id TEXT PRIMARY KEY,
           name TEXT NOT NULL,
           major_id TEXT,
           FOREIGN KEY (major_id) REFERENCES majors (major_id)
         )
       ''');
       print('✓ Students table created');
       
       // Create enrollments table
       print('Creating enrollments table...');
       await db.execute('''
         CREATE TABLE IF NOT EXISTS enrollments (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           student_id TEXT,
           course_id TEXT,
           enrollment_date TEXT,
           status TEXT,
           grade TEXT,
           FOREIGN KEY (student_id) REFERENCES students (student_id),
           FOREIGN KEY (course_id) REFERENCES courses (course_id)
         )
       ''');
       print('✓ Enrollments table created');
   
     }
   
     Future<void> _createLibraryTables(Database db) async {
   
       // Create books table
       print('Creating books table...');
       await db.execute('''
       CREATE TABLE IF NOT EXISTS books (
         book_id TEXT PRIMARY KEY,
         title TEXT NOT NULL,
         author TEXT NOT NULL,
         description TEXT,
         cover_url TEXT,
         isbn TEXT,
         category TEXT
       )
       ''');
       print('✓ Books table created');
       
       // Create borrow transactions table
       print('Creating borrow_transactions table...');
       await db.execute('''
       CREATE TABLE IF NOT EXISTS borrow_transactions (
         id INTEGER PRIMARY KEY AUTOINCREMENT,
         book_id TEXT,
         borrower_id TEXT,
         borrow_date TEXT,
         return_date TEXT,
         FOREIGN KEY (book_id) REFERENCES books (book_id),
         FOREIGN KEY (borrower_id) REFERENCES students (student_id)
       )
       ''');
       print('✓ Borrow transactions table created');
   
     }
   
     // Library Operations
     Future<List<Map<String, dynamic>>> getAllBooks() async {
   
       final db = await database;
       return await db.query('books');
   
     }
   
     Future<String> insertBook(Map<String, dynamic> book) async {
   
       final db = await database;
       await db.insert('books', book);
       return book['book_id'];
   
     }
   
     Future<void> insertBooks(List<Map<String, dynamic>> books) async {
   
       final db = await database;
       final batch = db.batch();
       for (final book in books) {
         batch.insert('books', book, conflictAlgorithm: ConflictAlgorithm.replace);
       }
       await batch.commit(noResult: true);
   
     }
   
     Future<int> borrowBook(Map<String, dynamic> transaction) async {
   
       final db = await database;
       return await db.insert('borrow_transactions', transaction);
   
     }
   
     Future<int> returnBook(String bookId, String borrowerId) async {
   
       final db = await database;
       return await db.update(
         'borrow_transactions',
         {'return_date': DateTime.now().toIso8601String()},
         where: 'book_id = ? AND borrower_id = ? AND return_date IS NULL',
         whereArgs: [bookId, borrowerId],
       );
   
     }
   
     // Database Management
     Future<void> deleteDatabase() async {
   
       try {
         print('Attempting to delete database...');
         final path = await DatabaseConfig.getDatabasePath('campus_portal.db');
         await databaseFactory.deleteDatabase(path);
         _database = null;
         print('Database deleted successfully');
       } catch (e) {
         print('Error deleting database: $e');
         rethrow;
       }
   
     }
   
     Future<void> close() async {
   
       final db = await database;
       db.close();
   
     }
   
     // Helper Methods
     Future<void> _verifyDatabaseStructure(Database db) async {
   
       print('\n=== Verifying Database Structure ===');
       final tables = await db.query(
         'sqlite_master',
         where: 'type = ? AND name NOT LIKE ?',
         whereArgs: ['table', 'sqlite_%'],
       );
       
       final expectedTables = {
         'users',
         'instructors',
         'courses',
         'students',
         'enrollments',
         'books',
         'borrow_transactions'
       };
       
       final actualTables = tables.map((t) => t['name'] as String).toSet();
       _printTableVerification(expectedTables, actualTables);
       await _printTableStructures(db, actualTables);
       
       if (actualTables.length < expectedTables.length) {
         throw Exception(
             'Database initialization incomplete: Missing tables detected');
       }
   
     }
   
     void _printTableVerification(Set<String> expected, Set<String> actual) {
   
       print('\nTable Verification Results:');
       print('Expected tables count: ${expected.length}');
       print('Actual tables count: ${actual.length}');
       
       if (actual.length < expected.length) {
         print('\n⚠️ Missing Tables Detected:');
         final missingTables = expected.difference(actual);
         for (var table in missingTables) {
           print('❌ Missing table: $table');
         }
       }
   
     }
   
     Future<void> _printTableStructures(Database db, Set<String> tables) async {
   
       print('\nExisting Tables:');
       for (var table in tables) {
         final tableInfo = await db.query(
           'sqlite_master',
           where: 'type = ? AND name = ?',
           whereArgs: ['table', table],
         );
         print('✓ $table');
         print('  Structure: ${tableInfo.first['sql']}');
       }
       print('=== Database Verification Complete ===\n');
   
     }
   
     void _logDatabaseError(String message, Object error, StackTrace stackTrace) {
   
       print('\n=== Database Error ===');
       print('Error type: ${error.runtimeType}');
       print('Error message: $error');
       print('Stack trace:\n$stackTrace');
       print('=== End Database Error ===\n');
   
     }
   
     // Majors Operations
     Future<List<Map<String, dynamic>>> getAllMajors() async {
   
       final db = await database;
       return await db.query('majors');
   
     }
   
     Future<Map<String, dynamic>?> getMajorById(String majorId) async {
   
       final db = await database;
       final results = await db.query(
         'majors',
         where: 'major_id = ?',
         whereArgs: [majorId],
       );
       return results.isNotEmpty ? results.first : null;
   
     }
   
     Future<void> insertMajor(Map<String, dynamic> major) async {
   
       final db = await database;
       await db.insert('majors', major);
   
     }
   
     Future<void> seedDefaultMajors() async {
   
       print('\n=== Seeding Default Majors ===');
       final defaultMajors = [
         {
           'major_id': 'CS',
           'name': 'Computer Science',
           'description': 'Study of computation and information processing',
           'department': 'School of Computing'
         },
         {
           'major_id': 'EE',
           'name': 'Electrical Engineering',
           'description': 'Study of electrical systems and electronics',
           'department': 'School of Engineering'
         },
         {
           'major_id': 'BUS',
           'name': 'Business Administration',
           'description': 'Study of business management and operations',
           'department': 'School of Business'
         },
         {
           'major_id': 'MATH',
           'name': 'Mathematics',
           'description': 'Study of numbers, quantities, and shapes',
           'department': 'School of Sciences'
         },
       ];
       
       try {
         final db = await database;
         final batch = db.batch();
       
         for (var major in defaultMajors) {
           batch.insert('majors', major,
               conflictAlgorithm: ConflictAlgorithm.ignore);
         }
       
         await batch.commit(noResult: true);
         print('✓ Default majors seeded successfully');
       } catch (e) {
         print('Error seeding default majors: $e');
       }
   
     }
   
     // Course Operations
     Future<List<Map<String, dynamic>>> getCoursesByMajor(String majorId) async {
   
       final db = await database;
       return await db.query(
         'courses',
         where: 'major_id = ?',
         whereArgs: [majorId],
       );
   
     }
   
     Future<void> insertCourse(Map<String, dynamic> course) async {
   
       final db = await database;
       await db.insert('courses', course);
   
     }
   
     MajorDatabaseHelper get getMajorDatabaseHelper => majorDatabaseHelper;
   }
   
   import 'package:sqflite/sqflite.dart';
   import 'package:campus_portal_system/models/user.dart';
   import 'database_helper.dart';
   
   class UserDatabaseHelper {
     static final UserDatabaseHelper instance = UserDatabaseHelper._init();
     final DatabaseHelper _dbHelper = DatabaseHelper.instance;
   
     UserDatabaseHelper._init();
   
     Future<Database> get database => _dbHelper.database;
   
     // User Operations
     Future<int> insertUser(Map<String, dynamic> user) async {
   
       try {
         final db = await database;
         print('Inserting user: $user');
         final id = await db.insert('users', user);
         print('User inserted with ID: $id');
         return id;
       } catch (e, stackTrace) {
         _logDatabaseError('Error inserting user', e, stackTrace);
         rethrow;
       }
   
     }
   
     Future<User?> getUserByEmail(String email) async {
   
       final db = await database;
       final results = await db.query(
         'users',
         where: 'email = ?',
         whereArgs: [email],
       );
       return results.isEmpty ? null : User.fromMap(results.first);
   
     }
   
     Future<List<User>> getAllUsers() async {
   
       final db = await database;
       final results = await db.query('users');
       return results.map((map) => User.fromMap(map)).toList();
   
     }
   
     Future<int> updateUser(User user) async {
   
       final db = await database;
       return await db.update(
         'users',
         user.toMap(),
         where: 'id = ?',
         whereArgs: [user.id],
       );
   
     }
   
     Future<int> deleteUser(int id) async {
   
       final db = await database;
       return await db.delete(
         'users',
         where: 'id = ?',
         whereArgs: [id],
       );
   
     }
   
     // Academic Operations
     Future<void> insertStudent(Map<String, dynamic> student) async {
   
       final db = await database;
       await db.insert('students', student);
   
     }
   
     Future<void> insertCourse(Map<String, dynamic> course) async {
   
       final db = await database;
       await db.insert('courses', course);
   
     }
   
     Future<void> enrollStudent(Map<String, dynamic> enrollment) async {
   
       final db = await database;
       await db.insert('enrollments', enrollment);
   
     }
   
     Future<List<Map<String, dynamic>>> getEnrolledCourses(String studentId) async {
   
       final db = await database;
       return await db.rawQuery('''
         SELECT e.*, c.name as course_name, c.department
         FROM enrollments e
         JOIN courses c ON e.course_id = c.course_id
         WHERE e.student_id = ?
       ''', [studentId]);
   
     }
   
     // Mock Data Operations
     Future<void> seedMockUsers() async {
   
       print('\n=== Seeding Mock Users ===');
       try {
         final db = await database;
         final batch = db.batch();
       
         // Add admin users
         for (var admin in _getMockAdmins()) {
           batch.insert('users', admin, conflictAlgorithm: ConflictAlgorithm.replace);
         }
       
         // Add teacher users
         for (var teacher in _getMockTeachers()) {
           batch.insert('users', teacher, conflictAlgorithm: ConflictAlgorithm.replace);
         }
       
         // Add student users
         for (var student in _getMockStudents()) {
           batch.insert('users', student, conflictAlgorithm: ConflictAlgorithm.replace);
         }
       
         await batch.commit(noResult: true);
         print('Successfully seeded mock users');
         print('=== Mock Users Seeding Complete ===\n');
       } catch (e, stackTrace) {
         _logDatabaseError('Error seeding mock users', e, stackTrace);
         rethrow;
       }
   
     }
   
     List<Map<String, dynamic>> _getMockAdmins() {
   
       return [
         {
           'name': 'John Smith',
           'email': 'admin@campus.edu',
           'password': 'admin123',
           'role': 'admin',
           'is_verified': 1,
         },
         {
           'name': 'Sarah Johnson',
           'email': 'sysadmin@campus.edu',
           'password': 'admin123',
           'role': 'admin',
           'is_verified': 1,
         },
       ];
   
     }
   
     List<Map<String, dynamic>> _getMockTeachers() {
   
       final teacherNames = [
         'Dr. Michael Brown', 'Prof. Emily Davis', 'Dr. James Wilson',
         'Prof. Jennifer Taylor', 'Dr. Robert Anderson', 'Prof. Elizabeth Thomas',
         'Dr. William Martinez', 'Prof. Patricia Moore', 'Dr. Richard Jackson',
         'Prof. Margaret White',
       ];
       
       return List.generate(
         10,
         (index) => {
           'name': teacherNames[index],
           'email': 'teacher${index + 1}@campus.edu',
           'password': 'teacher123',
           'role': 'instructor',
           'is_verified': 0,
         },
       );
   
     }
   
     List<Map<String, dynamic>> _getMockStudents() {
   
       final studentNames = [
         'David Miller', 'Emma Wilson', 'Alexander Lee', 'Sophia Chen',
         'Daniel Kim', 'Olivia Brown', 'Ethan Davis', 'Ava Garcia',
         'Matthew Thompson', 'Isabella Rodriguez', 'Andrew Johnson',
         'Mia Martinez', 'Christopher Lee', 'Charlotte Wright',
         'Joseph Anderson', 'Amelia Taylor', 'Benjamin Moore',
         'Harper White', 'Samuel Park', 'Victoria Chang',
         'Nicholas Adams', 'Grace Phillips', 'Ryan Murphy',
         'Zoe Bennett', 'Nathan Cooper', 'Lily Foster',
         'Jack Howard', 'Chloe Rivera', 'Luke Peterson',
         'Sophie Turner'
       ];
       
       return List.generate(
         30,
         (index) => {
           'name': studentNames[index],
           'email': 'student${index + 1}@campus.edu',
           'password': 'student123',
           'role': 'student',
           'is_verified': 0,
         },
       );
   
     }
   
     void _logDatabaseError(String message, Object error, StackTrace stackTrace) {
   
       print('\n=== Database Error ===');
       print('Error type: ${error.runtimeType}');
       print('Error message: $error');
       print('Stack trace:\n$stackTrace');
       print('=== End Database Error ===\n');
   
     }
   
     Future<void> createUserTable(Database db) async {
   
       await db.execute('''
         CREATE TABLE users (
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           name TEXT NOT NULL,
           email TEXT NOT NULL UNIQUE,
           password TEXT NOT NULL,
           role TEXT NOT NULL,
           is_verified INTEGER NOT NULL DEFAULT 0
         )
       ''');
   
     }
   
     // Get all unverified users
     Future<List<Map<String, dynamic>>> getUnverifiedUsers() async {
   
       final db = await database;
       const sql = '''
         SELECT * FROM users 
         WHERE is_verified = 0
         ORDER BY name
       ''';
       return await db.rawQuery(sql);
   
     }
   
     // Get all verified teachers
     Future<List<Map<String, dynamic>>> getVerifiedTeachers() async {
   
       final db = await database;
       const sql = '''
         SELECT * FROM users 
         WHERE role = 'teacher' 
         AND is_verified = 1
         ORDER BY name
       ''';
       return await db.rawQuery(sql);
   
     }
   
     // Get all verified students
     Future<List<Map<String, dynamic>>> getVerifiedStudents() async {
   
       final db = await database;
       const sql = '''
         SELECT * FROM users 
         WHERE role = 'student' 
         AND is_verified = 1
         ORDER BY name
       ''';
       return await db.rawQuery(sql);
   
     }
   
     // Update user verification status
     Future<int> updateUserVerificationStatus(int userId, bool isVerified) async {
   
       final db = await database;
       return await db.rawUpdate('''
         UPDATE users 
         SET is_verified = ? 
         WHERE id = ?
       ''', [isVerified ? 1 : 0, userId]);
   
     }
   } 