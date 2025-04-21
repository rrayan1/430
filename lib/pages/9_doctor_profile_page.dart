import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _consultationFeesController = TextEditingController();

  String? _experience;
  String? _availabilityStart;
  String? _availabilityEnd;

  final List<String> experienceOptions = [
    "0-5 years",
    "5-10 years",
    "10-15 years",
    "15+ years"
  ];

  final List<String> timeOptions = [
    "08:00 AM",
    "09:00 AM",
    "10:00 AM",
    "11:00 AM",
    "12:00 PM",
    "01:00 PM",
    "02:00 PM",
    "03:00 PM",
    "04:00 PM",
    "05:00 PM",
    "06:00 PM",
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _specializationController.text = data['specialization'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _experience = data['experience'];
        _availabilityStart = data['availability_start'];
        _availabilityEnd = data['availability_end'];
        _consultationFeesController.text = data['consultation_fees'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading doctor data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'phone': _phoneController.text.trim(),
        'experience': _experience ?? '',
        'availability_start': _availabilityStart ?? '',
        'availability_end': _availabilityEnd ?? '',
        'consultation_fees': _consultationFeesController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      debugPrint('❌ Error saving doctor profile: $e');
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

  Widget _buildDropdownField(String label, List<String> options,
      String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: (currentValue != null && currentValue.isNotEmpty)
            ? currentValue
            : null,
        decoration: InputDecoration(
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: options
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? 'Select $label' : null,
      ),
    );
  }

  Widget _buildAvailabilityRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value:
                  (_availabilityStart != null && _availabilityStart!.isNotEmpty)
                      ? _availabilityStart
                      : null,
              decoration: InputDecoration(
                hintText: "Availability Start",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: timeOptions
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _availabilityStart = value;
                });
              },
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: (_availabilityEnd != null && _availabilityEnd!.isNotEmpty)
                  ? _availabilityEnd
                  : null,
              decoration: InputDecoration(
                hintText: "Availability End",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: timeOptions
                  .map((time) =>
                      DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _availabilityEnd = value;
                });
              },
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
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
                            _buildTextField(_nameController, 'Name'),
                            _buildTextField(
                                _specializationController, 'Specialization'),
                            _buildTextField(_phoneController, 'Phone Number'),
                            _buildDropdownField(
                                'Experience', experienceOptions, _experience,
                                (value) {
                              setState(() {
                                _experience = value;
                              });
                            }),
                            _buildAvailabilityRow(),
                            _buildTextField(_consultationFeesController,
                                'Consultation Fees'),
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
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _phoneController.dispose();
    _consultationFeesController.dispose();
    super.dispose();
  }
}
