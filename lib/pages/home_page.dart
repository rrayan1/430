import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/service_card.dart';
import '../widgets/doctor_card.dart';
import '../widgets/custom_navbar.dart';
import 'package:labproject/pages/chatbot_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 1000,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Find the Right Doctor",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatbotPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text("Open AI Chatbot"),
                  ),
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
                  const Text("Services",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                        },
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        children: const [
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Odontology",
                                  icon: Icons.medical_services)),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Neurology", icon: Icons.psychology)),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Cardiology", icon: Icons.favorite)),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Dermatology", icon: Icons.healing)),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Pediatrics",
                                  icon: Icons.child_friendly)),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Psychiatry",
                                  icon: Icons.psychology_alt)),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Orthopedics",
                                  icon: Icons.accessibility_new)),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 140,
                              child: ServiceCard(
                                  title: "Radiology", icon: Icons.scanner)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text("Top Doctors",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                        },
                      ),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const ClampingScrollPhysics(),
                        children: const [
                          SizedBox(
                            width: 250,
                            child: DoctorCard(
                              name: "Dr. Tala Ray",
                              title: "Senior Surgeon",
                              time: "10:30 AM - 3:30",
                              fee: "\$12",
                              rating: 5.0,
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 250,
                            child: DoctorCard(
                              name: "Dr. Ali Uzair",
                              title: "Senior Surgeon",
                              time: "10:00 AM - 4:00",
                              fee: "\$15",
                              rating: 4.8,
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 250,
                            child: DoctorCard(
                              name: "Dr. Lina Moe",
                              title: "Cardiologist",
                              time: "9:00 AM - 2:00",
                              fee: "\$20",
                              rating: 4.9,
                            ),
                          ),
                          SizedBox(width: 16),
                          SizedBox(
                            width: 250,
                            child: DoctorCard(
                              name: "Dr. Sam Tan",
                              title: "Neurologist",
                              time: "11:00 AM - 5:00",
                              fee: "\$18",
                              rating: 4.7,
                            ),
                          ),
                        ],
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
}
