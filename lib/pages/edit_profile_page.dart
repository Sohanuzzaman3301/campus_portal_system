// import 'package:campus_portal_system/providers/auth_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/user.dart';
// import '../database/user_database_helper.dart';
// import '../services/auth_service.dart';

// class EditProfilePage extends ConsumerStatefulWidget {
//   const EditProfilePage({Key? key}) : super(key: key);

//   @override
//   ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends ConsumerState<EditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Load current user data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final currentUser = ref.read(authNotifierProvider);
//       if (currentUser != null) {
//         _nameController.text = currentUser.name;
//         _emailController.text = currentUser.email;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final currentUser = ref.read(authNotifierProvider);

//       if (currentUser == null) {
//         throw Exception('No user logged in');
//       }

//       // Create updated user data
//       final updatedUser = currentUser.copyWith(
//         name: _nameController.text,
//         email: _emailController.text,
//         password: _passwordController.text.isNotEmpty
//             ? _passwordController.text
//             : currentUser.password,
//       );

//       // Update user in database
//       await UserDatabaseHelper.instance.updateUser(updatedUser);

//       // Update auth state
//       await ref.read(authNotifierProvider.notifier).updateProfile(updatedUser);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating profile: ${e.toString()}')),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Watch the auth state to rebuild when user data changes
//     final currentUser = ref.watch(authNotifierProvider);

//     if (currentUser == null) {
//       return const Scaffold(
//         body: Center(
//           child: Text('No user logged in'),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Profile'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Full Name',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   if (!value.contains('@')) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: 'New Password (optional)',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (value != null && value.isNotEmpty && value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),
//               TextFormField(
//                 controller: _confirmPasswordController,
//                 decoration: const InputDecoration(
//                   labelText: 'Confirm New Password',
//                   border: OutlineInputBorder(),
//                 ),
//                 obscureText: true,
//                 validator: (value) {
//                   if (_passwordController.text.isNotEmpty) {
//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _updateProfile,
//                 child: _isLoading
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : const Text('Update Profile'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// } 