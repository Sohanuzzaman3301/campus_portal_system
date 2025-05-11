import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/majors_provider.dart';
import '../database/database_helper.dart';

class MajorPage extends ConsumerWidget {
  const MajorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final majorsAsync = ref.watch(majorsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Academic Programs'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.refresh_outline),
            onPressed: () => ref.refresh(majorsProvider),
          ),
        ],
      ),
      body: majorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error', style: theme.textTheme.bodyLarge),
        ),
        data: (majors) => _buildContent(majors, theme, context),
      ),
    );
  }

  Widget _buildContent(List<Map<String, dynamic>> majors, ThemeData theme,
      BuildContext context) {
    final majorsByDepartment = <String, List<Map<String, dynamic>>>{};
    for (var major in majors) {
      final department = major['department'] as String;
      majorsByDepartment.putIfAbsent(department, () => []).add(major);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: majorsByDepartment.length,
      itemBuilder: (context, index) {
        final department = majorsByDepartment.keys.elementAt(index);
        final departmentMajors = majorsByDepartment[department]!;
        return _buildDepartmentSection(department, departmentMajors, theme);
      },
    );
  }

  Widget _buildDepartmentSection(
      String department, List<Map<String, dynamic>> majors, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16, top: 8),
          child: Row(
            children: [
              Icon(_getDepartmentIcon(department),
                  color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                department,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...majors.map((major) => _buildMajorCard(major, theme)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMajorCard(Map<String, dynamic> major, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          major['name'],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Ionicons.school_outline,
                size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(major['major_id']),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (major['description'] != null) ...[
                  Text(
                    major['description'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Available Courses',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCoursesList(major['major_id'], theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList(String majorId, ThemeData theme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getCoursesByMajor(majorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final courses = snapshot.data ?? [];

        if (courses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Ionicons.information_circle_outline,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'No courses available',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Ionicons.book_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course['name'],
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              course['course_id'],
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${course['credits']} credits',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course['semester'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getDepartmentIcon(String department) {
    switch (department.toLowerCase()) {
      case 'school of computing':
        return Ionicons.desktop_outline;
      case 'school of engineering':
        return Ionicons.construct_outline;
      case 'school of business':
        return Ionicons.briefcase_outline;
      case 'school of sciences':
        return Ionicons.flask_outline;
      case 'school of arts':
        return Ionicons.color_palette_outline;
      default:
        return Ionicons.library_outline;
    }
  }
}
