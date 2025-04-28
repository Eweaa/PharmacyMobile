import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../layouts/user_layout.dart';
import '../../../providers/auth_provider.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  String _tokenExpiration = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadTokenExpiration();
  }

  Future<void> _loadTokenExpiration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expiration = await authProvider.formattedTokenExpiration;
    
    if (mounted) {
      setState(() {
        _tokenExpiration = expiration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UserLayout(
      title: 'Home',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text('My Profile'),
                subtitle: const Text('View and edit your profile'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to profile
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.grey),
                title: const Text('Settings'),
                subtitle: const Text('App preferences and settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to settings
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.help, color: Colors.green),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help with the app'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to help
                },
              ),
            ),
            // Add token expiration information
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Token Expires: $_tokenExpiration'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadTokenExpiration,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}