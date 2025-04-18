import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentMonth = DateTime.now();
  String? _selectedDoctor;
  Map<String, List<String>> _appointments = {}; // dateKey -> [timeSlots]
  final List<String> _doctors = ['Dr. Lina (Cardiology)', 'Dr. Ali (Neurology)', 'Dr. Moe (Pediatrics)'];

  List<DateTime> _generateDaysForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;
    final totalDays = lastDay.day;
    final days = <DateTime>[];

    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(0));
    }

    for (int i = 1; i <= totalDays; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    return days;
  }

  void _showTimeSlots(DateTime date) {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a doctor first.')));
      return;
    }

    final timeSlots = List.generate(8, (index) {
      final start = TimeOfDay(hour: 9 + index, minute: 0);
      final end = TimeOfDay(hour: 9 + index, minute: 30);
      return '${start.format(context)} - ${end.format(context)}';
    });

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final bookedSlots = _appointments[dateKey] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Available Slots on ${DateFormat.yMMMEd().format(date)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...timeSlots.map((slot) => ListTile(
                  title: Text(slot),
                  enabled: !bookedSlots.contains(slot),
                  onTap: () {
                    setState(() {
                      _appointments.putIfAbsent(dateKey, () => []).add(slot);
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('✅ Appointment confirmed for $slot with $_selectedDoctor'),
                    ));
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showConfirmedAppointments() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: _appointments.entries.expand((entry) {
          return entry.value.map((slot) => ListTile(
                title: Text('${entry.key} - $slot'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pop(context);
                        _showTimeSlots(DateFormat('yyyy-MM-dd').parse(entry.key));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _appointments[entry.key]!.remove(slot);
                          if (_appointments[entry.key]!.isEmpty) {
                            _appointments.remove(entry.key);
                          }
                        });
                        Navigator.pop(context);
                        _showConfirmedAppointments();
                      },
                    ),
                  ],
                ),
              ));
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDaysForMonth(_currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View My Appointments',
            onPressed: _showConfirmedAppointments,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedDoctor,
              isExpanded: true,
              hint: const Text('Select Doctor/Specialty'),
              items: _doctors.map((doc) => DropdownMenuItem(value: doc, child: Text(doc))).toList(),
              onChanged: (value) => setState(() => _selectedDoctor = value),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                DateFormat.yMMMM().format(_currentMonth),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 350,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 1,
                  childAspectRatio: 7,
                ),
                itemBuilder: (context, index) {
                  final date = days[index];
                  final isValid = date.year > 0;
                  return GestureDetector(
                    onTap: isValid ? () => _showTimeSlots(date) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isValid ? Colors.blue[100] : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: isValid ? Border.all(color: Colors.blueAccent) : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isValid ? '${date.day}' : '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
