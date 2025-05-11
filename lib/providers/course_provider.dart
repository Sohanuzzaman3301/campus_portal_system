import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/course_database_helper.dart';
import '../database/database_helper.dart';

// Provider for CourseHelper instance
final courseHelperProvider = Provider<CourseDatabaseHelper>((ref) {
  return CourseDatabaseHelper(DatabaseHelper.instance);
});

// Provider for all courses
final allCoursesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final courseHelper = ref.watch(courseHelperProvider);
  return await courseHelper.getAllCourses();
});

// Provider for courses by major
final coursesByMajorProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, majorId) async {
  final courseHelper = ref.watch(courseHelperProvider);
  return await courseHelper.getCoursesByMajor(majorId);
});

// Provider for single course by ID
final courseByIdProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, courseId) async {
  final courseHelper = ref.watch(courseHelperProvider);
  final courses = await courseHelper.getCourseById(courseId);
  return courses.isNotEmpty ? courses.first : null;
});

// Notifier for managing courses
class CourseNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final CourseDatabaseHelper _courseHelper;

  CourseNotifier(this._courseHelper) : super(const AsyncValue.loading()) {
    loadCourses();
  }

  Future<void> loadCourses() async {
    try {
      state = const AsyncValue.loading();
      final courses = await _courseHelper.getAllCourses();
      state = AsyncValue.data(courses);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCourse(Map<String, dynamic> course) async {
    try {
      await _courseHelper.insertCourse(course);
      await loadCourses();
    } catch (e) {
      print('Error adding course: $e');
    }
  }

  Future<void> updateCourse(Map<String, dynamic> course) async {
    try {
      await _courseHelper.updateCourse(course);
      await loadCourses();
    } catch (e) {
      print('Error updating course: $e');
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _courseHelper.deleteCourseByCourseId(courseId);
      await loadCourses();
    } catch (e) {
      print('Error deleting course: $e');
    }
  }

  Future<void> deleteAllCourses() async {
    try {
      await _courseHelper.deleteAllCourses();
      await loadCourses();
    } catch (e) {
      print('Error deleting all courses: $e');
    }
  }

  Future<void> deleteCoursesByMajor(String majorId) async {
    try {
      await _courseHelper.deleteCourseByMajor(majorId);
      await loadCourses();
    } catch (e) {
      print('Error deleting courses for major: $e');
    }
  }
}

// Provider for course notifier
final courseNotifierProvider = StateNotifierProvider<CourseNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final courseHelper = ref.watch(courseHelperProvider);
  return CourseNotifier(courseHelper);
}); 