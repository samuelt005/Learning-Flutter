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

  final _timeController = TextEditingController();
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
    if (_timeController.text.isEmpty || _descController.text.isEmpty) return;

    final newActivity = Activity(
      time: _timeController.text,
      description: _descController.text,
    );

    setState(() {
      _activities.add(newActivity);
    });

    await _storageService.saveActivities(_activities);

    _timeController.clear();
    _descController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Planejador Diário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'Horário (ex: 08:00)'),
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
                              '${activity.time} - ${activity.description}',
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
