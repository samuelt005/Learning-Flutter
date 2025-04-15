import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../services/storage_service.dart';

class DailyPlannerScreen extends StatefulWidget {
  final DateTime date;

  const DailyPlannerScreen({super.key, required this.date});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  final StorageService _storageService = StorageService();
  final _descController = TextEditingController();
  TimeOfDay? _selectedTime;
  List<Activity> _dailyActivities = [];

  @override
  void initState() {
    super.initState();
    _loadDailyActivities();
  }

  Future<void> _loadDailyActivities() async {
    final all = await _storageService.loadActivities();
    final key = widget.date.toIso8601String().split('T').first;
    final filtered = all.where((a) => a.time.startsWith(key)).toList();
    filtered.sort(
      (a, b) => DateTime.parse(a.time).compareTo(DateTime.parse(b.time)),
    );

    setState(() {
      _dailyActivities = filtered;
    });
  }

  Future<void> _addActivity() async {
    if (_selectedTime == null || _descController.text.isEmpty) return;

    final date = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final newActivity = Activity(
      time: date.toIso8601String(),
      description: _descController.text,
    );

    final all = await _storageService.loadActivities();
    all.add(newActivity);
    await _storageService.saveActivities(all);

    setState(() {
      _descController.clear();
      _selectedTime = null;
    });

    _loadDailyActivities();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDate =
        '${widget.date.day}/${widget.date.month}/${widget.date.year}';

    return Scaffold(
      appBar: AppBar(title: Text('Atividades em $displayDate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickTime,
              child: Text(
                _selectedTime == null
                    ? 'Selecionar Hora'
                    : _selectedTime!.format(context),
              ),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Atividade'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addActivity,
              child: const Text('Adicionar Atividade'),
            ),
            const Divider(height: 30),
            Expanded(
              child:
                  _dailyActivities.isEmpty
                      ? const Text('Nenhuma atividade.')
                      : ListView(
                        children:
                            _dailyActivities.map((a) {
                              final dt = DateTime.parse(a.time);
                              final hour =
                                  '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                              return ListTile(
                                title: Text('$hour - ${a.description}'),
                              );
                            }).toList(),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
