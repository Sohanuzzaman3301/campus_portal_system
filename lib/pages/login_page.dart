import 'package:campus_portal_system/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_portal_system/constants/lottie_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:ionicons/ionicons.dart';
import 'package:campus_portal_system/database/user_database_helper.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSeeding = false;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final success = await ref.read(authNotifierProvider.notifier).login(
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          if (success) {
            context.go('/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid email or password')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _createMockData() async {
    setState(() => _isSeeding = true);
    try {
      await UserDatabaseHelper.instance.seedMockUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mock users created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating mock users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSeeding = false);
    }
  }

  Future<void> _quickAdminLogin() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authNotifierProvider.notifier).login(
            'admin@campus.edu',
            'admin123',
          );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin login failed. Create mock data first.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breakpoints = ResponsiveBreakpoints.of(context);
    final isMobile = breakpoints.smallerThan(TABLET);
    final isDesktop = breakpoints.largerThan(TABLET);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24 : isDesktop ? 48 : 32,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDesktop) const SizedBox(height: 48),
                Lottie.asset(
                  LottieAnimations.login,
                  width: isDesktop ? 300 : 200,
                  height: isDesktop ? 300 : 200,
                  repeat: false,
                  animate: true,
                ),
                SizedBox(height: isDesktop ? 48 : 32),
                Card(
                  elevation: isDesktop ? 4 : 2,
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 32 : 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Ionicons.mail_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isDesktop ? 24 : 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Ionicons.lock_closed_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isDesktop ? 32 : 24),
                          SizedBox(
                            width: double.infinity,
                            height: isDesktop ? 48 : 44,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Login'),
                            ),
                          ),
                          SizedBox(height: isDesktop ? 24 : 16),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text('Don\'t have an account? Register'),
                          ),
                          if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                            TextButton.icon(
                              onPressed: _isSeeding ? null : _createMockData,
                              icon: _isSeeding
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Ionicons.people_outline),
                              label: const Text('Create Mock Data (Dev Only)'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _isLoading ? null : _quickAdminLogin,
                              icon: const Icon(Ionicons.person_circle_outline),
                              label: const Text('Quick Admin Login (Dev Only)'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (isDesktop) const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
} 