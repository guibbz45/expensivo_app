# TODO: Fix Firebase connection

## Step 1 - Inspect current setup
- [x] Verified `lib/main.dart` does not call `Firebase.initializeApp`.
- [x] Verified `pubspec.yaml` has no Firebase dependencies.
- [x] Confirmed `lib/firebase_options.dart` exists with project config.

## Step 2 - Update dependencies
- [ ] Add `firebase_core` to `pubspec.yaml`.

## Step 3 - Initialize Firebase
- [ ] Update `lib/main.dart` to call `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.

## Step 4 - Fetch packages & run
- [ ] Run `flutter pub get`.
- [ ] Run `flutter clean` then `flutter run`.

