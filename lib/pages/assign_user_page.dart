import 'package:campus_portal_system/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/course_provider.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/enrollment_provider.dart';

class AssignUserPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;

  const AssignUserPage({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<AssignUserPage> createState() => _AssignUserPageState();
}

class _AssignUserPageState extends ConsumerState<AssignUserPage> {
  String? _selectedMajor;
  bool _isLoading = false;
  List<Map<String, dynamic>> _majors = [];
  final List<String> _selectedCourses = [];

  @override
  void initState() {
    super.initState();
    _loadMajors();
  }

  Future<void> _loadMajors() async {
    try {
      final majorHelper = DatabaseHelper.instance.getMajorDatabaseHelper;
      final majors = await majorHelper.getAllMajorNames();
      setState(() {
        _majors = majors.isNotEmpty ? majors : _getDummyMajors();
      });
    } catch (e) {
      print('Error loading majors: $e');
      setState(() {
        _majors = _getDummyMajors();
      });
    }
  }

  List<Map<String, dynamic>> _getDummyMajors() {
    return [
      {'major_id': 'CS', 'name': 'Computer Science', 'department': 'Engineering'},
      {'major_id': 'BUS', 'name': 'Business Administration', 'department': 'Business'},
      {'major_id': 'ENG', 'name': 'English Literature', 'department': 'Arts'},
      {'major_id': 'MATH', 'name': 'Mathematics', 'department': 'Science'},
    ];
  }

  Future<void> _assignUser() async {
    if (_selectedMajor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a major')),
      );
      return;
    }

    if (_selectedCourses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one course')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studentId = 'STU${widget.user['id'].toString().padLeft(6, '0')}';
      
      final enrollmentHelper = ref.read(enrollmentHelperProvider);
      await enrollmentHelper.enrollStudent(
        studentId: studentId,
        majorId: _selectedMajor!,
        courseIds: _selectedCourses,
      );

      final db = await DatabaseHelper.instance.database;
      await db.update(
        'users',
        {
          'student_id': studentId,
          'is_verified': 1,
        },
        where: 'id = ?',
        whereArgs: [widget.user['id']],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User verified and courses assigned successfully')),
        );
        context.pop();
      }
    } catch (e) {
      print('Error in _assignUser: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verifying user: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleCourseSelection(String courseId) {
    setState(() {
      if (_selectedCourses.contains(courseId)) {
        _selectedCourses.remove(courseId);
      } else {
        _selectedCourses.add(courseId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          widget.user['name'][0].toUpperCase(),
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                      title: Text(
                        widget.user['name'],
                        style: theme.textTheme.titleLarge,
                      ),
                      subtitle: Text(widget.user['email']),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Ionicons.shield_outline),
                      title: const Text('Role'),
                      subtitle: Text(
                        widget.user['role'][0].toUpperCase() + 
                        widget.user['role'].substring(1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Major Selection Section
            Text(
              'Select Major',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Major Cards Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _majors.length,
              itemBuilder: (context, index) {
                final major = _majors[index];
                final isSelected = _selectedMajor == major['major_id'];
                
                return Card(
                  elevation: isSelected ? 8 : 2,
                  color: isSelected ? theme.colorScheme.primaryContainer : null,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMajor = major['major_id'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            major['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isSelected ? 
                                theme.colorScheme.onPrimaryContainer : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            major['department'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected ? 
                                theme.colorScheme.onPrimaryContainer : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Courses Section (shown when major is selected)
            if (_selectedMajor != null) ...[
              const SizedBox(height: 24),
              Text(
                'Available Courses',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final coursesAsync = ref.watch(coursesByMajorProvider(_selectedMajor!));
                  
                  return coursesAsync.when(
                    data: (courses) {
                      if (courses.isEmpty) {
                        return const Center(
                          child: Text('No courses available for this major'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(course['name']),
                              subtitle: Text(course['description']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${course['credits']} credits',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Checkbox(
                                    value: _selectedCourses.contains(course['course_id']),
                                    onChanged: (_) => _toggleCourseSelection(course['course_id']),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error loading courses: $error'),
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _assignUser,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Verify User'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 