import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';
import '../screens/Admin_Screens/Active_Users/active_users_screen.dart';
import '../screens/Admin_Screens/Inactive_Users/inactive_users_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/Shared/login_screen.dart';
import '../screens/Admin_Screens/Admin_Home_Screen/admin_home_screen.dart';
import '../providers/auth_provider.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const AdminLayout({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(title.toLowerCase(), lang)),
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                AppLocalizations.translate('admin_menu', lang),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(AppLocalizations.translate('dashboard', lang)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminHomeScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: Text(AppLocalizations.translate('inactive_users', lang)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InactiveUsersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppLocalizations.translate('active_users', lang)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ActiveUsersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      // Bottom navigation bar removed
      backgroundColor: Theme.of(context).colorScheme.background,
      body: child,
    );
  }
}