// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:luxe/core/controller/auth_controller.dart';
import 'package:luxe/core/model/auth_model.dart';

class ProfilePage extends StatefulWidget {
  final UserController userController;

  const ProfilePage({super.key, required this.userController});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    widget.userController.loadUserFromPreferences();
    setState(() {
      _user = widget.userController.currentUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_user!.photoURL != null)
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(_user!.photoURL!),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Username: ${_user!.username ?? "No username available"}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'User ID: ${_user!.uid}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${_user!.email}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Is Admin: ${_user!.isAdmin ? "Yes" : "No"}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
