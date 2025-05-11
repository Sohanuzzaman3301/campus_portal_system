import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

final majorAssignmentProvider = StateNotifierProvider<MajorAssignmentNotifier, AsyncValue<void>>((ref) {
  return MajorAssignmentNotifier(DatabaseHelper.instance.getMajorDatabaseHelper);
});

class MajorAssignmentNotifier extends StateNotifier<AsyncValue<void>> {
  final majorDatabaseHelper;

  MajorAssignmentNotifier(this.majorDatabaseHelper) : super(const AsyncValue.data(null));

  Future<void> assignMajorToUser(String userId, String majorId) async {
    try {
      state = const AsyncValue.loading();
      // Verify major exists
      final majorExists = await majorDatabaseHelper.majorExists(majorId);
      if (!majorExists) {
        throw Exception('Major not found');
      }
      
      // Update user's major
      await DatabaseHelper.instance.updateUserMajor(userId, majorId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<String?> getUserMajor(String userId) async {
    try {
      final userData = await majorDatabaseHelper.getUserById(userId);
      return userData?['major_id'];
    } catch (e) {
      return null;
    }
  }
}
