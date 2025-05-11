import 'package:flutter_riverpod/flutter_riverpod.dart';

// Student Dashboard Providers
final studentCoursesCountProvider = Provider<int>((ref) => 5);
final studentBorrowedBooksCountProvider = Provider<int>((ref) => 2);
final studentUpcomingTestsCountProvider = Provider<int>((ref) => 3);
final studentGpaProvider = Provider<double>((ref) => 3.75);

// Teacher Dashboard Providers
final teacherTotalStudentsProvider = Provider<int>((ref) => 120);
final teacherCoursesCountProvider = Provider<int>((ref) => 4);
final teacherPendingGradesCountProvider = Provider<int>((ref) => 15);
final teacherTodayClassesCountProvider = Provider<int>((ref) => 3);

// Admin Dashboard Providers
final totalUsersCountProvider = Provider<int>((ref) => 500);
final pendingUsersCountProvider = Provider<int>((ref) => 10);
final totalCoursesCountProvider = Provider<int>((ref) => 50);
final systemAlertsCountProvider = Provider<int>((ref) => 2);

// ... Add other providers for the async data shown in the dashboard 