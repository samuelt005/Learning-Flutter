import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../models/activity.dart';
import '../services/storage_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final StorageService _storageService = StorageService();
  Map<String, List<Activity>> _activitiesByDate = {};
  DateTime _focusedDay = DateTime.now();

  DateTime _selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  String _getDateKey(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return DateFormat('yyyy-MM-dd').format(utcDate);
  }

  Future<void> _loadActivities() async {
    final activities = await _storageService.loadActivities();
    final Map<String, List<Activity>> grouped = {};

    for (var activity in activities) {
      try {
        final activityTime = DateTime.parse(activity.time);
        final dayKey = _getDateKey(activityTime);
        grouped.putIfAbsent(dayKey, () => []).add(activity);
      } catch (e) {
        print(
          "Error parsing date for activity: ${activity.description}, time: ${activity.time}. Error: $e",
        );
      }
    }

    grouped.forEach((key, value) {
      value.sort(
        (a, b) => DateTime.parse(a.time).compareTo(DateTime.parse(b.time)),
      );
    });

    if (mounted) {
      setState(() {
        _activitiesByDate = grouped;
      });
    }
  }

  Future<void> _showActivityDialog({Activity? activityToEdit}) async {
    final bool isEditing = activityToEdit != null;
    final descController = TextEditingController(
      text: activityToEdit?.description ?? '',
    );
    TimeOfDay? selectedTime =
    activityToEdit != null
        ? TimeOfDay.fromDateTime(DateTime.parse(activityToEdit.time))
        : null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickTime() async {
              final initialTime = selectedTime ?? TimeOfDay.now();
              final picked = await showTimePicker(
                context: context,
                initialTime: initialTime,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(alwaysUse24HourFormat: true),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setDialogState(() {
                  selectedTime = picked;
                });
              }
            }

            Future<void> saveActivity() async {
              if (selectedTime == null || descController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Por favor, selecione a hora e preencha a descrição.',
                    ),
                  ),
                );
                return;
              }

              final activityDateTime = DateTime(
                _selectedDay.year,
                _selectedDay.month,
                _selectedDay.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              final newDescription = descController.text;
              final newTime = activityDateTime.toIso8601String();

              try {
                final allActivities = await _storageService.loadActivities();
                if (isEditing) {
                  final index = allActivities.indexWhere(
                        (a) =>
                    a.time == activityToEdit.time &&
                        a.description == activityToEdit.description,
                  );
                  if (index != -1) {
                    allActivities[index] = Activity(
                      time: newTime,
                      description: newDescription,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Erro: Atividade original não encontrada para editar.',
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                    return;
                  }
                } else {
                  final newActivity = Activity(
                    time: newTime,
                    description: newDescription,
                  );
                  allActivities.add(newActivity);
                }

                await _storageService.saveActivities(allActivities);

                Navigator.of(context).pop();
                await _loadActivities();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Atividade atualizada com sucesso!'
                          : 'Atividade adicionada com sucesso!',
                    ),
                  ),
                );
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar atividade: $e')),
                );
              }
            }

            final localizations = MaterialLocalizations.of(context);
            final formattedDate = localizations.formatShortDate(_selectedDay);
            final dialogTitle =
            isEditing
                ? 'Editar Atividade'
                : 'Adicionar Atividade para $formattedDate';
            final saveButtonText = isEditing ? 'Salvar' : 'Adicionar';

            return AlertDialog(
              title: Text(dialogTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.access_time),
                      onPressed: pickTime,
                      label: Text(
                        selectedTime == null
                            ? 'Selecionar Hora'
                            : localizations.formatTimeOfDay(
                          selectedTime!,
                          alwaysUse24HourFormat: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Atividade',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: saveActivity,
                  child: Text(saveButtonText),
                ),
              ],
            );
          },
        );
      },
    );

    descController.dispose();
  }

  Future<void> _deleteActivity(Activity activityToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir a atividade "${activityToDelete.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final allActivities = await _storageService.loadActivities();
        allActivities.removeWhere(
              (a) =>
          a.time == activityToDelete.time &&
              a.description == activityToDelete.description,
        );
        await _storageService.saveActivities(allActivities);
        await _loadActivities();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Atividade excluída.')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir atividade: $e')),
          );
        }
      }
    }
  }

  List<Activity> _getActivitiesForDay(DateTime day) {
    final key = _getDateKey(day);
    return _activitiesByDate[key] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final dayOnly = DateTime.utc(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    if (!isSameDay(_selectedDay, dayOnly)) {
      setState(() {
        _selectedDay = dayOnly;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final activitiesForSelectedDay = _getActivitiesForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text('Planejamento Diário')),
      body: Column(
        children: [
          TableCalendar<Activity>(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getActivitiesForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orangeAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.indigo,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.blueGrey,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Text(
              "Atividades para ${localizations.formatFullDate(_selectedDay)}:",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child:
                activitiesForSelectedDay.isEmpty
                    ? const Center(
                      child: Text('Nenhuma atividade para este dia.'),
                    )
                    : ListView.builder(
                      itemCount: activitiesForSelectedDay.length,
                      itemBuilder: (context, index) {
                        final activity = activitiesForSelectedDay[index];
                        final dt = DateTime.parse(activity.time);
                        final time = localizations.formatTimeOfDay(
                          TimeOfDay.fromDateTime(dt),
                          alwaysUse24HourFormat: true,
                        );
                        return ListTile(
                          title: Text(activity.description),
                          subtitle: Text("Hora: $time"),
                          dense: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 20,
                                ),
                                tooltip: 'Editar',
                                onPressed: () {
                                  _showActivityDialog(activityToEdit: activity);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                tooltip: 'Excluir',
                                onPressed: () {
                                  _deleteActivity(activity);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showActivityDialog(),
        tooltip: 'Adicionar Atividade',
        child: const Icon(Icons.add),
      ),
    );
  }
}
