import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../database/user_database_helper.dart';
import '../models/user.dart';

class UnverifiedUsersPage extends ConsumerStatefulWidget {
  const UnverifiedUsersPage({super.key});

  @override
  ConsumerState<UnverifiedUsersPage> createState() => _UnverifiedUsersPageState();
}

class _UnverifiedUsersPageState extends ConsumerState<UnverifiedUsersPage> {
  Stream<List<User>> _getUnverifiedUsers() async* {
    while (true) {
      try {
        final users = await UserDatabaseHelper.instance.getUnverifiedUsers();
        yield users.map((map) => User.fromMap(map)).toList();
      } catch (e) {
        print('Error fetching users: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds: 2)); // Refresh every 2 seconds
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Users'),
      ),
      body: StreamBuilder<List<User>>(
        stream: _getUnverifiedUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(
              child: Text('No unverified users found'),
            );
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name[0].toUpperCase()),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: TextButton(
                    onPressed: () {
                      context.push('/assign-user', extra: user.toMap());
                    },
                    child: const Text('Verify'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
