import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/habit.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    if (habit.reminderTime == null) return;

    final timeParts = habit.reminderTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Schedule for each day in weekly schedule
    for (var dayOfWeek in habit.weeklySchedule) {
      final scheduledDate = _getNextScheduledDate(dayOfWeek, hour, minute);
      
      await _notifications.zonedSchedule(
        habit.id.hashCode + dayOfWeek, // Unique ID
        'Time for ${habit.name}',
        'Don\'t forget to ${habit.name.toLowerCase()}! 💛',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Reminders for your daily habits',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  DateTime _getNextScheduledDate(int dayOfWeek, int hour, int minute) {
    final now = DateTime.now();
    final today = now.weekday % 7; // Convert to 0-6 format
    
    int daysUntilNext = (dayOfWeek - today) % 7;
    if (daysUntilNext == 0) {
      // If today is the scheduled day, check if time has passed
      final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledTime.isBefore(now)) {
        daysUntilNext = 7; // Schedule for next week
      }
    }
    
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    ).add(Duration(days: daysUntilNext));
    
    return scheduledDate;
  }

  Future<void> cancelHabitReminder(Habit habit) async {
    for (var dayOfWeek in habit.weeklySchedule) {
      await _notifications.cancel(habit.id.hashCode + dayOfWeek);
    }
  }

  Future<void> updateHabitReminder(Habit habit) async {
    await cancelHabitReminder(habit);
    await scheduleHabitReminder(habit);
  }
}

