import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final habitServiceAsync = ref.watch(habitServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
      ),
      body: habitServiceAsync.when(
        data: (service) {
          final habits = service.getAllHabits();
          final year = _selectedMonth.year;
          final month = _selectedMonth.month;
          final firstDay = DateTime(year, month, 1);
          final lastDay = DateTime(year, month + 1, 0);
          final daysInMonth = lastDay.day;
          // Convert weekday to Sunday = 0 format
          final firstWeekday = (firstDay.weekday + 1) % 7;

          return Column(
            children: [
              // Month Selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(year, month - 1, 1);
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _selectedMonth = DateTime(year, month + 1, 1);
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Calendar Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Weekday Headers
                      Row(
                        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                            .map((day) => Expanded(
                                  child: Center(
                                    child: Text(
                                      day,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),

                      // Calendar Days
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: firstWeekday + daysInMonth,
                          itemBuilder: (context, index) {
                            if (index < firstWeekday) {
                              return const SizedBox.shrink();
                            }

                            final day = index - firstWeekday + 1;
                            final date = DateTime(year, month, day);
                            final today = DateTime.now();
                            final isToday = date.year == today.year &&
                                date.month == today.month &&
                                date.day == today.day;

                            // Count completed habits for this day
                            int completedCount = 0;
                            for (var habit in habits) {
                              // Check if habit is scheduled for this specific date
                              // Convert DateTime.weekday (1-7) to our format (0-6)
                              final dateWeekday = date.weekday;
                              final dateIndex = dateWeekday == 7 ? 0 : dateWeekday;
                              if (habit.weeklySchedule.contains(dateIndex) &&
                                  service.isCompleted(habit.id, date)) {
                                completedCount++;
                              }
                            }

                            // Count total habits scheduled for this date
                            final dateWeekday = date.weekday;
                            final dateIndex = dateWeekday == 7 ? 0 : dateWeekday;
                            final totalHabits = habits
                                .where((h) => h.weeklySchedule.contains(dateIndex))
                                .length;

                            return GestureDetector(
                              onTap: () {
                                // Show day details
                                _showDayDetails(context, service, date, habits);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: isToday
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$day',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: isToday
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isToday
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : null,
                                      ),
                                    ),
                                    if (totalHabits > 0) ...[
                                      const SizedBox(height: 4),
                                      _buildCompletionIndicator(
                                        completedCount,
                                        totalHabits,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCompletionIndicator(int completed, int total) {
    if (completed == 0) {
      return Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      );
    } else if (completed == total) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      );
    } else {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
      );
    }
  }

  void _showDayDetails(
    BuildContext context,
    HabitService service,
    DateTime date,
    List<Habit> habits,
  ) {
    // Get habits scheduled for this specific date
    final dateWeekday = date.weekday;
    final dateIndex = dateWeekday == 7 ? 0 : dateWeekday;
    final dayHabits = habits.where((h) => h.weeklySchedule.contains(dateIndex)).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(date),
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (dayHabits.isEmpty)
              const Text('No habits scheduled for this day')
            else
              ...dayHabits.map((habit) {
                final isCompleted = service.isCompleted(habit.id, date);
                return ListTile(
                  leading: Text(habit.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(habit.name),
                  trailing: Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

