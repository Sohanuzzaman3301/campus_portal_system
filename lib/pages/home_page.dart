import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);
    final isAdmin = user?.role.toLowerCase() == 'admin';
    final breakpoints = ResponsiveBreakpoints.of(context);
    final isMobile = breakpoints.smallerThan(TABLET);
    final isTablet = breakpoints.between(TABLET, DESKTOP);

    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : isTablet ? 3 : 4,
          childAspectRatio: isMobile ? 1 : 1.3,
          crossAxisSpacing: isMobile ? 16 : 24,
          mainAxisSpacing: isMobile ? 16 : 24,
        ),
        itemCount: isAdmin ? 8 : 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _HomeCard(
                title: 'Dashboard',
                icon: Ionicons.grid_outline,
                color: Colors.blue,
                onTap: () => context.push('/dashboard'),
              );
            case 1:
              return _HomeCard(
                title: 'Courses',
                icon: Ionicons.book_outline,
                color: Colors.green,
                onTap: () => context.push('/courses'),
              );
            case 2:
              return _HomeCard(
                title: 'Schedule',
                icon: Ionicons.calendar_outline,
                color: Colors.orange,
                onTap: () => context.push('/schedule'),
              );
            case 3:
              return _HomeCard(
                title: 'Library',
                icon: Ionicons.library_outline,
                color: Colors.purple,
                onTap: () => context.push('/library'),
              );
            case 4:
              if (isAdmin) {
                return _HomeCard(
                  title: 'Students',
                  icon: Ionicons.people_outline,
                  color: Colors.teal,
                  onTap: () => context.push('/students'),
                );
              }
              return const SizedBox.shrink();
            case 5:
              if (isAdmin) {
                return _HomeCard(
                  title: 'Teachers',
                  icon: Ionicons.school_outline,
                  color: Colors.indigo,
                  onTap: () => context.push('/teachers'),
                );
              }
              return const SizedBox.shrink();
            case 6:
              if (isAdmin) {
                return _HomeCard(
                  title: 'Pending Users',
                  icon: Ionicons.people_circle_outline,
                  color: Colors.amber,
                  onTap: () => context.push('/unverified-users'),
                );
              }
              return const SizedBox.shrink();
            case 7:
              if (isAdmin) {
                return _HomeCard(
                  title: 'Majors',
                  icon: Ionicons.school_outline,
                  color: Colors.deepPurple,
                  onTap: () => context.push('/majors'),
                );
              }
              return const SizedBox.shrink();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).smallerThan(TABLET);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isMobile ? 36 : 48,
                color: color,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: isMobile ? 16 : 18,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 