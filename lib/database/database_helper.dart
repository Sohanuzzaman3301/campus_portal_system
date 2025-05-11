import 'package:campus_portal_system/database/database_config.dart';
import 'package:sqflite/sqflite.dart';
import 'major_database_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  late final MajorDatabaseHelper majorDatabaseHelper;

  DatabaseHelper._init() {
    majorDatabaseHelper = MajorDatabaseHelper(this);
  }

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
      
      // Check and seed books directly using the db instance
      final hasExistingBooks = await _hasBooks(db);
      if (!hasExistingBooks) {
        await _seedDefaultBooks(db);
      }

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

  Future<void> updateUserMajor(String userId, String majorId) async {
    final db = await database;
    await db.update(
      'users',
      {'major_id': majorId},
      where: 'id = ?',
      whereArgs: [userId],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getEnrolledCourses(String studentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.* FROM courses c
      INNER JOIN enrollments e ON c.course_id = e.course_id
      WHERE e.student_id = ?
    ''', [studentId]);
  }

  // Private methods that use the db instance directly
  Future<bool> _hasBooks(Database db) async {
    try {
      final result = await db.query('books', limit: 1);
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking books: $e');
      return false;
    }
  }

  Future<void> _seedDefaultBooks(Database db) async {
    print('\n=== Seeding Default Books ===');
    final defaultBooks = [
      {
        'book_id': 'B001',
        'title': 'Introduction to Computer Science',
        'author': 'John Smith',
        'description': 'A comprehensive guide to computer science fundamentals',
        'cover_url': 'https://picsum.photos/200/300',
        'isbn': '978-3-16-148410-0',
        'category': 'Computer Science'
      },
      {
        'book_id': 'B002',
        'title': 'Advanced Mathematics',
        'author': 'Sarah Johnson',
        'description': 'Advanced topics in mathematics for university students',
        'cover_url': 'https://picsum.photos/200/300',
        'isbn': '978-3-16-148410-1',
        'category': 'Mathematics'
      },
      {
        'book_id': 'B003',
        'title': 'Physics Fundamentals',
        'author': 'Michael Brown',
        'description': 'Basic principles of physics explained',
        'cover_url': 'https://picsum.photos/200/300',
        'isbn': '978-3-16-148410-2',
        'category': 'Physics'
      },
      {
        'book_id': 'B004',
        'title': 'Digital Electronics',
        'author': 'Emily Davis',
        'description': 'Understanding digital circuits and systems',
        'cover_url': 'https://picsum.photos/200/300',
        'isbn': '978-3-16-148410-3',
        'category': 'Electronics'
      },
    ];

    try {
      final batch = db.batch();
      for (var book in defaultBooks) {
        batch.insert('books', book, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
      print('✓ Default books seeded successfully');
    } catch (e) {
      print('Error seeding default books: $e');
    }
  }

  // Public methods can still use the database getter
  Future<bool> hasBooks() async {
    final db = await database;
    return _hasBooks(db);
  }

  Future<void> seedDefaultBooks() async {
    final db = await database;
    await _seedDefaultBooks(db);
  }
}
