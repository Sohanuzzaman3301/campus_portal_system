import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_portal_system/router/router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:campus_portal_system/database/database_helper.dart';
import 'package:campus_portal_system/database/user_database_helper.dart';
import 'package:campus_portal_system/theme/app_theme.dart';
import 'package:campus_portal_system/providers/theme_provider.dart';
import 'package:campus_portal_system/database/database_config.dart';
import 'package:campus_portal_system/database/major_database_helper.dart';
import 'package:campus_portal_system/database/course_database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory first
  await DatabaseConfig.initializeDatabase();

  // Initialize database and print users
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;
  await printAllUsers();

  // Check and seed majors if needed
  final majorHelper = MajorDatabaseHelper(dbHelper);
  if (!await majorHelper.hasMajors()) {
    await majorHelper.seedDefaultMajors();
  }

  // Check and seed courses if needed
  final courseHelper = CourseDatabaseHelper(dbHelper);
  if (!await courseHelper.hasCourses()) {
    await courseHelper.seedDefaultCourses();
  }

  // Add this line
  await printAllStudents();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

Future<void> printAllUsers() async {
  try {
    final users = await UserDatabaseHelper.instance.getAllUsers();
    print('\n=== All Users in Database ===');
    if (users.isEmpty) {
      print('No users found in database');
    } else {
      for (final user in users) {
        print('ID: ${user.id}');
        print('Name: ${user.name}');
        print('Email: ${user.email}');
        print('Role: ${user.role}');
        print('-------------------');
      }
    }
    print('=== End Users List ===\n');
  } catch (e) {
    print('Error printing users: $e');
  }
}

Future<void> printAllStudents() async {
  try {
    final db = await DatabaseHelper.instance.database;
    final students = await db.query('students');
    print('\n=== All Students in Database ===');
    if (students.isEmpty) {
      print('No students found in database');
    } else {
      for (final student in students) {
        print('Student ID: ${student['student_id']}');
        print('Name: ${student['name']}');
        print('Major ID: ${student['major_id']}');
        print('-------------------');
      }
    }
    print('=== End Students List ===\n');
  } catch (e) {
    print('Error printing students: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Campus Portal',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: MaxWidthBox(
          maxWidth: 2460,
          child: child!,
        ),
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}
