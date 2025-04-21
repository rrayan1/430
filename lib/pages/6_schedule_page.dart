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
  final Map<String, List<String>> _appointments = {};

  final List<String> _doctors = [
    'Dr. Lina (Cardiology)',
    'Dr. Ali (Neurology)',
    'Dr. Moe (Pediatrics)',
  ];

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

  void _showTimeSlots(DateTime date) {
    if (_selectedDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a doctor first.')),
      );
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
            Text(
              "Available Slots on ${DateFormat.yMMMEd().format(date)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...timeSlots.map((slot) => ListTile(
                  title: Text(slot),
                  enabled: !bookedSlots.contains(slot),
                  onTap: () {
                    setState(() {
                      _appointments.putIfAbsent(dateKey, () => []).add(slot);
                    });
                    Navigator.pop(context);
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
                        _showTimeSlots(
                            DateFormat('yyyy-MM-dd').parse(entry.key));
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Doctor/Specialty Dropdown (separate)
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

            // Calendar Card
            Center(
              child: Container(
                width: 480, // 🛠️ Smaller now
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
                    // Month Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          DateFormat.yMMMM().format(_currentMonth),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Weekday Headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
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
                    ),
                    const SizedBox(height: 8),

                    // Calendar Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: days.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                        final isPast = date.isBefore(
                          DateTime(today.year, today.month, today.day),
                        );
                        final dateKey = DateFormat('yyyy-MM-dd').format(date);
                        final hasAppointment =
                            _appointments.containsKey(dateKey);

                        return MouseRegion(
                          cursor: (isValid && !isPast)
                              ? SystemMouseCursors.click
                              : SystemMouseCursors.basic,
                          child: GestureDetector(
                            onTap: (isValid && !isPast)
                                ? () => _showTimeSlots(date)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? Colors.blueAccent.withOpacity(0.8)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                                border: (isValid && !isPast)
                                    ? Border.all(
                                        color:
                                            Colors.blueAccent.withOpacity(0.2),
                                      )
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
                                          : (isToday
                                              ? Colors.white
                                              : Colors.black87),
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
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
