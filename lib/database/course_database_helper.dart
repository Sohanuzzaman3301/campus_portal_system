import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class CourseDatabaseHelper {
  final DatabaseHelper _databaseHelper;

  CourseDatabaseHelper(this._databaseHelper);

  Future<void> seedDefaultCourses() async {
    try {
      print('\n=== Seeding Default Courses ===');
      final db = await _databaseHelper.database;

      // Default courses data organized by major
      final defaultCourses = {
        'CS': [
          {
            'course_id': 'CS101',
            'name': 'Introduction to Programming',
            'description': 'Basic programming concepts and algorithms',
            'major_id': 'CS',
            'credits': 3,
            'semester': 'Fall',
          },
          {
            'course_id': 'CS201',
            'name': 'Data Structures',
            'description': 'Advanced data structures and algorithms',
            'major_id': 'CS',
            'credits': 4,
            'semester': 'Spring',
          },
          {
            'course_id': 'CS301',
            'name': 'Database Systems',
            'description': 'Database design and management',
            'major_id': 'CS',
            'credits': 3,
            'semester': 'Fall',
          },
          {
            'course_id': 'CS401',
            'name': 'Software Engineering',
            'description': 'Software development lifecycle',
            'major_id': 'CS',
            'credits': 4,
            'semester': 'Spring',
          },
          {
            'course_id': 'CS501',
            'name': 'Artificial Intelligence',
            'description': 'AI concepts and applications',
            'major_id': 'CS',
            'credits': 3,
            'semester': 'Fall',
          },
        ],
        'BUS': [
          {
            'course_id': 'BUS101',
            'name': 'Business Fundamentals',
            'description': 'Introduction to business concepts',
            'major_id': 'BUS',
            'credits': 3,
            'semester': 'Fall',
          },
          {
            'course_id': 'BUS201',
            'name': 'Marketing Management',
            'description': 'Marketing strategies and analysis',
            'major_id': 'BUS',
            'credits': 3,
            'semester': 'Spring',
          },
          {
            'course_id': 'BUS301',
            'name': 'Financial Accounting',
            'description': 'Basic accounting principles',
            'major_id': 'BUS',
            'credits': 4,
            'semester': 'Fall',
          },
          {
            'course_id': 'BUS401',
            'name': 'Business Strategy',
            'description': 'Strategic management and planning',
            'major_id': 'BUS',
            'credits': 3,
            'semester': 'Spring',
          },
          {
            'course_id': 'BUS501',
            'name': 'International Business',
            'description': 'Global business operations',
            'major_id': 'BUS',
            'credits': 3,
            'semester': 'Fall',
          },
        ],
        'ENG': [
          {
            'course_id': 'ENG101',
            'name': 'Introduction to Literature',
            'description': 'Literary analysis and criticism',
            'major_id': 'ENG',
            'credits': 3,
            'semester': 'Fall',
          },
          {
            'course_id': 'ENG201',
            'name': 'Creative Writing',
            'description': 'Fiction and poetry writing',
            'major_id': 'ENG',
            'credits': 3,
            'semester': 'Spring',
          },
          {
            'course_id': 'ENG301',
            'name': 'Shakespeare Studies',
            'description': 'Analysis of Shakespeare\'s works',
            'major_id': 'ENG',
            'credits': 3,
            'semester': 'Fall',
          },
          {
            'course_id': 'ENG401',
            'name': 'Modern Literature',
            'description': '20th century literary works',
            'major_id': 'ENG',
            'credits': 3,
            'semester': 'Spring',
          },
          {
            'course_id': 'ENG501',
            'name': 'Literary Theory',
            'description': 'Advanced literary analysis',
            'major_id': 'ENG',
            'credits': 4,
            'semester': 'Fall',
          },
        ],
        'MATH': [
          {
            'course_id': 'MATH101',
            'name': 'Calculus I',
            'description': 'Limits, derivatives, and integrals',
            'major_id': 'MATH',
            'credits': 4,
            'semester': 'Fall',
          },
          {
            'course_id': 'MATH201',
            'name': 'Linear Algebra',
            'description': 'Vector spaces and matrices',
            'major_id': 'MATH',
            'credits': 3,
            'semester': 'Spring',
          },
          {
            'course_id': 'MATH301',
            'name': 'Abstract Algebra',
            'description': 'Group theory and rings',
            'major_id': 'MATH',
            'credits': 4,
            'semester': 'Fall',
          },
          {
            'course_id': 'MATH401',
            'name': 'Real Analysis',
            'description': 'Advanced calculus concepts',
            'major_id': 'MATH',
            'credits': 4,
            'semester': 'Spring',
          },
          {
            'course_id': 'MATH501',
            'name': 'Topology',
            'description': 'Topological spaces and continuity',
            'major_id': 'MATH',
            'credits': 3,
            'semester': 'Fall',
          },
        ],
      };

      // Use a batch to insert all courses
      final batch = db.batch();
      for (var majorCourses in defaultCourses.values) {
        for (var course in majorCourses) {
          batch.insert(
            'courses',
            course,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
      await batch.commit(noResult: true);
      print('✓ Default courses seeded successfully');

    } catch (e) {
      print('Error seeding default courses: $e');
    }
  }
  Future<List<Map<String, dynamic>>> getAllCourses() async {
    final db = await _databaseHelper.database;
    return await db.query('courses');
  }
  Future<List<Map<String, dynamic>>> getCoursesByMajor(String majorId) async {
    final db = await _databaseHelper.database;
    return await db.query('courses', where: 'major_id = ?', whereArgs: [majorId]);
  }
  Future<List<Map<String, dynamic>>> getCourseById(String courseId) async {
    final db = await _databaseHelper.database;
    return await db.query('courses', where: 'course_id = ?', whereArgs: [courseId]);
  }
  Future<int> insertCourse(Map<String, dynamic> course) async {
    final db = await _databaseHelper.database;
    return await db.insert('courses', course);
  }
  Future<int> updateCourse(Map<String, dynamic> course) async {
    final db = await _databaseHelper.database;
    return await db.update('courses', course, where: 'course_id = ?', whereArgs: [course['course_id']]);
  }
  Future<int> deleteCourse(String courseId) async {
    final db = await _databaseHelper.database;
    return await db.delete('courses', where: 'course_id = ?', whereArgs: [courseId]);
  }
  Future<int> deleteAllCourses() async {
    final db = await _databaseHelper.database;
    return await db.delete('courses');
  }
  Future<void> deleteCourseByMajor(String majorId) async {
    final db = await _databaseHelper.database;
    await db.delete('courses', where: 'major_id = ?', whereArgs: [majorId]);
  }
  Future<void> deleteCourseByCourseId(String courseId) async {
    final db = await _databaseHelper.database;
    await db.delete('courses', where: 'course_id = ?', whereArgs: [courseId]);
  }
  Future<bool> hasCourses() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.query('courses', limit: 1);
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking courses: $e');
      return false;
    }
  }
} 

