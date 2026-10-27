# Cartoon Clean Car (Flutter)
1. `flutter create .` in this folder (generates android/ios), keep `lib/`, `assets/`, `pubspec.yaml`
2. `flutter pub get && flutter run`
3. Android `AndroidManifest.xml`: add `<uses-permission android:name="android.permission.CAMERA"/>` and inside `<queries>`:
   `<intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>` and `<intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>`
4. iOS `Info.plist`: `NSCameraUsageDescription`, and `LSApplicationQueriesSchemes` = `tel`, `https`

Demo: any email + 4-char password works. Choose "Captain" to enter the captain side (signs in as Ahmed Hassan).
Structure: core/ (theme, glass widgets, utils) · models/ · state/ (AppState – swap for Firebase) · screens/
