import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class CoursesPage extends ConsumerWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authNotifierProvider);
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view courses')),
      );
    }

    // Check if user is a student
    if (currentUser.role.toLowerCase() != 'student') {
      return const Scaffold(
        body: Center(child: Text('Only students can view courses')),
      );
    }

    // Rest of your courses page UI...
    return const Scaffold(
      body: Center(child: Text('Courses Page')),
    );
  }
} 