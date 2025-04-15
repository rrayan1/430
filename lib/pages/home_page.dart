import 'package:flutter/material.dart';
import '../widgets/service_card.dart';
import '../widgets/doctor_card.dart';
import '../widgets/cust_navBar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 1000,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Hello, Flan!",
                    style:
                        TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.smart_toy, size: 32),
                    SizedBox(width: 8),
                    Text("Need help from a robot? Press the robot icon now"),
                  ],
                ),
                const SizedBox(height: 32),
                const Text("Find the Right Doctor",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                    "Enter your symptoms, language, and doctor preference to get AI-powered recommendations"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16)),
                  child: const Text("AI Doctor Recommendation"),
                ),
                const SizedBox(height: 32),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Services",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("See All →")
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ServiceCard(
                        title: "Odontology", icon: Icons.medical_services),
                    ServiceCard(title: "Neurology", icon: Icons.psychology),
                    ServiceCard(title: "Cardiology", icon: Icons.favorite),
                  ],
                ),
                const SizedBox(height: 32),
                const Text("Top Doctors",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const DoctorCard(
                    name: "Dr. Tala Ray",
                    title: "Senior Surgeon",
                    time: "10:30 AM - 3:30",
                    fee: "\$12",
                    rating: 5.0),
                const SizedBox(height: 16),
                const DoctorCard(
                    name: "Dr. Ali Uzair",
                    title: "Senior Surgeon",
                    time: "10:00 AM - 4:00",
                    fee: "\$15",
                    rating: 4.8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
