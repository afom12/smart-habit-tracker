import '../models/streak_data.dart';

class StreakCalculator {
  static StreakData calculateStreak({
    required String habitId,
    required bool Function(DateTime) isCompleted,
  }) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    int totalCompleted = 0;
    int totalMissed = 0;
    
    // Calculate current streak (backwards from today)
    var checkDate = todayDate;
    while (true) {
      if (isCompleted(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    // Calculate longest streak and totals (check last 365 days)
    final startDate = todayDate.subtract(const Duration(days: 365));
    var date = startDate;
    
    while (date.isBefore(todayDate) || date.isAtSameMomentAs(todayDate)) {
      if (isCompleted(date)) {
        tempStreak++;
        totalCompleted++;
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }
      } else {
        tempStreak = 0;
        totalMissed++;
      }
      date = date.add(const Duration(days: 1));
    }
    
    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalCompleted: totalCompleted,
      totalMissed: totalMissed,
    );
  }
}

