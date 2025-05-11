import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';

final majorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final majorDatabaseHelper = DatabaseHelper.instance.getMajorDatabaseHelper;
  return majorDatabaseHelper.getAllMajor();
});

// Add additional providers for CRUD operations
final majorProvider = FutureProvider.family<Map<String, dynamic>?, int>((ref, id) async {
  final majorDatabaseHelper = DatabaseHelper.instance.getMajorDatabaseHelper;
  return majorDatabaseHelper.getMajorById(id.toString());
});

final majorsByDepartmentProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, department) async {
  final majorDatabaseHelper = DatabaseHelper.instance.getMajorDatabaseHelper;
  return majorDatabaseHelper.getMajorsByDepartment(department);
}); 

final allMajorsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final majorDatabaseHelper = DatabaseHelper.instance.getMajorDatabaseHelper;
  return majorDatabaseHelper.getAllMajorNames();
}); 