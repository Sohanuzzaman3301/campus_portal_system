import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/user_database_helper.dart';

final unverifiedUsersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userDatabaseHelper = UserDatabaseHelper.instance;
  return userDatabaseHelper.getUnverifiedUsers();
}); 