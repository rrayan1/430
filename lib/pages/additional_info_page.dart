import 'package:flutter/material.dart';

class AdditionalInfoPage extends StatelessWidget {
  const AdditionalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 600,
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
                const Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                _infoRow("Age", "Age"),
                _infoRow("Gender", "Gender"),
                _infoRow("Blood Type", "Blood Type"),
                _infoRow("Home Address", "Add", isButton: true),
                _infoRow("Emergency Contact", "Add", isButton: true),
                _infoRow("Allergies", "Add", isButton: true),
                _infoRow("Upload your image", "Add", isButton: true),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Connect firebase
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B50FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Finish",
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

  Widget _infoRow(String label, String hint, {bool isButton = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 180, child: Text(label)),
          Expanded(
            child: isButton
                ? ElevatedButton.icon(
                    onPressed: () {
                      // add button funct
                    },
                    icon: const Icon(Icons.add),
                    label: Text(hint),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFCBFF),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                : TextField(
                    decoration: InputDecoration(
                      hintText: hint,
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
