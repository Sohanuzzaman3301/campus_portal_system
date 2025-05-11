import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/user_database_helper.dart';
import '../models/user.dart';

class AssignmentNotifier extends StateNotifier<AsyncValue<void>> {
  final UserDatabaseHelper _userDb;

  AssignmentNotifier(this._userDb) : super(const AsyncValue.data(null));

  Future<void> assignCourseAndMajor({
    required int userId,
    required String majorId,
    required String courseId,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _userDb.assignCourseAndMajorToUser(
        userId: userId,
        majorId: majorId,
        courseId: courseId,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> verifyUser(int userId) async {
    try {
      state = const AsyncValue.loading();
      await _userDb.updateUserVerificationStatus(userId, true);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final assignmentProvider =
    StateNotifierProvider<AssignmentNotifier, AsyncValue<void>>((ref) {
  return AssignmentNotifier(UserDatabaseHelper.instance);
});

// Provider for verified users
final verifiedUsersProvider = FutureProvider<List<User>>((ref) async {
  final users = await UserDatabaseHelper.instance.getVerifiedUsers();
  return users.map((user) => User.fromMap(user as Map<String, dynamic>)).toList();
});

// Provider for user assignments
final userAssignmentsProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, userId) async {
  final assignments =
      await UserDatabaseHelper.instance.getUserAssignments(userId);
  return assignments;
});
