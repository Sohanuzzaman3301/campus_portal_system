import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class MajorDatabaseHelper {
  static const String tableName = 'majors';

  static const String columnMajorId = 'major_id';
  static const String columnName = 'name';
  static const String columnDepartment = 'department';
  static const String columnDescription = 'description';

  final DatabaseHelper _databaseHelper;

  MajorDatabaseHelper(this._databaseHelper);

  // Create
  Future<void> insertMajor(Map<String, dynamic> major) async {
    final db = await _databaseHelper.database;
    await db.insert(tableName, major, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Read
  Future<List<Map<String, dynamic>>> getMajors() async {
    final db = await _databaseHelper.database;
    return await db.query(tableName, orderBy: '$columnName ASC');
  }

  Future<Map<String, dynamic>?> getMajorById(String majorId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: '$columnMajorId = ?',
      whereArgs: [majorId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getMajorsByDepartment(String department) async {
    final db = await _databaseHelper.database;
    return await db.query(
      tableName,
      where: '$columnDepartment = ?',
      whereArgs: [department],
      orderBy: '$columnName ASC',
    );
  }

  // Update
  Future<int> updateMajor(Map<String, dynamic> major) async {
    final db = await _databaseHelper.database;
    return await db.update(
      tableName,
      major,
      where: '$columnMajorId = ?',
      whereArgs: [major[columnMajorId]],
    );
  }

  // Delete
  Future<int> deleteMajor(String majorId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      tableName,
      where: '$columnMajorId = ?',
      whereArgs: [majorId],
    );
  }

  // Additional utility methods
  Future<bool> majorExists(String majorId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: '$columnMajorId = ?',
      whereArgs: [majorId],
      limit: 1,
    );
    return results.isNotEmpty;
  }
  Future<List<Map<String, dynamic>>> getAllMajor() async {
    final db = await _databaseHelper.database;
    return await db.query(tableName, orderBy: '$columnName ASC');
  }
  // Count
  Future<int> getMajorsCount() async {
    final db = await _databaseHelper.database;
    final results = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getAllMajorNames() async {
    final db = await _databaseHelper.database;
    return await db.query(tableName, orderBy: '$columnName ASC', distinct: true);
  }

  Future<void> seedDefaultMajors() async {
    try {
      print('\n=== Seeding Default Majors ===');
      final db = await _databaseHelper.database;
      
      // Default majors data
      final defaultMajors = [
        {
          'major_id': 'CS',
          'name': 'Computer Science',
          'description': 'Study of computation and information processing',
          'department': 'Engineering'
        },
        {
          'major_id': 'BUS',
          'name': 'Business Administration',
          'description': 'Study of business management and operations',
          'department': 'Business'
        },
        {
          'major_id': 'ENG',
          'name': 'English Literature',
          'description': 'Study of literature and language',
          'department': 'Arts'
        },
        {
          'major_id': 'MATH',
          'name': 'Mathematics',
          'description': 'Study of numbers, quantities, and shapes',
          'department': 'Science'
        },
      ];

      // Use a batch to insert all majors
      final batch = db.batch();
      for (var major in defaultMajors) {
        batch.insert(
          'majors',
          major,
          conflictAlgorithm: ConflictAlgorithm.ignore, // Skip if already exists
        );
      }
      await batch.commit(noResult: true);
      print('✓ Default majors seeded successfully');
      
    } catch (e) {
      print('Error seeding default majors: $e');
    }
  }

  Future<bool> hasMajors() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('majors', limit: 1);
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking majors: $e');
      return false;
    }
  }
} 