import 'package:flutter/material.dart';
import 'inactive_users_screen.dart';
import '../widgets/app_layout.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Dashboard',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  title: 'Total Users',
                  value: '1,234',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                DashboardCard(
                  title: 'Active Users',
                  value: '1,089',
                  icon: Icons.person_outline,
                  color: Colors.green,
                ),
                DashboardCard(
                  title: 'Inactive Users',
                  value: '145',
                  icon: Icons.person_off,
                  color: Colors.orange,
                ),
                DashboardCard(
                  title: 'New Today',
                  value: '25',
                  icon: Icons.person_add,
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}