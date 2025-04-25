import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/admin_layout.dart';
import '../providers/auth_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _tokenExpiration = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadTokenExpiration();
  }

  Future<void> _loadTokenExpiration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expiration = await authProvider.tokenExpiration;
    
    if (mounted) {
      setState(() {
        _tokenExpiration = expiration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Admin Dashboard',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard cards in a GridView
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(
                    context,
                    'Total Users',
                    '250',
                    Icons.people,
                    Colors.blue,
                  ),
                  _buildDashboardCard(
                    context,
                    'Active Users',
                    '180',
                    Icons.person_outline,
                    Colors.green,
                  ),
                  _buildDashboardCard(
                    context,
                    'Inactive Users',
                    '70',
                    Icons.person_off,
                    Colors.orange,
                  ),
                  _buildDashboardCard(
                    context,
                    'System Status',
                    'Online',
                    Icons.check_circle,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            
            // Token expiration card
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(top: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Session Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Token Expires: $_tokenExpiration'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadTokenExpiration,
                      child: const Text('Refresh Token Info'),
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

  Widget _buildDashboardCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}