# 🌟 Afomi - Smart Habit Tracker

A beautiful and smart habit tracker app built with Flutter to help you build consistency and stay motivated.

## ✨ Features

### Core Features
- ✅ **Add Habits** - Create habits with custom icons, colors, and schedules
- 📅 **Daily Check-in** - Simple and clean interface to mark habits as done
- 🔥 **Streak Counter** - Track current streak, longest streak, and completion rate
- 📆 **Calendar View** - Visual monthly calendar showing completion status
- 📊 **Weekly Progress Chart** - Beautiful charts showing your weekly progress
- 🌓 **Light/Dark Theme** - Comfortable viewing in any lighting condition

### Optional Features
- 🔔 **Local Notifications** - Friendly reminders for your habits
- 💬 **Motivational Quotes** - Daily inspiration when you open the app
- 🎨 **Custom Icons & Colors** - Personalize your habits
- 💾 **Local Storage** - All data stored securely offline using Hive

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── habit.dart
│   ├── habit_completion.dart
│   └── streak_data.dart
├── screens/                  # App screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── add_edit_habit_screen.dart
│   ├── calendar_screen.dart
│   ├── analytics_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable widgets
│   ├── habit_card.dart
│   └── motivational_quote.dart
├── services/                 # Business logic
│   ├── habit_service.dart
│   └── notification_service.dart
├── providers/                # State management
│   └── theme_provider.dart
├── theme/                    # Theme configuration
│   └── app_theme.dart
└── utils/                    # Utilities
    └── streak_calculator.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd "mobile app"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters** (required for data persistence)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots
<p align="center">
  <img src="https://github.com/user-attachments/assets/39110e7d-0478-4e0b-8a31-ae061034bef8" width="200" />
  <img src="https://github.com/user-attachments/assets/c98e5406-e989-4922-93a0-436387429ca3" width="200" />
  <img src="https://github.com/user-attachments/assets/0c1feaba-b2a1-4f66-bb1f-66ed5cfc4dab" width="200" />
  <img src="https://github.com/user-attachments/assets/6d86521b-3438-46f5-bac5-c06655e86f72" width="200" />
</p>
 
The app features:
- Clean, modern UI with smooth animations
- Beautiful gradient splash screen
- Intuitive habit management
- Visual progress tracking
- Calendar view for monthly overview
- Analytics with charts and statistics

## 🛠️ Technologies Used

- **Flutter** - Cross-platform framework
- **Riverpod** - State management
- **Hive** - Local database
- **fl_chart** - Beautiful charts
- **Google Fonts** - Typography

- **flutter_local_notifications** - Push notifications

## 📝 Notes

- All data is stored locally using Hive
- The app works completely offline
- Notifications require proper permissions on Android/iOS
- Theme preference is saved automatically

## 🎯 Future Enhancements

- Cloud sync with Firebase
- Export/Import habits
- Habit templates
- Social sharing of streaks
- Widget support

## 📄 License

This project is created for educational purposes.

---

**Built with ❤️ using Flutter**

