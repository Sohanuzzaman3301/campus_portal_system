import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_portal_system/constants/lottie_animations.dart';
import 'package:lottie/lottie.dart';
import 'package:ionicons/ionicons.dart';
import '../providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider);

    if (user == null) {
      return const Center(child: Text('No user data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Lottie.asset(
              LottieAnimations.profile,
              width: 150,
              height: 150,
              repeat: false,
              animate: true,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Ionicons.person_outline),
                    title: const Text('Name'),
                    subtitle: Text(user.name),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Ionicons.mail_outline),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Ionicons.shield_checkmark_outline),
                    title: const Text('Role'),
                    subtitle: Text(user.role[0].toUpperCase() + user.role.substring(1)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Ionicons.id_card_outline),
                    title: const Text('User ID'),
                    subtitle: Text(user.id?.toString() ?? 'N/A'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 