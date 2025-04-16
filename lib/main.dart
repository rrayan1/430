import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/additional_info_page.dart';
import 'pages/doctor_signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      home: const HomePage(),
      routes: {
        '/profile': (context) => const ProfilePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/doctor_signup': (context) => const DoctorSignupPage(),
        '/additional_info': (context) => const AdditionalInfoPage(),
      },
    );
  }
}
