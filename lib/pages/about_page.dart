import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final breakpoints = ResponsiveBreakpoints.of(context);
    final isMobile = breakpoints.smallerThan(TABLET);
    final isDesktop = breakpoints.largerThan(TABLET);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        // The leading back button will automatically use context.pop()
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 48,
                vertical: isDesktop ? 64 : 48,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Campus Portal System',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Database Application Course Project',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // University Section
            Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 48),
              child: Column(
                children: [
                  Icon(
                    Icons.school,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wuhan Institute of Technology',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    'www.wit.edu.cn',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Technology Section
            Padding(
              padding: EdgeInsets.all(isMobile ? 24 : 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.code,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Technology Stack',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildTechChip(theme, 'Flutter', Icons.flutter_dash),
                      _buildTechChip(theme, 'Dart', Icons.code),
                      _buildTechChip(theme, 'SQLite', Icons.storage),
                      _buildTechChip(theme, 'Riverpod', Icons.account_tree),
                      _buildTechChip(theme, 'Go Router', Icons.route),
                      _buildTechChip(theme, 'Material 3', Icons.design_services),
                      _buildTechChip(theme, 'Responsive UI', Icons.devices),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'About the App',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Campus Portal System is a comprehensive educational management solution built with modern technologies. '
                    'It features a responsive design that works across all devices, state-of-the-art state management with Riverpod, '
                    'and a robust SQLite database for efficient data handling. The app implements Material Design 3 principles '
                    'for a clean, intuitive user interface.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Team Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 48,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Development Team',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTeamMember(
                              theme,
                              'Shanto Md Sohanuzzaman',
                              'Team Lead',
                              'Full-stack developer with expertise in database design and system architecture.',
                              ['Frontend Development', 'Backend Architecture', 'Database Design'],
                            )),
                            const SizedBox(width: 24),
                            Expanded(child: _buildTeamMember(
                              theme,
                              'Sajjad Hossen',
                              'Research Lead',
                              'Focused on system analysis and research methodology.',
                              ['Requirements Analysis', 'System Research', 'Documentation'],
                            )),
                            const SizedBox(width: 24),
                            Expanded(child: _buildTeamMember(
                              theme,
                              'Towhidul Islam Shahed',
                              'Quality Assurance',
                              'Ensures system quality through comprehensive testing.',
                              ['Beta Testing', 'Quality Assurance', 'User Feedback'],
                            )),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _buildTeamMember(
                            theme,
                            'Shanto Md Sohanuzzaman',
                            'Team Lead',
                            'Full-stack developer with expertise in database design and system architecture.',
                            ['Frontend Development', 'Backend Architecture', 'Database Design'],
                          ),
                          const SizedBox(height: 24),
                          _buildTeamMember(
                            theme,
                            'Sajjad Hossain',
                            'Research Lead',
                            'Focused on system analysis and research methodology.',
                            ['Requirements Analysis', 'System Research', 'Documentation'],
                          ),
                          const SizedBox(height: 24),
                          _buildTeamMember(
                            theme,
                            'Shahed Hossain',
                            'Quality Assurance',
                            'Ensures system quality through comprehensive testing.',
                            ['Beta Testing', 'Quality Assurance', 'User Feedback'],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(
    ThemeData theme,
    String name,
    String role,
    String description,
    List<String> responsibilities,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                role,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ...responsibilities.map((responsibility) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(responsibility),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(ThemeData theme, String label, IconData icon) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: theme.colorScheme.onPrimaryContainer,
      ),
      label: Text(label),
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
