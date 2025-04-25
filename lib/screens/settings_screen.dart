import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_applicaiton_1/widgets/admin_layout.dart';
import '../widgets/app_layout.dart';
import '../providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    _selectedLanguage = languageProvider.currentLocale.languageCode == 'en' ? 'English' : 'Arabic';
  }

  void _changeLanguage(String language) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    String languageCode = language == 'English' ? 'en' : 'ar';
    languageProvider.changeLanguage(languageCode);
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Settings',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'English',
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                        _changeLanguage(value);
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('العربية'),
                    value: 'Arabic',
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                        _changeLanguage(value);
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}