import 'dart:async';

import 'package:campus_portal_system/models/user.dart';
import 'package:campus_portal_system/pages/major_page.dart';
import 'package:campus_portal_system/pages/students_page.dart';
import 'package:campus_portal_system/pages/teachers_page.dart';
import 'package:campus_portal_system/pages/unverified_users_page.dart';
import 'package:campus_portal_system/providers/auth_provider.dart';
import 'package:campus_portal_system/widgets/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Auth Pages
import '../pages/login_page.dart';
import '../pages/register_page.dart';

// Main Pages
import '../pages/home_page.dart';
import '../pages/about_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../pages/courses_page.dart';
import '../pages/library_page.dart';
import '../pages/dashboard_page.dart';

// Layout Pages
import '../pages/skeleton_page.dart';

// Import the new pages
import '../pages/assign_user_page.dart';
import '../pages/schedule_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    refreshListenable: RouterRefreshStream(authNotifier.stream),
    redirect: (context, state) async {
      // Check current login status
      final isLoggedIn = await ref.read(authServiceProvider).isLoggedIn();
      
      // Get the current path
      final path = state.uri.path;
      final isLoginRoute = path == '/login';
      final isRegisterRoute = path == '/register';
      final isAuthRoute = isLoginRoute || isRegisterRoute;

      if (!isLoggedIn) {
        // If not logged in and trying to access protected route
        return isAuthRoute ? null : '/login';
      } else {
        // If logged in and trying to access auth routes
        return isAuthRoute ? '/' : null;
      }
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildPageTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => buildPageTransition(
          context: context,
          state: state,
          child: const RegisterPage(),
        ),
      ),

      // Main Shell Route with SkeletonPage
      ShellRoute(
        builder: (context, state, child) => SkeletonPage(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: '/about',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const AboutPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const SettingsPage(),
            ),
          ),
          GoRoute(
            path: '/teachers',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const TeachersPage(),
            ),
          ),
          GoRoute(
            path: '/students',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const StudentsPage(),
            ),
          ),
          GoRoute(
            path: '/unverified-users',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const UnverifiedUsersPage(),
            ),
          ),
          // Common Routes
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const ProfilePage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const SettingsPage(),
            ),
          ),
          GoRoute(
            path: '/courses',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const CoursesPage(),
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const LibraryPage(),
            ),
          ),
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/majors',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: const MajorPage(),
            ),
          ),
          // Add this route in your router configuration
          GoRoute(
            path: '/assign-user',
            pageBuilder: (context, state) => buildPageTransition(
              context: context,
              state: state,
              child: AssignUserPage(
                user: state.extra as Map<String, dynamic>,
              ),
            ),
          ),
          // Add this route to your router configuration
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const SchedulePage(),
          ),
          // // Add this route to your router configuration
          // GoRoute(
          //   path: '/edit-profile',
          //   builder: (context, state) => const EditProfilePage(),
          // // ),
          // GoRoute(
          //   path: '/edit-profile',
          //   pageBuilder: (context, state) => buildPageTransition(
          //     context: context,
          //     state: state,
          //     child: const EditProfilePage(),
          //   ),
          // ),
        ],
      ),
    ],
    // Add error handling
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    ),
  );
});

// Helper class to refresh router on auth state changes
class RouterRefreshStream extends ChangeNotifier {
  RouterRefreshStream(Stream<User?> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (User? user) => notifyListeners(),
    );
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
