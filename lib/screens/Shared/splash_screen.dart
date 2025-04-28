import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_applicaiton_1/providers/auth_provider.dart';

import '../User_Screens/User_Home/user_home_screen.dart';
import '../Admin_Screens/Admin_Home_Screen/admin_home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => authProvider.userRole == 'admin' 
            ? const AdminHomeScreen() 
            : const UserHomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/Agza5anaBlack.jpg',
          height: 100,
        ),
      ),
    );
  }
}