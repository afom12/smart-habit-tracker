class StreakData {
  final int currentStreak;
  final int longestStreak;
  final int totalCompleted;
  final int totalMissed;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompleted,
    required this.totalMissed,
  });

  double get completionRate {
    final total = totalCompleted + totalMissed;
    if (total == 0) return 0.0;
    return totalCompleted / total;
  }
}

