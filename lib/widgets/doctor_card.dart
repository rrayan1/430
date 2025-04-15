import 'package:flutter/material.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String title;
  final String time;
  final String fee;
  final double rating;

  const DoctorCard({
    super.key,
    required this.name,
    required this.title,
    required this.time,
    required this.fee,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.person),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title), Text(time), Text("Fee: $fee")],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.yellow[700]),
            Text(rating.toString()),
          ],
        ),
      ),
    );
  }
}
