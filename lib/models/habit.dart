import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  String? reminderTime; // Format: "HH:mm" or null

  @HiveField(4)
  List<int> weeklySchedule; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String color; // Hex color code

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    this.reminderTime,
    required this.weeklySchedule,
    required this.createdAt,
    required this.color,
  });

  // Check if habit should be done today
  bool isScheduledForToday() {
    // DateTime.weekday: 1=Monday, 7=Sunday
    // Our format: 0=Sunday, 1=Monday, ..., 6=Saturday
    final todayWeekday = DateTime.now().weekday;
    final todayIndex = todayWeekday == 7 ? 0 : todayWeekday; // Convert Sunday from 7 to 0
    return weeklySchedule.contains(todayIndex);
  }

  // Check if habit is scheduled daily
  bool isDaily() {
    return weeklySchedule.length == 7;
  }
}

