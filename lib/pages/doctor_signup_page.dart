import 'package:flutter/material.dart';

class DoctorSignupPage extends StatelessWidget {
  const DoctorSignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 800,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Create your account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                const Text("Additional Information",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _doctorRow("Name", "Name"),
                          _doctorRow("Email", "Email"),
                          _doctorRow("Age", "Age"),
                          _doctorRow("Gender", "Gender"),
                          _doctorRow("Specialization", "Specialization"),
                          _doctorRow("Experience", "Range",
                              suffix: const Icon(Icons.arrow_drop_down)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          _doctorRow("Phone", "Phone Number"),
                          _doctorRow("Availability", "Add", isButton: true),
                          _doctorRow("Consultation Fees", "Add",
                              isButton: true),
                          _doctorRow("Upload your image", "Add",
                              isButton: true),
                          _doctorRow("Upload your credentials", "Add",
                              isButton: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/additional_info');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B50FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Sign-up as a doctor",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _doctorRow(String label, String hint,
      {bool isButton = false, Widget? suffix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label)),
          Expanded(
            child: isButton
                ? ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: Text(hint),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFCBFF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                : TextField(
                    decoration: InputDecoration(
                      hintText: hint,
                      suffixIcon: suffix,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
