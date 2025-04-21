import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // 🔥 align everything to TOP
          children: [
            // Left Half
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // 🔥 center horizontally
                children: [
                  const Text(
                    "Check your patients for today!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildPatientCards(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right Half
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.center, // 🔥 center horizontally
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center, // 🔥 center cards horizontally
        children: [
          _patientCard(
            name: "Flan El Foulani",
            age: 26,
            gender: "Male",
            bloodType: "A+",
            time: "10:00 AM",
            room: "435",
            imageUrl: "https://randomuser.me/api/portraits/men/32.jpg",
          ),
          const SizedBox(width: 16),
          _patientCard(
            name: "Jane Doe",
            age: 29,
            gender: "Female",
            bloodType: "O+",
            time: "10:30 AM",
            room: "440",
            imageUrl: "https://randomuser.me/api/portraits/women/44.jpg",
          ),
        ],
      ),
    );
  }

  Widget _patientCard({
    required String name,
    required int age,
    required String gender,
    required String bloodType,
    required String time,
    required String room,
    required String imageUrl,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: NetworkImage(imageUrl),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: "Name: ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: name),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text("Age: $age"),
            Text("Gender: $gender"),
            Text("Blood Type: $bloodType"),
            const SizedBox(height: 12),
            Text(
              "$time in Room $room",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      alignment:
          WrapAlignment.center, // 🔥 center quick action buttons horizontally
      children: [
        _squareButton("Update Availability"),
        _squareButton("Check Records"),
        _squareButton("Open Online Room"),
        _squareButton("Write Prescription"),
      ],
    );
  }

  Widget _squareButton(String label) {
    return SizedBox(
      width: 250,
      height: 200,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B50FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
