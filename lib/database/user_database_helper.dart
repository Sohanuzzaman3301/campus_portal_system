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

  Future<List<User>> getVerifiedUsers() async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'is_verified = 1',
    );
    return results.map((map) => User.fromMap(map)).toList();
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

  Future<void> assignCourseAndMajorToUser({
    required int userId,
    required String majorId,
    required String courseId,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      // Get user details
      final userResult = await txn.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (userResult.isEmpty) {
        throw Exception('User not found');
      }

      final user = userResult.first;
      final role = user['role'] as String;

      if (role.toLowerCase() == 'student') {
        // Create student record if it doesn't exist
        final studentId = 'STU${userId.toString().padLeft(6, '0')}';
        await txn.insert(
          'students',
          {
            'student_id': studentId,
            'name': user['name'],
            'major_id': majorId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Update user with student_id
        await txn.update(
          'users',
          {'student_id': studentId},
          where: 'id = ?',
          whereArgs: [userId],
        );

        // Create enrollment
        await txn.insert(
          'enrollments',
          {
            'student_id': studentId,
            'course_id': courseId,
            'enrollment_date': DateTime.now().toIso8601String(),
            'status': 'active',
          },
        );
      } else if (role.toLowerCase() == 'instructor') {
        // Create instructor record if it doesn't exist
        final instructorId = 'INS${userId.toString().padLeft(6, '0')}';
        await txn.insert(
          'instructors',
          {
            'instructor_id': instructorId,
            'name': user['name'],
            'major_id': majorId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Update user with instructor_id
        await txn.update(
          'users',
          {'instructor_id': instructorId},
          where: 'id = ?',
          whereArgs: [userId],
        );
      }

      // Mark user as verified
      await txn.update(
        'users',
        {'is_verified': 1},
        where: 'id = ?',
        whereArgs: [userId],
      );
    });
  }

  Future<Map<String, dynamic>> getUserAssignments(int userId) async {
    final db = await database;
    final result = await db.transaction((txn) async {
      // Get user details
      final user = (await txn.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      )).first;

      final assignments = <String, dynamic>{
        'user': user,
      };

      if (user['student_id'] != null) {
        // Get student details
        final student = await txn.query(
          'students',
          where: 'student_id = ?',
          whereArgs: [user['student_id']],
        );

        if (student.isNotEmpty) {
          assignments['student'] = student.first;
          
          // Get enrollments
          final enrollments = await txn.query(
            'enrollments',
            where: 'student_id = ?',
            whereArgs: [user['student_id']],
          );
          assignments['enrollments'] = enrollments;

          // Get major details
          if (student.first['major_id'] != null) {
            final major = await txn.query(
              'majors',
              where: 'major_id = ?',
              whereArgs: [student.first['major_id']],
            );
            if (major.isNotEmpty) {
              assignments['major'] = major.first;
            }
          }
        }
      } else if (user['instructor_id'] != null) {
        // Get instructor details
        final instructor = await txn.query(
          'instructors',
          where: 'instructor_id = ?',
          whereArgs: [user['instructor_id']],
        );

        if (instructor.isNotEmpty) {
          assignments['instructor'] = instructor.first;
          
          // Get major details
          if (instructor.first['major_id'] != null) {
            final major = await txn.query(
              'majors',
              where: 'major_id = ?',
              whereArgs: [instructor.first['major_id']],
            );
            if (major.isNotEmpty) {
              assignments['major'] = major.first;
            }
          }
        }
      }

      return assignments;
    });

    return result;
  }

  Future<void> updateUserDetails(User user) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      await db.update(
        'users',
        {
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'role': user.role,
          'is_verified': user.isVerified ? 1 : 0,
          'student_id': user.studentId,
          'instructor_id': user.instructorId,
        },
        where: 'id = ?',
        whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error updating user in database: $e');
      rethrow;
    }
  }
} 