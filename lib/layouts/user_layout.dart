import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../screens/Shared/login_screen.dart';

class UserLayout extends StatelessWidget {
  final Widget child;
  final String title;

  const UserLayout({
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
                AppLocalizations.translate('app_menu', lang),
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
                // Navigate to user dashboard
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(AppLocalizations.translate('profile', lang)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.translate('settings', lang)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                AppLocalizations.translate('logout', lang),
                style: const TextStyle(color: Colors.red),
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
      body: child,
    );
  }
}