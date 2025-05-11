import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/user_database_helper.dart';

// Service provider
final usersServiceProvider = Provider<UsersService>((ref) => UsersService());

// Provider for unverified users
final unverifiedUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await UserDatabaseHelper.instance.getUnverifiedUsers();
  } catch (e) {
    print('Error in unverifiedUsersProvider: $e');
    return [];
  }
});

// Provider for verified teachers
final verifiedTeachersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await UserDatabaseHelper.instance.getVerifiedTeachers();
  } catch (e) {
    print('Error in verifiedTeachersProvider: $e');
    return [];
  }
});

// Provider for verified students
final verifiedStudentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    return await UserDatabaseHelper.instance.getVerifiedStudents();
  } catch (e) {
    print('Error in verifiedStudentsProvider: $e');
    return [];
  }
});

// Provider for verifying a user
final verifyUserProvider = FutureProvider.family<bool, int>((ref, userId) async {
  try {
    await UserDatabaseHelper.instance.updateUserVerificationStatus(userId, true);
    // Refresh the providers after verification
    ref.invalidate(unverifiedUsersProvider);
    ref.invalidate(verifiedTeachersProvider);
    ref.invalidate(verifiedStudentsProvider);
    return true;
  } catch (e) {
    print('Error in verifyUserProvider: $e');
    return false;
  }
});

// Service class for additional functionality if needed
class UsersService {
  final UserDatabaseHelper _db = UserDatabaseHelper.instance;

  Future<bool> verifyUser(int userId) async {
    try {
      await _db.updateUserVerificationStatus(userId, true);
      return true;
    } catch (e) {
      print('Error verifying user: $e');
      return false;
    }
  }
} 