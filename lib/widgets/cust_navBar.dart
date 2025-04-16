import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Carebook'),
      backgroundColor: Colors.blue,
      actions: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: const Text("Sign In", style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
