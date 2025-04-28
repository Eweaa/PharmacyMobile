import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_applicaiton_1/l10n/app_localizations.dart';
import 'package:test_applicaiton_1/providers/auth_provider.dart';
import 'package:test_applicaiton_1/styles/colors.dart';
import '../../providers/language_provider.dart';
import '../User_Screens/Register/register_screen.dart';
import '../User_Screens/User_Home/user_home_screen.dart';
import '../Admin_Screens/Admin_Home_Screen/admin_home_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toastification/toastification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final lang = languageProvider.currentLocale.languageCode;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Center(  // Added Center widget here
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,  // Added this for horizontal centering
                    children: [
                      SizedBox(height: 40),
                      Image.asset(
                        'assets/medicine.png',
                        height: 120,
                      ),
                      SizedBox(height: 20),
                      // Text(
                      //   AppLocalizations.translate('login_title', lang),
                      //   style: TextStyle(
                      //     fontSize: 26,
                      //     fontWeight: FontWeight.bold,
                      //     color: Theme.of(context).colorScheme.primary,
                      //   ),
                      // ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.translate('email', lang),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50), // Match button radius
                            borderSide: BorderSide(color: Colorz.blue), // Match button color
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colorz.blue, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colorz.blue, width: 3),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.translate('email_required', lang);
                          }
                          // Email validation using regex
                          // final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          // if (!emailRegex.hasMatch(value)) {
                          //   return AppLocalizations.translate('email_invalid', lang);
                          // }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.translate('password', lang),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50), // Match button radius
                            borderSide: BorderSide(color: Colorz.blue), // Match button color
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colorz.blue, width: 2), // Increased width from 1 to 2
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide(color: Colorz.blue, width: 3), // Increased width from 2 to 3
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.translate('password_required', lang);
                          }
                          if (value.length < 6) {
                            return AppLocalizations.translate('password_too_short', lang);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity, // Makes the button take full width
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                           backgroundColor: Colorz.blue,
                           foregroundColor: Colors.white,
                           padding: EdgeInsets.symmetric(vertical: 12), // Reduced from 16 to 12
                           minimumSize: Size.fromHeight(44), // Reduced from 48 to 44
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(50), // Match input border radius
                           ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              );
                              
                              try {
                                // Make API request
                                final response = await http.post(
                                  Uri.parse('https://ph-identity-s4.elhamylabs.com/connect/token'),
                                  headers: {
                                    'Content-Type': 'application/x-www-form-urlencoded',
                                  },
                                  body: {
                                    'username': _emailController.text,
                                    'password': _passwordController.text,
                                    'grant_type': 'password',
                                    'client_id': 'Jada-30.angular.production',
                                    'scope': 'read openid offline_access',
                                    'aud': 'Jada30APIGateWay',
                                  },
                                );
                                
                                // Close loading dialog
                                Navigator.of(context).pop();
                                
                                if (response.statusCode == 200) {
                                  // Successful login
                                  final responseData = json.decode(response.body);
                                  
                                  // Extract token and expiration
                                  final String accessToken = responseData['access_token'];
                                  final int expiresIn = responseData['expires_in'];
                                  
                                  // Store token or other data if needed
                                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                  await authProvider.login(_emailController.text, token: accessToken, expiresIn: expiresIn);
                                  
                                  // Show success toast
                                  toastification.show(
                                    context: context,
                                    type: ToastificationType.success,
                                    style: ToastificationStyle.flat,
                                    title: Text('Success'),
                                    description: Text(AppLocalizations.translate('login_successful', lang)),
                                    alignment: Alignment.topCenter,
                                    autoCloseDuration: const Duration(seconds: 3),
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                  );
                                  
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => authProvider.userRole == 'admin' 
                                        ? const AdminHomeScreen() 
                                        : const UserHomeScreen(),
                                    ),
                                  );
                                } else {
                                  // Failed login
                                  toastification.show(
                                    context: context,
                                    type: ToastificationType.error,
                                    style: ToastificationStyle.flat,
                                    title: Text('Failed'),
                                    alignment: Alignment.topCenter,
                                    description: Text(AppLocalizations.translate('login_failed', lang)),
                                    autoCloseDuration: const Duration(seconds: 3),
                                    icon: const Icon(Icons.error, color: Colors.red,), // rror ic
                                  );
                                }
                              } catch (e) {
                                // Close loading dialog
                                Navigator.of(context).pop();
                                
                                // Show error toast
                                toastification.show(
                                  context: context,
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.flat,
                                  title: Text('Error'),
                                  alignment: Alignment.topCenter,
                                  description: Text('${AppLocalizations.translate('login_failed', lang)}: $e'),
                                  autoCloseDuration: const Duration(seconds: 3),
                                  icon: const Icon(Icons.error, color: Colors.red,), // Add an error ic
                                );
                              }
                            }
                          },
                          child: Text(
                            AppLocalizations.translate('login_title', lang),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ),
                      ),
                      SizedBox(height: 32), // Increased from 16 to 32
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: Text('Don\'t have an account? Register', style: TextStyle(
                          color: Colorz.blue, 
                        ),),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}