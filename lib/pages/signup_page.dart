import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create your account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _inputField(nameController, "Full Name", Icons.person),
                const SizedBox(height: 12),
                _inputField(emailController, "Email", Icons.mail),
                const SizedBox(height: 12),
                _inputField(passwordController, "Password", Icons.lock,
                    isObscure: true),
                const SizedBox(height: 12),
                _inputField(phoneController, "Phone Number", Icons.phone),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final authResult = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );

                        final uid = authResult.user?.uid;

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .set({
                          'name': nameController.text.trim(),
                          'email': emailController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'createdAt': Timestamp.now(),
                        });

                        Navigator.pushNamed(context, '/additional_info');
                      } on FirebaseAuthException catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Sign Up Failed"),
                            content: Text(e.message ?? "Unknown error"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"))
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B50FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Sign Up",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("If you are a doctor, "),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/doctor_signup'),
                      child: const Text("press here.",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: const Text("Sign in",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller, String hint, IconData icon,
      {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
