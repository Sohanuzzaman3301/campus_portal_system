import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/theme_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);
    final breakpoints = ResponsiveBreakpoints.of(context);
    final isMobile = breakpoints.smallerThan(TABLET);
    final isDesktop = breakpoints.largerThan(TABLET);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Account Settings
          _SettingsSection(
            title: 'Account',
            icon: Ionicons.person_circle_outline,
            children: [
              ListTile(
                leading: const Icon(Ionicons.person_outline),
                title: const Text('Edit Profile'),
                subtitle: const Text('Change your personal information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/edit-profile'),
              ),
              ListTile(
                leading: const Icon(Ionicons.key_outline),
                title: const Text('Change Password'),
                subtitle: const Text('Update your password'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Ionicons.mail_outline),
                title: const Text('Email Settings'),
                subtitle: const Text('Manage email preferences'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Notifications
          _SettingsSection(
            title: 'Notifications',
            icon: Ionicons.notifications_outline,
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive push notifications'),
                secondary: const Icon(Ionicons.push_outline),
                value: true,
                onChanged: (bool value) {},
              ),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receive email updates'),
                secondary: const Icon(Ionicons.mail_outline),
                value: true,
                onChanged: (bool value) {},
              ),
              ListTile(
                leading: const Icon(Ionicons.options_outline),
                title: const Text('Notification Preferences'),
                subtitle: const Text('Customize notification settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Appearance
          _SettingsSection(
            title: 'Appearance',
            icon: Ionicons.color_palette_outline,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Theme'),
                subtitle: const Text('Follow system settings'),
                secondary: const Icon(Ionicons.phone_portrait_outline),
                value: ThemeMode.system,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setTheme(value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                subtitle: const Text('Use light color scheme'),
                secondary: const Icon(Ionicons.sunny_outline),
                value: ThemeMode.light,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setTheme(value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                subtitle: const Text('Use dark color scheme'),
                secondary: const Icon(Ionicons.moon_outline),
                value: ThemeMode.dark,
                groupValue: currentTheme,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setTheme(value);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Privacy & Security
          _SettingsSection(
            title: 'Privacy & Security',
            icon: Ionicons.shield_checkmark_outline,
            children: [
              SwitchListTile(
                title: const Text('Two-Factor Authentication'),
                subtitle: const Text('Enable 2FA for added security'),
                secondary: const Icon(Ionicons.lock_closed_outline),
                value: false,
                onChanged: (bool value) {},
              ),
              ListTile(
                leading: const Icon(Ionicons.document_text_outline),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Ionicons.document_outline),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About & Support
          _SettingsSection(
            title: 'About & Support',
            icon: Ionicons.information_circle_outline,
            children: [
              ListTile(
                leading: const Icon(Ionicons.help_circle_outline),
                title: const Text('Help Center'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Ionicons.chatbox_outline),
                title: const Text('Contact Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
