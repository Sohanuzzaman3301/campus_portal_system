import '../database/user_database_helper.dart';
import '../models/user.dart';

class UserService {
  final UserDatabaseHelper _db = UserDatabaseHelper.instance;

  // Get all unverified users
  Future<List<User>> getUnverifiedUsers() async {
    try {
      final users = await _db.getAllUsers();
      return users.where((user) => !user.isVerified).toList();
    } catch (e) {
      print('Error getting unverified users: $e');
      return [];
    }
  }

  // Get all teachers
  Future<List<User>> getTeachers() async {
    try {
      final users = await _db.getAllUsers();
      return users.where((user) => 
        user.role.toLowerCase() == 'teacher' && 
        user.isVerified
      ).toList();
    } catch (e) {
      print('Error getting teachers: $e');
      return [];
    }
  }

  // Get all students
  Future<List<User>> getStudents() async {
    try {
      final users = await _db.getAllUsers();
      return users.where((user) => 
        user.role.toLowerCase() == 'student' && 
        user.isVerified
      ).toList();
    } catch (e) {
      print('Error getting students: $e');
      return [];
    }
  }

  // Verify a user
  Future<bool> verifyUser(User user) async {
    try {
      final updatedUser = user.copyWith(isVerified: true);
      await _db.updateUser(updatedUser);
      return true;
    } catch (e) {
      print('Error verifying user: $e');
      return false;
    }
  }

  // Group teachers by department
  Future<Map<String, List<User>>> getTeachersByDepartment() async {
    try {
      final teachers = await getTeachers();
      final grouped = <String, List<User>>{};
      
      for (final teacher in teachers) {
        const department = 'Department'; // You'll need to add department to your user model
        grouped.putIfAbsent(department, () => []).add(teacher);
      }
      
      return grouped;
    } catch (e) {
      print('Error grouping teachers: $e');
      return {};
    }
  }

  // Group students by major
  Future<Map<String, List<User>>> getStudentsByMajor() async {
    try {
      final students = await getStudents();
      final grouped = <String, List<User>>{};
      
      for (final student in students) {
        const major = 'Major'; // You'll need to add major to your user model
        grouped.putIfAbsent(major, () => []).add(student);
      }
      
      return grouped;
    } catch (e) {
      print('Error grouping students: $e');
      return {};
    }
  }
} 