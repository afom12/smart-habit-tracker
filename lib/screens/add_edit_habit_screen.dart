import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/notification_service.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit;

  const AddEditHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = '📚';
  String? _reminderTime;
  List<int> _weeklySchedule = [0, 1, 2, 3, 4, 5, 6]; // All days by default
  String _selectedColor = '#6366F1';

  final List<String> _icons = [
    '📚',
    '💧',
    '📖',
    '💪',
    '🧘',
    '🏃',
    '🎯',
    '⏰',
    '🌱',
    '✨',
    '🎨',
    '🎵',
    '🍎',
    '😴',
    '📝',
  ];

  final List<String> _colors = [
    '#6366F1', // Indigo
    '#8B5CF6', // Purple
    '#10B981', // Green
    '#F59E0B', // Amber
    '#EF4444', // Red
    '#EC4899', // Pink
    '#06B6D4', // Cyan
    '#84CC16', // Lime
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _selectedIcon = widget.habit!.icon;
      _reminderTime = widget.habit!.reminderTime;
      _weeklySchedule = List.from(widget.habit!.weeklySchedule);
      _selectedColor = widget.habit!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay(
              hour: int.parse(_reminderTime!.split(':')[0]),
              minute: int.parse(_reminderTime!.split(':')[1]),
            )
          : TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _reminderTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _toggleDay(int day) {
    setState(() {
      if (_weeklySchedule.contains(day)) {
        _weeklySchedule.remove(day);
      } else {
        _weeklySchedule.add(day);
        _weeklySchedule.sort();
      }
    });
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate() || _weeklySchedule.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final habitService = await ref.read(habitServiceProvider.future);
    final notificationService = NotificationService();

    final habit = Habit(
      id: widget.habit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      icon: _selectedIcon,
      reminderTime: _reminderTime,
      weeklySchedule: _weeklySchedule,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
      color: _selectedColor,
    );

    await habitService.saveHabit(habit);

    // Update notifications
    if (widget.habit != null) {
      await notificationService.updateHabitReminder(habit);
    } else {
      await notificationService.scheduleHabitReminder(habit);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.habit != null
              ? 'Habit updated successfully'
              : 'Habit added successfully'),
        ),
      );
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.habit != null) {
      final habitService = await ref.read(habitServiceProvider.future);
      final notificationService = NotificationService();
      
      await notificationService.cancelHabitReminder(widget.habit!);
      await habitService.deleteHabit(widget.habit!.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit != null ? 'Edit Habit' : 'Add Habit'),
        actions: [
          if (widget.habit != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteHabit,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Habit Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Read 10 pages',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Icon Selection
            Text(
              'Choose Icon',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _icons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Color Selection
            Text(
              'Choose Color',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = color == _selectedColor;
                final colorValue = Color(int.parse(color.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorValue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorValue.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Weekly Schedule
            Text(
              'Weekly Schedule',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayChip('S', 0),
                _buildDayChip('M', 1),
                _buildDayChip('T', 2),
                _buildDayChip('W', 3),
                _buildDayChip('T', 4),
                _buildDayChip('F', 5),
                _buildDayChip('S', 6),
              ],
            ),
            const SizedBox(height: 24),

            // Reminder Time
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTime ?? 'No reminder'),
              trailing: _reminderTime != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _reminderTime = null),
                    )
                  : null,
              onTap: _selectTime,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.habit != null ? 'Update Habit' : 'Add Habit',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(String label, int day) {
    final isSelected = _weeklySchedule.contains(day);
    return GestureDetector(
      onTap: () => _toggleDay(day),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3) ??
                    Colors.grey,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

