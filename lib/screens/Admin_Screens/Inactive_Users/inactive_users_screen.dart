import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:test_applicaiton_1/l10n/app_localizations.dart';
import 'package:test_applicaiton_1/providers/language_provider.dart';

import '../../../layouts/admin_layout.dart';
import '../../../models/base_response.dart';
import '../../../models/user.dart';
import '../../../providers/auth_provider.dart';

class InactiveUsersScreen extends StatefulWidget {
  const InactiveUsersScreen({super.key});

  @override
  State<InactiveUsersScreen> createState() => _InactiveUsersScreenState();
}

class _InactiveUsersScreenState extends State<InactiveUsersScreen> {
  bool _isLoading = true;
  List<User> _inactiveUsers = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchInactiveUsers();
  }

  Future<void> _fetchInactiveUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();

      final response = await http.get(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/UserManagement/GetInactiveUsers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final baseResponse = BaseResponse<User>.fromJson(
          jsonData, 
          (userJson) => User.fromJson(userJson)
        );
        
        setState(() {
          _inactiveUsers = baseResponse.responseData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load inactive users: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _activateUser(int userId) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getAccessToken();

      // Make API request to activate user with the userId in the URL
      final response = await http.put(
        Uri.parse('https://ph-ocelot.elhamylabs.com/api/UserManagement/ActivateUser/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // Show success toastr
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User activated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Refresh the list
        _fetchInactiveUsers();
      } else {
        // Show error toastr
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to activate user: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();
      
      // Show error toastr
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error activating user: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLocale.languageCode;

    return AdminLayout(
      title: AppLocalizations.translate('inactive_Users', lang),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with headline removed
            const SizedBox(height: 16),
            if (_isLoading && _inactiveUsers.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage.isNotEmpty && _inactiveUsers.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchInactiveUsers,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            else if (_inactiveUsers.isEmpty)
              const Center(
                child: Text('No inactive users found'),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchInactiveUsers,
                  child: ListView.builder(
                    itemCount: _inactiveUsers.length,
                    itemBuilder: (context, index) {
                      final user = _inactiveUsers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(user.userName[0]),
                          ),
                          title: Text(user.userName),
                          subtitle: Text(user.email),
                          trailing: ElevatedButton(
                            onPressed: () => _activateUser(user.userId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Activate'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}