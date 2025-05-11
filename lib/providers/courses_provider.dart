import 'package:campus_portal_system/database/user_database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';

final enrolledCoursesProvider =
    FutureProvider.family<List<Course>, String>((ref, studentId) async {
  final coursesData =
      await UserDatabaseHelper.instance.getEnrolledCourses(studentId);
  return coursesData.map((data) => Course.fromMap(data)).toList();
});
