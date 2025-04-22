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
  String? _selectedDoctorUID;
  final Map<String, List<Map<String, String>>> _appointments = {};
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> _doctorList = [];
  List<Map<String, dynamic>> _myAppointments = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorsFromDB();
    _loadAppointmentsFromDB();
  }

  Map<String, int> manualSplit(String input) {
    input = input.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
    final match = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$', caseSensitive: false)
        .firstMatch(input);
    if (match == null) {
      throw FormatException('Invalid time format: $input');
    }
    int hour = int.parse(match.group(1)!);
    int minute = int.parse(match.group(2)!);
    String ampm = match.group(3)!.toUpperCase();
    if (ampm == 'PM' && hour != 12) hour += 12;
    if (ampm == 'AM' && hour == 12) hour = 0;
    return {'hour': hour, 'minute': minute};
  }

  Future<void> _loadDoctorsFromDB() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .get();

    setState(() {
      _doctorList = snapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] ?? 'Unknown';
        final specialization = data['specialization'] ?? 'Specialist';
        return {
          'display': 'Dr. $name ($specialization)',
          'uid': doc.id,
        };
      }).toList();
    });
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
      _myAppointments.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = data['date'];
        final slot = data['slot'];
        final doctor = data['doctor'];

        _appointments.putIfAbsent(date, () => []).add({
          'slot': slot,
          'doctor': doctor,
        });

        _myAppointments.add({
          'id': doc.id,
          'date': date,
          'slot': slot,
          'doctor': doctor,
        });
      }
    });
  }

  Future<List<String>> _getBookedSlots(String doctorUID, String date) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('doctor', isEqualTo: doctorUID)
        .where('date', isEqualTo: date)
        .get();
    return snapshot.docs.map((doc) => doc['slot'] as String).toList();
  }

  Future<void> _saveAppointment(String date, String slot) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _selectedDoctorUID == null) return;

    await _firestore.collection('appointments').add({
      'userId': user.uid,
      'doctor': _selectedDoctorUID,
      'date': date,
      'slot': slot,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _loadAppointmentsFromDB();
  }

  Future<void> _deleteAppointment(String id) async {
    await _firestore.collection('appointments').doc(id).delete();
    await _loadAppointmentsFromDB();
  }

  void _showTimeSlots(DateTime date,
      {String? oldAppointmentId,
      String? oldSlot,
      String? doctorUIDOverride}) async {
    final user = FirebaseAuth.instance.currentUser;
    if ((_selectedDoctorUID == null && doctorUIDOverride == null) ||
        user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor first.')),
      );
      return;
    }

    final doctorUID = doctorUIDOverride ?? _selectedDoctorUID!;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    final docRef = _firestore.collection('users').doc(doctorUID);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor not found.')),
      );
      return;
    }

    final docData = docSnapshot.data()!;
    final startStr = docData['availability_start'] ?? '08:00 AM';
    final endStr = docData['availability_end'] ?? '04:00 PM';

    try {
      final startParts = manualSplit(startStr);
      final endParts = manualSplit(endStr);

      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day,
          startParts['hour']!, startParts['minute']!);
      final end = DateTime(today.year, today.month, today.day,
          endParts['hour']!, endParts['minute']!);

      final isToday = today.year == date.year &&
          today.month == date.month &&
          today.day == date.day;

      List<Map<String, dynamic>> timeSlots = [];
      DateTime curr = start;
      while (curr.isBefore(end)) {
        final next = curr.add(const Duration(minutes: 30));
        bool isPastSlot = isToday && curr.isBefore(today);
        timeSlots.add({
          'slot':
              '${DateFormat.jm().format(curr)} - ${DateFormat.jm().format(next)}',
          'isPast': isPastSlot,
        });
        curr = next;
      }

      final bookedSlots = (await _getBookedSlots(doctorUID, dateKey))
          .where((slot) => slot != oldSlot)
          .toList();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Available Slots on ${DateFormat.yMMMEd().format(date)}",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: timeSlots.map((slotData) {
                final slot = slotData['slot'];
                final isPast = slotData['isPast'];
                final isBooked = bookedSlots.contains(slot);
                return ListTile(
                  title: Text(
                    isBooked ? '$slot (Booked)' : slot,
                    style: TextStyle(
                      color: isPast || isBooked ? Colors.grey : Colors.black,
                    ),
                  ),
                  enabled: !isPast && !isBooked,
                  onTap: !isPast && !isBooked
                      ? () async {
                          Navigator.pop(context);
                          if (oldAppointmentId != null) {
                            await _deleteAppointment(oldAppointmentId);
                          }
                          await _firestore.collection('appointments').add({
                            'userId': user.uid,
                            'doctor': doctorUID,
                            'date': dateKey,
                            'slot': slot,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          await _loadAppointmentsFromDB();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('✅ Appointment confirmed for $slot')),
                          );
                        }
                      : null,
                );
              }).toList(),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error reading availability: $e')),
      );
    }
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

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
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
                    style: const TextStyle(
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
          boxShadow: const [
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
                IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left)),
                Text(DateFormat.yMMMM().format(_currentMonth),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 12),
            _buildWeekDays(),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                final isPast =
                    date.isBefore(DateTime(today.year, today.month, today.day));
                final dateKey = DateFormat('yyyy-MM-dd').format(date);
                final hasAppointment = _appointments.containsKey(dateKey);

                return GestureDetector(
                  onTap:
                      (isValid && !isPast) ? () => _showTimeSlots(date) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:
                          isToday ? Colors.blueAccent.withOpacity(0.8) : null,
                      borderRadius: BorderRadius.circular(24),
                      border: (isValid && !isPast)
                          ? Border.all(
                              color: Colors.blueAccent.withOpacity(0.2))
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
                              color: isPast
                                  ? Colors.transparent
                                  : Colors.blueAccent,
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Schedule Appointment'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Schedule'),
              Tab(text: 'My Appointments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Schedule Appointment Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DropdownButton<String>(
                    value: _selectedDoctorUID,
                    isExpanded: true,
                    hint: const Text('Select Doctor/Specialty'),
                    items: _doctorList
                        .map((doc) => DropdownMenuItem(
                              value: doc['uid'],
                              child: Text(doc['display']!),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedDoctorUID = value),
                  ),
                  const SizedBox(height: 32),
                  _buildCalendar(days, today),
                ],
              ),
            ),
            // Manage Appointments Tab
            ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _myAppointments.length,
              itemBuilder: (context, index) {
                final appt = _myAppointments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('${appt['slot']}'),
                    subtitle: Text('Date: ${appt['date']}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'reschedule') {
                          final selectedDate = DateTime.parse(appt['date']);
                          _showTimeSlots(
                            selectedDate,
                            oldAppointmentId: appt['id'],
                            oldSlot: appt['slot'],
                            doctorUIDOverride: appt['doctor'],
                          );
                        } else if (value == 'cancel') {
                          _deleteAppointment(appt['id']);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                            value: 'reschedule', child: Text('Reschedule')),
                        const PopupMenuItem(
                            value: 'cancel', child: Text('Cancel')),
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
}
