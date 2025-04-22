
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:labproject/pages/9_doctor_profile_page.dart';
import '../widgets/custom_navbar.dart';
import 'package:intl/intl.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  Stream<QuerySnapshot> _getTodaysAppointments() {
    final today = DateTime.now();
    final formattedToday = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctor', isEqualTo: 'Dr. Moe (Pediatrics)')
        .where('date', isEqualTo: '2025-04-22') // 🔥 override for now

        .orderBy('slot')
        .snapshots();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: const CustomNavBar(),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left half - Patient Appointments
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Check your patients for today!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                FutureBuilder<QuerySnapshot>(
  future: FirebaseFirestore.instance
      .collection('appointments')
      .where('doctor', isEqualTo: 'Dr. Moe (Pediatrics)')
      .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(DateTime.now()))
      .get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Text("No appointments for today.");
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                String displayName = userId;
                if (userSnapshot.connectionState == ConnectionState.done &&
                    userSnapshot.hasData &&
                    userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  displayName = userData['Name'] ?? userId;
                }

                return _patientCard(
  name: displayName,
  userId: userId,
  time: data['slot'] ?? '',
  imageUrl: "https://randomuser.me/api/portraits/men/11.jpg",
  context: context,
);

              },
            );
          }).toList(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Right half - Quick Actions
          // Right half - Quick Actions
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text(
        "Quick Actions",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
  )));
}

 Widget _patientCard({
    required String name,
    required String userId,
    required String time,
    required String imageUrl,
    required BuildContext context,
  }) {
    return InkWell(
      onTap: () async {
        final userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userData = userSnapshot.data();

        final gender = userData?['gender'] ?? 'N/A';
        final age = userData?['age']?.toString() ?? 'N/A';
        final bloodType = userData?['bloodType'] ?? 'N/A';

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Age: $age"),
                Text("Gender: $gender"),
                Text("Blood Type: $bloodType"),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        );
      },
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
              Text("Patient: $name", textAlign: TextAlign.center),
              Text("Time: $time"),
              const SizedBox(height: 12),
              const Text("Tap to view more", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUpdateAvailability(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DoctorProfilePage()),
    );
  }

  // void _navigateToRecordsPage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (_) => const PlaceholderPage(title: "Patient Records")),
  //   );
  // }

  void _showOnlineRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Online Room'),
        content: const Text('A virtual consultation room will be available soon.'),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // void _navigateToPrescriptionPage(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //         builder: (_) => const PlaceholderPage(title: "Write Prescription")),
  //   );
  // }

  Widget _buildQuickActions(BuildContext context) {
  return Wrap(
    spacing: 20,
    runSpacing: 20,
    alignment: WrapAlignment.center,
    children: [
      _actionCard(context, Icons.access_time, "Update Availability", _navigateToUpdateAvailability),
      _actionCard(context, Icons.videocam, "Open Online Room", _showOnlineRoomDialog),
    ],
  );
}

Widget _actionCard(BuildContext context, IconData icon, String label, void Function(BuildContext) onTap) {
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
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}
}