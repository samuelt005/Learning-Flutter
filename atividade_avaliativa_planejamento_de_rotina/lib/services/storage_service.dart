// services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';

class StorageService {
  static const _key = 'activities';

  Future<void> saveActivities(List<Activity> activities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(activities.map((a) => a.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<List<Activity>> loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);
    return decoded.map((e) => Activity.fromJson(e)).toList();
  }
}
