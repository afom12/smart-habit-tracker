import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class HabitCompletion extends HiveObject {
  @HiveField(0)
  String habitId;

  @HiveField(1)
  DateTime date; // Date only (time set to 00:00:00)

  @HiveField(2)
  bool completed;

  HabitCompletion({
    required this.habitId,
    required this.date,
    required this.completed,
  });

  // Create a date key for easy lookup (YYYY-MM-DD format)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String dateKeyFromDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

