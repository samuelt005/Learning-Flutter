import 'package:flutter/material.dart';
import 'models/activity.dart';
import 'services/storage_service.dart';

void main() => runApp(PlannerApp());

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planejador Diário',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: PlannerHome(),
    );
  }
}

class PlannerHome extends StatefulWidget {
  const PlannerHome({super.key});

  @override
  _PlannerHomeState createState() => _PlannerHomeState();
}

class _PlannerHomeState extends State<PlannerHome> {
  final StorageService _storageService = StorageService();
  List<Activity> _activities = [];

  DateTime? _selectedDateTime;
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final loaded = await _storageService.loadActivities();
    setState(() {
      _activities = loaded;
    });
  }

  Future<void> _addActivity() async {
    if (_selectedDateTime == null || _descController.text.isEmpty) return;

    final newActivity = Activity(
      time: _selectedDateTime!.toIso8601String(),
      description: _descController.text,
    );

    setState(() {
      _activities.add(newActivity);
      _selectedDateTime = null;
    });

    await _storageService.saveActivities(_activities);

    _descController.clear();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Planejador Diário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text(
                _selectedDateTime == null
                    ? 'Selecionar Data e Hora'
                    : '${_selectedDateTime!.day.toString().padLeft(2, '0')}/'
                        '${_selectedDateTime!.month.toString().padLeft(2, '0')} '
                        '${_selectedDateTime!.hour.toString().padLeft(2, '0')}:'
                        '${_selectedDateTime!.minute.toString().padLeft(2, '0')}',
              ),
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Atividade'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addActivity,
              child: Text('Adicionar Atividade'),
            ),
            Divider(height: 30),
            Expanded(
              child:
                  _activities.isEmpty
                      ? Text('Nenhuma atividade cadastrada.')
                      : ListView.builder(
                        itemCount: _activities.length,
                        itemBuilder: (context, index) {
                          final activity = _activities[index];
                          return ListTile(
                            title: Text(
                              '${DateTime.parse(activity.time).day.toString().padLeft(2, '0')}/'
                              '${DateTime.parse(activity.time).month.toString().padLeft(2, '0')} '
                              '${DateTime.parse(activity.time).hour.toString().padLeft(2, '0')}:'
                              '${DateTime.parse(activity.time).minute.toString().padLeft(2, '0')}'
                              ' - ${activity.description}',
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
