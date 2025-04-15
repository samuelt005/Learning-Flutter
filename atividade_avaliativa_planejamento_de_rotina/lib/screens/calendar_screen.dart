import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';
import 'daily_planner_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();
  Map<String, List<Activity>> _activitiesByDate = {};
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await _storageService.loadActivities();
    final Map<String, List<Activity>> grouped = {};

    for (var activity in activities) {
      final dayKey = activity.time.split('T').first;
      grouped.putIfAbsent(dayKey, () => []).add(activity);
    }

    setState(() {
      _activitiesByDate = grouped;
    });
  }

  List<Activity> _getActivitiesForDay(DateTime day) {
    final key = day.toIso8601String().split('T').first;
    final list = _activitiesByDate[key] ?? [];
    list.sort(
      (a, b) => DateTime.parse(a.time).compareTo(DateTime.parse(b.time)),
    );
    return list;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DailyPlannerScreen(date: selectedDay)),
    ).then((_) => _loadActivities());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planejador Diário')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.indigoAccent,
                shape: BoxShape.circle,
              ),
            ),
            selectedDayPredicate: (day) => isSameDay(day, _focusedDay),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              _onDaySelected(selectedDay, focusedDay);
            },
            eventLoader: _getActivitiesForDay,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children:
                  _getActivitiesForDay(_focusedDay).map((a) {
                    final dt = DateTime.parse(a.time);
                    final time =
                        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                    return ListTile(title: Text('$time - ${a.description}'));
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
