import 'package:flutter/material.dart';

class DoctorHomePage extends StatelessWidget {
  const DoctorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Home'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Check your patients for today!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPatientCards(),
            const SizedBox(height: 32),
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 32),
            const Text(
              "Analytics",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAnalyticsPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _patientCard(
            name: "Flan El Foulani",
            age: 26,
            gender: "Male",
            bloodType: "A+",
            time: "10:00 AM",
            room: "435",
            imageUrl:
                "https://randomuser.me/api/portraits/men/32.jpg", // Example image
          ),
          const SizedBox(width: 16),
          _patientCard(
            name: "Jane Doe",
            age: 29,
            gender: "Female",
            bloodType: "O+",
            time: "10:30 AM",
            room: "440",
            imageUrl:
                "https://randomuser.me/api/portraits/women/44.jpg", // Example image
          ),
          // Add more patients here if you want
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
                      style: TextStyle(fontWeight: FontWeight.bold)),
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
      spacing: 12,
      runSpacing: 12,
      children: [
        _quickActionButton("Update Availability"),
        _quickActionButton("Check Records"),
        _quickActionButton("Open Online Room"),
        _quickActionButton("Write Prescription"),
      ],
    );
  }

  Widget _quickActionButton(String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3B50FF),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildAnalyticsPlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          "Analytics Graph Here",
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
