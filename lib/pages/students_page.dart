import 'package:campus_portal_system/providers/enrollment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/user_database_helper.dart';
import 'package:ionicons/ionicons.dart';

class StudentsPage extends ConsumerWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: UserDatabaseHelper.instance.getVerifiedStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(child: Text('No students found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final majorId = student['major_id'];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    child: Text(student['name'][0].toUpperCase()),
                  ),
                  title: Text(student['name']),
                  subtitle: Text(student['email']),
                  children: [
                    if (student['student_id'] != null) ...[
                      // Major Information
                      Consumer(
                        builder: (context, ref, child) {
                          final majorAsync = ref.watch(studentMajorProvider(student['student_id']));
                          
                          return majorAsync.when(
                            data: (major) {
                              if (major == null) {
                                return const ListTile(
                                  leading: Icon(Ionicons.school_outline),
                                  title: Text('Major not found'),
                                );
                              }

                              return ListTile(
                                leading: const Icon(Ionicons.school_outline),
                                title: Text(major['name']),
                                subtitle: Text(major['department']),
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => ListTile(
                              leading: const Icon(Icons.error_outline),
                              title: Text('Error loading major: $error'),
                            ),
                          );
                        },
                      ),

                      // Enrollments Information
                      Consumer(
                        builder: (context, ref, child) {
                          final enrollmentsAsync = ref.watch(
                            studentEnrollmentsProvider(student['student_id'])
                          );
                          
                          return enrollmentsAsync.when(
                            data: (enrollments) {
                              if (enrollments.isEmpty) {
                                return const ListTile(
                                  leading: Icon(Ionicons.book_outline),
                                  title: Text('No courses found'),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Enrolled Courses',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ...enrollments.map((enrollment) => ListTile(
                                    leading: const Icon(Ionicons.book_outline),
                                    title: Text(enrollment['course_name']),
                                    subtitle: Text(
                                      '${enrollment['credits']} credits - ${enrollment['semester']}'
                                    ),
                                    trailing: Text(
                                      enrollment['course_id'],
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  )),
                                ],
                              );
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, stack) => ListTile(
                              leading: const Icon(Icons.error_outline),
                              title: Text('Error loading enrollments: $error'),
                            ),
                          );
                        },
                      ),
                    ] else
                      const ListTile(
                        leading: Icon(Icons.warning_amber_rounded),
                        title: Text('No major assigned'),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
} 