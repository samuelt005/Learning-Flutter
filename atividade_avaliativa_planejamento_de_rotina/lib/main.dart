import 'package:flutter/material.dart';
import 'screens/calendar_screen.dart';

void main() => runApp(const PlannerApp());

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planejador Diário',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const CalendarScreen(),
    );
  }
}
