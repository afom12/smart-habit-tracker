# 🚀 Setup Instructions for Afomi Habit Tracker

## Quick Start

1. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

That's it! The app should work now.

## Optional: Generate Hive Adapters (Alternative Method)

If you prefer to use code generation instead of manual adapters:

1. **Generate adapters**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Update models** - Remove the `part` directives and use the generated adapters

## Platform-Specific Setup

### Android

1. Open `android/app/build.gradle`
2. Ensure `minSdkVersion` is at least 21
3. For notifications, add permissions in `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
   <uses-permission android:name="android.permission.VIBRATE"/>
   ```

### iOS

1. For notifications, add to `ios/Runner/Info.plist`:
   ```xml
   <key>UILaunchStoryboardName</key>
   <string>LaunchScreen</string>
   ```

## Troubleshooting

### If you see "HiveAdapter not found" errors:
- The manual adapters are already included in the project
- Make sure `habit_adapter.dart` and `habit_completion_adapter.dart` exist in `lib/models/`

### If notifications don't work:
- Check platform-specific permissions
- Ensure timezone package is properly initialized
- Test on a physical device (notifications may not work on emulators)

### If charts don't display:
- Ensure `fl_chart` package is installed
- Check that data is being passed correctly to chart widgets

## Development Tips

- Use `flutter clean` if you encounter build issues
- Run `flutter pub upgrade` to update dependencies
- Check `flutter doctor` to ensure your environment is set up correctly

