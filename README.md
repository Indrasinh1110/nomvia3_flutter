# NOMVIA

A new Flutter project.

## Authentication Setup (IMPORTANT)

For Google Sign-In and Phone Authentication to work on Android, you **MUST** generate the SHA-1 fingerprint of your debug keystore and add it to the Firebase Console.

### How to Generate SHA-1

1. Open a terminal in the `android` folder:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   (Windows: `gradlew.bat signingReport`)

2. Look for the `Task :app:signingReport` output.
3. Find the `debug` variant section.
4. Copy the `SHA1` fingerprint (defaults to something like `5E:8F:16:06:2E:A3:CD:2C:4A:0D:54:78:76:BA:A6:F3:8C:AB:CD:50`).

### Configure Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Open **Project Settings**.
3. Scroll down to **Your apps** and select the **Android app** (`com.example.nomvia`).
4. Click **Add fingerprint**.
5. Paste the SHA-1 you copied and save.
6. Download the updated `google-services.json` (optional, usually unchanged for just SHA-1, but good practice).

### Verify Google Cloud Console (If Google Auth fails)

1. Go to [Google Cloud Console](https://console.cloud.google.com/).
2. Select your project.
3. Go to **APIs & Services > Credentials**.
4. Ensure an **Android** OAuth 2.0 Client ID exists matching your package name and SHA-1.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
