import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';
import '../models/habit_completion.dart';
import '../models/streak_data.dart';
import '../utils/streak_calculator.dart';

class HabitService {
  static const String _habitsBoxName = 'habits';
  static const String _completionsBoxName = 'completions';

  Box<Habit>? _habitsBox;
  Box<HabitCompletion>? _completionsBox;

  Future<void> init() async {
    _habitsBox = await Hive.openBox<Habit>(_habitsBoxName);
    _completionsBox = await Hive.openBox<HabitCompletion>(_completionsBoxName);
  }

  // Habits CRUD
  List<Habit> getAllHabits() {
    return _habitsBox?.values.toList() ?? [];
  }

  Habit? getHabit(String id) {
    return _habitsBox?.get(id);
  }

  Future<void> saveHabit(Habit habit) async {
    await _habitsBox?.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    // Delete habit
    await _habitsBox?.delete(id);
    
    // Delete all completions for this habit
    final keysToDelete = <String>[];
    for (var key in _completionsBox?.keys ?? []) {
      final completion = _completionsBox?.get(key);
      if (completion?.habitId == id) {
        keysToDelete.add(key.toString());
      }
    }
    for (var key in keysToDelete) {
      await _completionsBox?.delete(key);
    }
  }

  // Get habits scheduled for today
  List<Habit> getTodayHabits() {
    final allHabits = getAllHabits();
    return allHabits.where((habit) => habit.isScheduledForToday()).toList();
  }

  // Completions
  Future<void> markComplete(String habitId, DateTime date, bool completed) async {
    final dateKey = HabitCompletion.dateKeyFromDateTime(date);
    final key = '$habitId-$dateKey';
    
    final completion = HabitCompletion(
      habitId: habitId,
      date: DateTime(date.year, date.month, date.day),
      completed: completed,
    );
    
    await _completionsBox?.put(key, completion);
  }

  bool isCompleted(String habitId, DateTime date) {
    final dateKey = HabitCompletion.dateKeyFromDateTime(date);
    final key = '$habitId-$dateKey';
    final completion = _completionsBox?.get(key);
    return completion?.completed ?? false;
  }

  // Get completion status for a date range
  Map<DateTime, bool> getCompletionsForRange(String habitId, DateTime start, DateTime end) {
    final result = <DateTime, bool>{};
    var current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      result[current] = isCompleted(habitId, current);
      current = current.add(const Duration(days: 1));
    }
    
    return result;
  }

  // Get streak data
  StreakData getStreakData(String habitId) {
    return StreakCalculator.calculateStreak(
      habitId: habitId,
      isCompleted: (date) => isCompleted(habitId, date),
    );
  }

  // Get completion count for a week
  List<int> getWeeklyCompletionCount(DateTime weekStart) {
    final habits = getAllHabits();
    final result = List<int>.filled(7, 0);
    
    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateWeekday = date.weekday;
      final dateIndex = dateWeekday == 7 ? 0 : dateWeekday;
      for (var habit in habits) {
        if (habit.weeklySchedule.contains(dateIndex) && isCompleted(habit.id, date)) {
          result[i]++;
        }
      }
    }
    
    return result;
  }
}

final habitServiceProvider = FutureProvider<HabitService>((ref) async {
  final service = HabitService();
  await service.init();
  return service;
});

