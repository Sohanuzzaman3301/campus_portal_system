import 'package:campus_portal_system/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'major_page.dart';

class SkeletonPage extends ConsumerWidget {
  final Widget child;

  const SkeletonPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authNotifierProvider);

    // Handle logout
    Future<void> handleLogout() async {
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }

    // User profile menu items
    final List<PopupMenuEntry<String>> userMenuItems = [
      PopupMenuItem(
        value: 'profile',
        child: ListTile(
          leading: const Icon(Icons.person),
          title: Text(currentUser?.name ?? 'Profile'),
        ),
      ),
      const PopupMenuItem(
        value: 'edit_profile',
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit Profile'),
        ),
      ),
      const PopupMenuItem(
        value: 'logout',
        child: ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
        ),
      ),
    ];

    // Handle menu selection
    void handleMenuSelection(String value) {
      switch (value) {
        case 'profile':
          context.push('/profile');
          break;
        case 'edit_profile':
          context.push('/edit-profile');
          break;
        case 'logout':
          handleLogout();
          break;
      }
    }

    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).uri.path;

    // Check if current page is accessed from HomeCard
    final isHomeCardPage = [
      '/assign-user',
      '/library',
      '/students',
      '/teachers',
      '/schedule',
      '/dashboard',
      '/unverified-users',
      '/majors'
    ].contains(currentLocation);

    return Scaffold(
      // Conditionally show AppBar
      appBar: isHomeCardPage
          ? null
          : AppBar(
              title: const Text('Campus Portal'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
      drawer: NavigationDrawer(
        selectedIndex: _getSelectedIndex(currentLocation, ref),
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.onPrimary,
                  child: Text(
                    currentUser?.name[0].toUpperCase() ?? 'U',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser?.name ?? 'User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                Text(
                  currentUser?.email ?? 'email',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('Home'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: Text('Profile'),
          ),
          const NavigationDrawerDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text('Settings'),
          ),
          const Divider(),
          const NavigationDrawerDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: Text('About'),
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Majors & Courses'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MajorPage()),
              );
            },
          ),
        ],
        onDestinationSelected: (index) {
          // Close the drawer first
          Navigator.pop(context);

          // Then navigate
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/profile');
              break;
            case 2:
              context.go('/settings');
              break;
            case 3:
              context.go('/about');
              break;
            case 4:
              context.go('/majors');
              break;
          }
        },
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getSelectedIndex(currentLocation, ref),
        onDestinationSelected: (index) {
          if (currentUser?.role.toLowerCase() == 'student') {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/courses');
                break;
              case 2:
                context.go('/profile');
                break;
              case 3:
                context.go('/settings');
                break;
            }
          } else {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/profile');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          if (currentUser?.role.toLowerCase() == 'student')
            const NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book),
              label: 'Courses',
            )
          else
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          if (currentUser?.role.toLowerCase() == 'student')
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            )
          else
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          if (currentUser?.role.toLowerCase() == 'student')
            const NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location, WidgetRef ref) {
    final currentUser = ref.read(authNotifierProvider);

    if (currentUser?.role.toLowerCase() == 'student') {
      switch (location) {
        case '/':
          return 0;
        case '/courses':
          return 1;
        case '/profile':
          return 2;
        case '/settings':
          return 3;
        default:
          return 0;
      }
    } else {
      switch (location) {
        case '/':
          return 0;
        case '/profile':
          return 1;
        case '/settings':
          return 2;
        default:
          return 0;
      }
    }
  }
}
