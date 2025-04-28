import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:test_applicaiton_1/providers/auth_provider.dart';
import 'package:test_applicaiton_1/screens/Shared/splash_screen.dart';
import 'package:test_applicaiton_1/styles/colors.dart';
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageProvider = LanguageProvider();
  final authProvider = AuthProvider();
  await Future.wait([
    languageProvider.init(),
    authProvider.init(), // This will now check token expiration and logout if needed
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => languageProvider),
        ChangeNotifierProvider(create: (_) => authProvider),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, AuthProvider>(
      builder: (context, languageProvider, authProvider, child) {
        return MaterialApp(
          title: 'Agza5ana',
          locale: languageProvider.currentLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
          ],
          debugShowCheckedModeBanner: false,  // Add this line to remove debug banner
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primaryColor: Colorz.blue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A73E8),  // Google Blue
              primary: Colorz.blue,
              secondary: const Color(0xFF4285F4),
              tertiary: const Color(0xFF8AB4F8),
              // surface: const Color(0xFFF8F9FC),
              surface: const Color.fromARGB(255, 255, 255, 255),
            ),
            appBarTheme: AppBarTheme(
              // backgroundColor: Color(0xFF1A73E8),
              backgroundColor: Colorz.blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}
