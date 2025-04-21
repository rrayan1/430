import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 ADD this import

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Carebook'),
      backgroundColor: Colors.blue,
      actions: [
        if (user == null) ...[
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: const Text("Sign In", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
          ),
        ] else ...[
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final snapshot = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .get();

                final data = snapshot.data();
                final isDoctor = data != null && data['role'] == 'doctor';

                if (isDoctor) {
                  Navigator.pushNamed(context, '/doctor_profile');
                } else {
                  Navigator.pushNamed(context, '/profile');
                }
              }
            },
            child: const Text("Profile", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
