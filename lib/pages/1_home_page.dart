import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/service_card.dart';
import '../widgets/doctor_card.dart';
import '../widgets/custom_navbar.dart';
import 'package:labproject/pages/5_chatbot_page.dart';
import 'package:labproject/pages/6_schedule_page.dart';

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
                  const Text(
                    "Find the Right Doctor",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatbotPage()),
                      );
                    },
                    icon: const Icon(Icons.local_hospital, color: Colors.white),
                    label: const Text(
                      "AI Doctor Recommendation",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                      shadowColor: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SchedulePage()),
                        );
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    label: const Text(
                      "Schedule an Appointment",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                      shadowColor: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Services",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
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
                        children: [
                          _serviceItem(context, "Neurology", Icons.psychology,
                              "Neurology is the branch of medicine dealing with the diagnosis and treatment of all categories of conditions and diseases involving the nervous system."),
                          const SizedBox(width: 8),
                          _serviceItem(context, "Cardiology", Icons.favorite,
                              "Cardiology is the branch of medicine dealing with disorders of the heart and blood vessels."),
                          const SizedBox(width: 8),
                          _serviceItem(context, "Dermatology", Icons.healing,
                              "Dermatology is the branch of medicine dealing with the skin, nails, hair, and diseases."),
                          const SizedBox(width: 8),
                          _serviceItem(
                              context,
                              "Pediatrics",
                              Icons.child_friendly,
                              "Pediatrics is the branch of medicine dealing with the medical care of infants, children, and adolescents."),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Our Doctors",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where('role', isEqualTo: 'doctor')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final doctors = snapshot.data!.docs.map((doc) {
                          return doc.data() as Map<String, dynamic>;
                        }).toList();

                        // Sort by experience
                        doctors.sort((a, b) {
                          int expA = _experienceToInt(a['experience']);
                          int expB = _experienceToInt(b['experience']);
                          return expB.compareTo(expA);
                        });

                        if (doctors.isEmpty) {
                          return const Center(child: Text("No doctors found."));
                        }

                        return ScrollConfiguration(
                          behavior: const MaterialScrollBehavior().copyWith(
                            dragDevices: {
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.touch,
                            },
                          ),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: doctors.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final doctor = doctors[index];
                              return SizedBox(
                                width: 250,
                                child: DoctorCard(
                                  name: "Dr. ${doctor['name'] ?? 'Unknown'}",
                                  title:
                                      doctor['specialization'] ?? 'Specialist',
                                  time:
                                      "${doctor['availability_start'] ?? 'N/A'} - ${doctor['availability_end'] ?? 'N/A'}",
                                  fee:
                                      "\$${doctor['consultation_fees'] ?? '0'}",
                                  rating: 5.0,
                                ),
                              );
                            },
                          ),
                        );
                      },
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

  // Helper for service items popup
  Widget _serviceItem(
      BuildContext context, String title, IconData icon, String description) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(description),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
      child: SizedBox(
        width: 140,
        child: ServiceCard(
          title: title,
          icon: icon,
        ),
      ),
    );
  }

  // Helper to map experience strings into sorting numbers
  static int _experienceToInt(String? exp) {
    switch (exp) {
      case "15+ years":
        return 4;
      case "10-15 years":
        return 3;
      case "5-10 years":
        return 2;
      case "0-5 years":
        return 1;
      default:
        return 0;
    }
  }
}
