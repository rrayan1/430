import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorSignupPage extends StatefulWidget {
  const DoctorSignupPage({super.key});

  @override
  State<DoctorSignupPage> createState() => _DoctorSignupPageState();
}

class _DoctorSignupPageState extends State<DoctorSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  Future<void> _signUpDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = authResult.user?.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': 'doctor',
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor account created successfully!')),
      );

      Navigator.of(context)
          .pushNamedAndRemoveUntil('/doctor_home', (route) => false);
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sign Up Failed"),
          content: Text(e.message ?? "Unknown error occurred."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Shows back button if available
        title: const Text("Doctor Sign Up"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: 800,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _inputField(_nameController, "Full Name", Icons.person),
                  const SizedBox(height: 12),
                  _inputField(_emailController, "Email", Icons.mail),
                  const SizedBox(height: 12),
                  _inputField(_passwordController, "Password", Icons.lock,
                      isObscure: true),
                  const SizedBox(height: 12),
                  _inputField(_phoneController, "Phone Number", Icons.phone),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _signUpDoctor,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B50FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Sign Up as a Doctor",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isObscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Please enter $hint' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
