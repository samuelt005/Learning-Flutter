// models/activity.dart
class Activity {
  final String time;
  final String description;

  Activity({required this.time, required this.description});

  Map<String, dynamic> toJson() => {'time': time, 'description': description};

  factory Activity.fromJson(Map<String, dynamic> json) =>
      Activity(time: json['time'], description: json['description']);
}
