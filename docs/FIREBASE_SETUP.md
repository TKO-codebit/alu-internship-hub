# Firebase Setup — Campus Launchpad

Follow these steps to connect the app to your Firebase project. Do this **before** running the app on a device or emulator.

## 1. Create the Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** → name it `campus-launchpad-alu` (or similar).
3. Disable Google Analytics if you do not need it for the assignment.
4. Click **Create project**.

## 2. Register mobile apps

### Android
1. In Project Overview, click **Android**.
2. Package name: `com.alu.campuslaunchpad`
3. Download `google-services.json`.
4. Place it at: `android/app/google-services.json`

### iOS
1. Click **Add app → iOS**.
2. Bundle ID: `com.alu.campuslaunchpad`
3. Download `GoogleService-Info.plist`.
4. Place it at: `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode and add the plist to the Runner target if needed.

## 3. Enable Firebase services

In the Firebase Console:

| Service | Where to enable |
|---------|-----------------|
| **Authentication** | Build → Authentication → Sign-in method → Email/Password |
| **Cloud Firestore** | Build → Firestore Database → Create database (test mode for dev) |
| **Cloud Messaging** (optional) | Build → Cloud Messaging |

## 4. Generate FlutterFire config

From the project root (after `flutter pub get`):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Select your Firebase project and the Android + iOS apps. This overwrites `lib/firebase/firebase_options.dart` with real keys.

## 5. Deploy Firestore security rules

```bash
firebase login
firebase init firestore   # select existing project, use firestore.rules
firebase deploy --only firestore:rules
```

Or paste `firestore.rules` from this repo into the Firebase Console → Firestore → Rules tab.

## 6. Seed an admin account (for startup verification)

After registering your first user in the app:

1. Open Firestore → `users` collection.
2. Find your user document.
3. Set `role` to `admin`.

Only admins can approve ALU startup profiles from the **Verify** tab.

## 7. Demo checklist for grading

During your 7–10 minute video, show:

- [ ] User registration appearing in **Authentication** tab
- [ ] Profile document created in **Firestore → users**
- [ ] Startup creates opportunity → document in **opportunities**
- [ ] Student applies → document in **applications**
- [ ] Real-time list update when status changes (keep Firebase Console open beside emulator)
- [ ] BLoC state change when bookmarking or filtering opportunities

## Firestore collections

```
users/{userId}
startups/{startupId}
opportunities/{opportunityId}
applications/{applicationId}
bookmarks/{userId}/items/{opportunityId}
notifications/{userId}/items/{notificationId}
```

See `docs/ARCHITECTURE.md` for schema details.
