import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _ageController.text = data['age']?.toString() ?? '';
        _genderController.text = data['gender'] ?? '';
        _bloodTypeController.text = data['bloodType'] ?? '';
        _allergiesController.text = data['allergies'] ?? '';
        _homeAddressController.text = data['homeAddress'] ?? '';
        _emergencyContactController.text = data['emergencyContact'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'age': int.tryParse(_ageController.text) ?? 0,
        'gender': _genderController.text,
        'bloodType': _bloodTypeController.text,
        'allergies': _allergiesController.text,
        'homeAddress': _homeAddressController.text,
        'emergencyContact': _emergencyContactController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      debugPrint('❌ Error saving profile: $e');
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: label,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildPatientHistory() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('history')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Text('No history found.');

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(data['doctor'] ?? 'Unknown Doctor'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${_formatTimestamp(data['date'])}'),
                    const SizedBox(height: 4),
                    Text(data['notes'] ?? 'No notes provided.'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    return 'Invalid date';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                bool isWide = constraints.maxWidth > 700;
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        FirebaseAuth.instance.currentUser?.email ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            _buildTextField(
                                                _ageController, 'Age'),
                                            _buildTextField(
                                                _genderController, 'Gender'),
                                            _buildTextField(
                                                _bloodTypeController,
                                                'Blood Type'),
                                            _buildTextField(
                                                _allergiesController,
                                                'Allergies'),
                                            _buildTextField(
                                                _homeAddressController,
                                                'Home Address'),
                                            _buildTextField(
                                                _emergencyContactController,
                                                'Emergency Contact'),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: _saveProfile,
                                              child:
                                                  const Text('Update Profile'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Flexible(
                                  flex: 3,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Patient History',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildPatientHistory(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          _buildTextField(
                                              _ageController, 'Age'),
                                          _buildTextField(
                                              _genderController, 'Gender'),
                                          _buildTextField(_bloodTypeController,
                                              'Blood Type'),
                                          _buildTextField(_allergiesController,
                                              'Allergies'),
                                          _buildTextField(
                                              _homeAddressController,
                                              'Home Address'),
                                          _buildTextField(
                                              _emergencyContactController,
                                              'Emergency Contact'),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: _saveProfile,
                                            child: const Text('Update Profile'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Patient History',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 12),
                                        _buildPatientHistory(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _homeAddressController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }
}
