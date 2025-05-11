import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../models/user.dart';

// Service provider
final userServiceProvider = Provider<UserService>((ref) => UserService());

// Generic provider for fetching user data
FutureProvider<List<User>> createUserProvider(Future<List<User>> Function(UserService) fetchFunction) {
  return FutureProvider<List<User>>((ref) async {
    final userService = ref.read(userServiceProvider);
    return await fetchFunction(userService);
  });
}

// Unverified users provider
final unverifiedUsersProvider = createUserProvider((userService) => userService.getUnverifiedUsers());

// Teachers provider (grouped by department)
final teachersProvider = FutureProvider<Map<String, List<User>>>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getTeachersByDepartment();
});

// Students provider (grouped by major)
final studentsProvider = FutureProvider<Map<String, List<User>>>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getStudentsByMajor();
});

// Single user operations
final verifyUserProvider = FutureProvider.family<bool, User>((ref, user) async {
  final userService = ref.read(userServiceProvider);
  final success = await userService.verifyUser(user);
  if (success) {
    // Refresh the providers
    ref.invalidate(unverifiedUsersProvider);
    ref.invalidate(teachersProvider);
    ref.invalidate(studentsProvider);
  }
  return success;
}); 