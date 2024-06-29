import 'package:flutter/material.dart';
import 'package:pativar_flutter_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    // Navigate back to MyApp to restart the application flow
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const RootApp()), // Use RootApp to reset the application state
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: const Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
