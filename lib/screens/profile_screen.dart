import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/transitions.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1E88E5),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
              value: context.watch<ThemeProvider>().isDarkMode,
              onChanged: (val) {
                context.read<ThemeProvider>().toggleTheme(val);
              },
              secondary: const Icon(Icons.dark_mode_outlined),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            _buildProfileItem(context, Icons.badge_outlined, 'Student Name', user.name),
            const Divider(),
            _buildProfileItem(context, Icons.email_outlined, 'Email', user.email),
            const Divider(),
            _buildProfileItem(context, Icons.school_outlined, 'Course/Program', user.course),
            const SizedBox(height: 48),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushReplacement(
                    FadePageRoute(page: const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18, color: Colors.redAccent),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(178),
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
