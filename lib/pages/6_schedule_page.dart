// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _currentMonth = DateTime.now();
  String? _selectedDoctor;
  final Map<String, List<Map<String, String>>> _appointments = {};
  final _firestore = FirebaseFirestore.instance;
  final List<String> _doctors = [
    'Dr. Lina (Cardiology)',
    'Dr. Ali (Neurology)',
    'Dr. Moe (Pediatrics)',
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointmentsFromDB();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  List<DateTime> _generateDaysForMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7;
    final days = <DateTime>[];
    for (int i = 0; i < firstWeekday; i++) {
      days.add(DateTime(0));
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    return days;
  }

  Future<void> _loadAppointmentsFromDB() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;

    final snapshot = await _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      _appointments.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = data['date'];
        final slot = data['slot'];
        final doctor = data['doctor'];
        _appointments.putIfAbsent(date, () => []).add({
          'slot': slot,
          'doctor': doctor,
        });
      }
    });
  }

  Future<List<String>> _getBookedSlots(String doctor, String date) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctor', isEqualTo: doctor)
        .where('date', isEqualTo: date)
        .get();

    return snapshot.docs.map((doc) => doc['slot'] as String).toList();
  }

  Future<void> _saveAppointment(String date, String slot) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedDoctor == null) return;

    await _firestore.collection('appointments').add({
      'userId': user.uid,
      'doctor': _selectedDoctor,
      'date': date,
      'slot': slot,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _loadAppointmentsFromDB();
  }

  Future<void> _deleteAppointment(String date, String slot, String doctor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docs = await _firestore
        .collection('appointments')
        .where('userId', isEqualTo: user.uid)
        .where('date', isEqualTo: date)
        .where('slot', isEqualTo: slot)
        .where('doctor', isEqualTo: doctor)
        .get();

    for (var doc in docs.docs) {
      await doc.reference.delete();
    }

    await _loadAppointmentsFromDB();
  }

  void _showTimeSlots(DateTime date, {String? oldSlot}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (_selectedDoctor == null || user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor first.')),
      );
      return;
    }

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final timeSlots = List.generate(8, (i) {
      final start = TimeOfDay(hour: 9 + i, minute: 0);
      final end = TimeOfDay(hour: 9 + i, minute: 30);
      return '${start.format(context)} - ${end.format(context)}';
    });

    final bookedSlots = (await _getBookedSlots(_selectedDoctor!, dateKey))
        .where((slot) => slot != oldSlot)
        .toList();

    if (!mounted) return;
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
            Text(
              "Available Slots on ${DateFormat.yMMMEd().format(date)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...timeSlots.map((slot) => ListTile(
                  title: Text(slot),
                  enabled: !bookedSlots.contains(slot),
                  onTap: () async {
                    Navigator.pop(context);
                    if (oldSlot != null) {
                      await _deleteAppointment(dateKey, oldSlot, _selectedDoctor!);
                    }
                    await _saveAppointment(dateKey, slot);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '✅ Appointment confirmed for $slot with $_selectedDoctor'),
                      ),
                    );
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
      backgroundColor: Colors.grey[100],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: _appointments.entries.expand((entry) {
          return entry.value.map((appt) => Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  tileColor: Colors.white,
                  title: Text(
                    '${entry.key} - ${appt['slot']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${appt['doctor']}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          Navigator.pop(context);
                          _selectedDoctor = appt['doctor'];
                          _showTimeSlots(
                            DateFormat('yyyy-MM-dd').parse(entry.key),
                            oldSlot: appt['slot'],
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Cancel Appointment'),
                              content: Text(
                                'Cancel appointment with ${appt['doctor']} on ${entry.key} at ${appt['slot']}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Yes'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _deleteAppointment(entry.key, appt['slot']!, appt['doctor']!);
                            Navigator.pop(context);
                            _showConfirmedAppointments();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ));
        }).toList(),
      ),
    );
  }

  Widget _buildWeekDays() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekdays
          .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildCalendar(List<DateTime> days, DateTime today) {
    return Center(
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _previousMonth, icon: Icon(Icons.chevron_left)),
                Text(DateFormat.yMMMM().format(_currentMonth),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(onPressed: _nextMonth, icon: Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 12),
            _buildWeekDays(),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final date = days[index];
                final isValid = date.year > 0;
                final isToday = date.day == today.day &&
                    date.month == today.month &&
                    date.year == today.year;
                final isPast = date.isBefore(DateTime(today.year, today.month, today.day));
                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                final hasAppointment = _appointments.containsKey(dateKey);

                return GestureDetector(
                  onTap: (isValid && !isPast) ? () => _showTimeSlots(date) : null,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isToday ? Colors.blueAccent.withOpacity(0.8) : null,
                      borderRadius: BorderRadius.circular(24),
                      border: (isValid && !isPast)
                          ? Border.all(color: Colors.blueAccent.withOpacity(0.2))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isValid ? '${date.day}' : '',
                          style: TextStyle(
                            color: isPast
                                ? Colors.grey
                                : (isToday ? Colors.white : Colors.black87),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasAppointment && isValid)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isPast ? Colors.transparent : Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDaysForMonth(_currentMonth);
    final today = DateTime.now();

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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedDoctor,
              isExpanded: true,
              hint: const Text('Select Doctor/Specialty'),
              items: _doctors
                  .map((doc) => DropdownMenuItem(value: doc, child: Text(doc)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedDoctor = value),
            ),
            const SizedBox(height: 32),
            _buildCalendar(days, today),
          ],
        ),
      ),
    );
  }
}
