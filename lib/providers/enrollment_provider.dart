import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

final enrollmentHelperProvider = Provider<EnrollmentHelper>((ref) {
  return EnrollmentHelper(DatabaseHelper.instance);
});

class EnrollmentHelper {
  final DatabaseHelper _dbHelper;

  EnrollmentHelper(this._dbHelper);

  Future<List<Map<String, dynamic>>> getStudentEnrollments(
      String studentId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT e.*, c.name as course_name, c.description, c.credits, c.semester
      FROM enrollments e
      JOIN courses c ON e.course_id = c.course_id
      WHERE e.student_id = ?
    ''', [studentId]);
  }

  Future<Map<String, dynamic>?> getStudentMajor(String studentId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT m.*
      FROM students s
      JOIN majors m ON s.major_id = m.major_id
      WHERE s.student_id = ?
    ''', [studentId]);

    return results.isNotEmpty ? results.first : null;
  }

  Future<void> enrollStudent({
    required String studentId,
    required String majorId,
    required List<String> courseIds,
  }) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Update student's major
      await txn.update(
        'students',
        {'major_id': majorId},
        where: 'student_id = ?',
        whereArgs: [studentId],
      );

      // Create enrollments
      for (final courseId in courseIds) {
        await txn.insert(
          'enrollments',
          {
            'student_id': studentId,
            'course_id': courseId,
            'enrollment_date': DateTime.now().toIso8601String(),
            'status': 'active',
            'grade': null,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}

// Provider for student enrollments
final studentEnrollmentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, studentId) async {
    final enrollmentHelper = ref.watch(enrollmentHelperProvider);
    return await enrollmentHelper.getStudentEnrollments(studentId);
  },
);

// Provider for student major
final studentMajorProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, studentId) async {
    final enrollmentHelper = ref.watch(enrollmentHelperProvider);
    return await enrollmentHelper.getStudentMajor(studentId);
  },
);
