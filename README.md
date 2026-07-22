# ALUhub (ALUhub)
https://drive.google.com/file/d/1g_JBb0gqwwrcJrdshG146ZGov1yuVAkR/view?usp=drive_link

ALU internship marketplace connecting students with student-led startups and early-stage ventures on campus.

Built with **Flutter**, **Firebase** (Auth, Firestore, Cloud Messaging), and **BLoC** state management. The UI uses the **ALU navy blue and red** brand palette.

## Features

- **Students** — Discover verified startup internships, apply, bookmark roles, track applications, and request facilitator references
- **Startup founders** — Register a startup profile, post internship roles (after verification), and review applicants
- **Facilitators** — Respond to student recommendation requests
- **Admins** — Approve or reject ALU startup profiles

## Prerequisites

| Tool | Version |
|------|---------|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | 3.6+ (Dart 3.6+) |
| Android Studio or Xcode | For emulators / device builds |
| Firebase project | Required before running on a device |

Optional: [Firebase CLI](https://firebase.google.com/docs/cli) for deploying Firestore rules.

## Quick start

### 1. Clone and install dependencies

```bash
git clone <repository-url>
cd alu-internship-hub
flutter pub get
```

### 2. Configure Firebase

The app will not connect to a backend until Firebase is set up. Follow the full guide in [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md). Summary:

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Register **Android** (`com.alu.campus_launchpad`) and **iOS** (`com.alu.campuslaunchpad`) apps
3. Place config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Enable **Email/Password** authentication and **Cloud Firestore**
5. Generate Flutter config:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This overwrites `lib/firebase/firebase_options.dart` with your project keys.

6. Deploy Firestore rules (optional but recommended):

```bash
firebase login
firebase deploy --only firestore:rules
```

### 3. Run the app

**Android emulator or device:**

```bash
flutter run
```

**iOS simulator or device (macOS only):**

```bash
cd ios && pod install && cd ..
flutter run
```

**Choose a specific device:**

```bash
flutter devices
flutter run -d <device-id>
```

### 4. Create an admin account (optional)

After registering your first user in the app:

1. Open Firestore → `users` collection
2. Find your user document
3. Set `role` to `admin`

Admins can verify startup profiles from the **Verify** tab.

## Development commands

```bash
# Static analysis
flutter analyze

# Run tests
flutter test

# Build release APK
flutter build apk

# Build iOS (requires macOS + Xcode)
flutter build ios
```

## Project structure

```
lib/
├── main.dart              # Firebase init + app entry
├── app.dart               # MultiBloc setup + auth gate
├── core/                  # Theme, constants, widgets, utils
├── data/                  # Models + Firebase repositories
├── features/              # Auth, opportunities, applications, etc.
└── firebase/              # FlutterFire options
```

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for schema, BLoC patterns, and Firestore collections.

## Theming

The app uses a dark **ALU navy** background with **red** accents:

| Token | Hex | Usage |
|-------|-----|-------|
| Navy | `#001B36` | Scaffold / app bar background |
| Deep navy | `#001225` | Bottom navigation, button contrast |
| ALU red | `#C41230` | Primary buttons, links, selected nav items |
| Card navy | `#0B2745` | Cards, input fields |

Theme definition: `lib/core/theme/app_theme.dart`

## ALU email policy

Only school emails are allowed:

- Students & founders: `@alustudent.com`
- Facilitators: `@alueducation.com`

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `YOUR_ANDROID_API_KEY` errors | Run `flutterfire configure` — see Firebase setup |
| Firestore permission denied | Deploy `firestore.rules` from the repo root |
| Google Sign-In fails on Android | Add SHA-1 fingerprint in Firebase Console → Project settings |
| No opportunities shown | A verified startup must post roles; check Firestore `opportunities` collection |
| Gradle / CocoaPods errors | Run `flutter clean && flutter pub get`, then rebuild |

## License

Academic / ALU project — see course requirements for usage terms.
