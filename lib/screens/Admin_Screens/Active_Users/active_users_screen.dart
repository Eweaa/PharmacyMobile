import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_applicaiton_1/l10n/app_localizations.dart';
import 'package:test_applicaiton_1/layouts/admin_layout.dart';
import 'package:test_applicaiton_1/providers/language_provider.dart';
import 'package:test_applicaiton_1/styles/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActiveUsersScreen extends StatefulWidget {
  const ActiveUsersScreen({super.key});

  @override
  State<ActiveUsersScreen> createState() => _ActiveUsersScreenState();
}

class _ActiveUsersScreenState extends State<ActiveUsersScreen> {
  bool _isLoading = true;
  List<dynamic> _activeUsers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchActiveUsers();
  }

  Future<void> _fetchActiveUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Using a sample API endpoint - replace with your actual endpoint
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
      
      if (response.statusCode == 200) {
        setState(() {
          _activeUsers = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load active users. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching active users: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLocale.languageCode;
    
    return AdminLayout(
      title: AppLocalizations.translate('active_Users', lang),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : _activeUsers.isEmpty
                  ? Center(child: Text('No active users found'))
                  : ListView.builder(
                      itemCount: _activeUsers.length,
                      itemBuilder: (context, index) {
                        final user = _activeUsers[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colorz.blue,
                              child: Text(
                                user['name'][0],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(user['name']),
                            subtitle: Text(user['email']),
                            trailing: Icon(Icons.check_circle, color: Colors.green),
                            onTap: () {
                              // Show user details or actions
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('User Details'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Name: ${user['name']}'),
                                      Text('Email: ${user['email']}'),
                                      Text('Phone: ${user['phone']}'),
                                      Text('Website: ${user['website']}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}