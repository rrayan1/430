import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_navbar.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  late String _doctorUid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorUid();
  }

  Future<void> _loadDoctorUid() async {
    _doctorUid = FirebaseAuth.instance.currentUser!.uid;
    setState(() {
      _isLoading = false;
    });
  }

  Stream<QuerySnapshot> _getAllAppointments() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctor', isEqualTo: _doctorUid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side - Appointments
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Check your patients!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _getAllAppointments(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text("No appointments found.");
                      }

                      final appointments = snapshot.data!.docs;

                      // Sort appointments by slot alphabetically (optional)
                      appointments.sort((a, b) {
                        final slotA = a['slot'] ?? '';
                        final slotB = b['slot'] ?? '';
                        return slotA.compareTo(slotB);
                      });

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: appointments.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(data['userId'])
                                  .get(),
                              builder: (context, userSnapshot) {
                                final userData = userSnapshot.data?.data()
                                        as Map<String, dynamic>? ??
                                    {};
                                final patientName =
                                    userData['name'] ?? 'Unknown';
                                final imageUrl = userData['profilePicture'] ??
                                    "https://randomuser.me/api/portraits/men/11.jpg";

                                return _patientCard(
                                  context: context,
                                  patientName: patientName,
                                  appointmentId: doc.id,
                                  time: data['slot'] ?? '',
                                  imageUrl: imageUrl,
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right Side - Quick Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildQuickActions(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientCard({
    required BuildContext context,
    required String patientName,
    required String appointmentId,
    required String time,
    required String imageUrl,
  }) {
    return InkWell(
      onTap: () =>
          _showPatientDialog(context, patientName, appointmentId, time),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(right: 16),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 32, backgroundImage: NetworkImage(imageUrl)),
              const SizedBox(height: 12),
              Text(patientName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Time: $time"),
              const SizedBox(height: 12),
              const Text("Tap to manage", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatientDialog(BuildContext context, String patientName,
      String appointmentId, String time) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(patientName),
        content: Text("Time: $time\n\nWhat would you like to do?"),
        actions: [
          TextButton(
            child: const Text("Cancel Appointment",
                style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog first
              await FirebaseFirestore.instance
                  .collection('appointments')
                  .doc(appointmentId)
                  .delete();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Appointment canceled.")));
              }
            },
          ),
          TextButton(
            child: const Text("Reschedule"),
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Reschedule feature coming soon!")));
            },
          ),
          TextButton(
            child: const Text("Close"),
            onPressed: () => Navigator.pop(dialogContext),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _actionCard(context, Icons.access_time, "Update Availability",
            _navigateToUpdateAvailability),
        _actionCard(
            context, Icons.videocam, "Open Online Room", _showOnlineRoomDialog),
      ],
    );
  }

  Widget _actionCard(BuildContext context, IconData icon, String label,
      void Function(BuildContext) onTap) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        width: 180,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToUpdateAvailability(BuildContext context) {
    Navigator.pushNamed(context, '/doctor_profile');
  }

  void _showOnlineRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Online Room'),
        content:
            const Text('A virtual consultation room will be available soon.'),
        actions: [
          TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
