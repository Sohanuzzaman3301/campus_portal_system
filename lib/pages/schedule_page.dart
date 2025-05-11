import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/auth_provider.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Ionicons.calendar_outline),
            onPressed: () {
              // TODO: Add calendar view toggle
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Activity',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HeatMap(
                      datasets: {
                        DateTime(2024, 3, 1): 3,
                        DateTime(2024, 3, 4): 2,
                        DateTime(2024, 3, 5): 4,
                        DateTime(2024, 3, 7): 1,
                      },
                      colorMode: ColorMode.color,
                      defaultColor: theme.colorScheme.surfaceContainerHighest,
                      textColor: theme.colorScheme.onSurface,
                      showColorTip: false,
                      showText: true,
                      scrollable: true,
                      size: 40,
                      colorsets: {
                        1: theme.colorScheme.primary.withOpacity(0.25),
                        2: theme.colorScheme.primary.withOpacity(0.5),
                        3: theme.colorScheme.primary.withOpacity(0.75),
                        4: theme.colorScheme.primary,
                      },
                      onClick: (value) {
                        // TODO: Show classes for selected date
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Classes on ${value.toString().split(' ')[0]}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Upcoming Classes',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUpcomingClasses(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingClasses(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // Example count
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Ionicons.book_outline,
                color: theme.colorScheme.primary,
              ),
            ),
            title: const Text('Introduction to Programming'),
            subtitle: Text(
              'Room 101 • 10:00 AM',
              style: theme.textTheme.bodySmall,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'In 2 hours',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 