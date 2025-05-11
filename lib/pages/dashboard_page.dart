import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _EventSection(
            title: 'Upcoming Events',
            events: [
              _Event(
                title: 'Mid-Term Examination',
                date: 'March 15, 2024',
                description: 'Mid-term examinations for all departments',
                icon: Ionicons.document_text_outline,
                color: Colors.orange,
              ),
              _Event(
                title: 'Science Exhibition',
                date: 'March 20, 2024',
                description: 'Annual science exhibition in the main auditorium',
                icon: Ionicons.flask_outline,
                color: Colors.purple,
              ),
              _Event(
                title: 'Sports Day',
                date: 'March 25, 2024',
                description: 'Annual sports day celebration',
                icon: Ionicons.football_outline,
                color: Colors.green,
              ),
            ],
          ),
          SizedBox(height: 24),
          _EventSection(
            title: 'Recent Announcements',
            events: [
              _Event(
                title: 'Library Timing Change',
                date: 'March 1, 2024',
                description: 'New library hours: 8:00 AM - 8:00 PM',
                icon: Ionicons.time_outline,
                color: Colors.blue,
              ),
              _Event(
                title: 'New Course Registration',
                date: 'March 5, 2024',
                description: 'Registration for new courses starts next week',
                icon: Ionicons.book_outline,
                color: Colors.teal,
              ),
              _Event(
                title: 'Campus Maintenance',
                date: 'March 10, 2024',
                description: 'Building A will be under maintenance',
                icon: Ionicons.construct_outline,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventSection extends StatelessWidget {
  final String title;
  final List<_Event> events;

  const _EventSection({
    required this.title,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...events,
      ],
    );
  }
}

class _Event extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final IconData icon;
  final Color color;

  const _Event({
    required this.title,
    required this.date,
    required this.description,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              date,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(description),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Ionicons.chevron_forward_outline),
          onPressed: () {
            // Show event details
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: $date'),
                    const SizedBox(height: 8),
                    Text(description),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
} 