import 'package:flutter/material.dart';
import 'pages/0_splash_page.dart';
import 'pages/1_home_page.dart';
import 'pages/4_profile_page.dart';
import 'pages/2_login_page.dart';
import 'pages/3_signup_page.dart';
import 'pages/7_doctor_signup_page.dart';
import 'pages/8_doctor_home_page.dart';
import 'pages/9_doctor_profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carebook',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/doctor_signup': (context) => const DoctorSignupPage(),
        '/doctor_home': (context) => const DoctorHomePage(),
        '/doctor_profile': (context) => const DoctorProfilePage(),
      },
    );
  }
}
