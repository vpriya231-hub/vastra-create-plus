# V Astra Create - Complete Setup Guide

This guide walks you through setting up the V Astra Create Flutter mobile app with all features including Firebase, Google Play Billing, and AdMob.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Backend Setup](#backend-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [Flutter Setup](#flutter-setup)
5. [AdMob Configuration](#admob-configuration)
6. [Google Play Billing Setup](#google-play-billing-setup)
7. [GitHub Actions CI/CD](#github-actions-cicd)
8. [Testing](#testing)
9. [Deployment](#deployment)

## Prerequisites

### Required Tools
- Flutter 3.16.0+ ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Node.js 18.0.0+ ([Install Node.js](https://nodejs.org/))
- Android Studio with Android SDK (for Android development)
- Xcode (for iOS development - macOS only)
- Git

### Required Accounts
- Firebase Project ([Create Firebase Project](https://console.firebase.google.com/))
- Google Play Console Account ([Google Play Console](https://play.google.com/console/))
- AdMob Account ([AdMob Console](https://admob.google.com/))
- Google Cloud Project (for APIs)

### API Keys & Credentials
- Gemini API Key ([Get Gemini API Key](https://aistudio.google.com/app/apikey))
- Hugging Face API Token ([Get HF Token](https://huggingface.co/settings/tokens))
- Firebase Service Account Key
- Google Play Service Account Key

---

## Backend Setup

### 1. Install Backend Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```env
# Server
NODE_ENV=production
PORT=5000
APP_BASE_URL=https://vastracreate.app

# Firebase
FIREBASE_TYPE=service_account
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@your-project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_CERT_URL=your-cert-url
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com

# AI APIs
GEMINI_API_KEY=your-gemini-api-key
HUGGING_FACE_API_KEY=your-hugging-face-token
HUGGING_FACE_MODEL=mistralai/Mistral-7B-Instruct-v0.1

# Google Play
PACKAGE_NAME=com.vastra.create
GOOGLE_PLAY_PLUS_ID=v_astra_plus_monthly
GOOGLE_PLAY_PRO_ID=v_astra_pro_monthly
GOOGLE_PLAY_ULTRA_ID=v_astra_ultra_monthly
```

### 3. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click Settings (gear icon) → Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate New Private Key"
6. Copy the JSON content and add to `.env`

### 4. Test Backend

```bash
npm start
# Should output: [V Astra Create Backend] Server running on http://localhost:5000
```

---

## Firebase Configuration

### 1. Create Firestore Database

1. Go to Firebase Console → Your Project
2. Click "Firestore Database" in left menu
3. Click "Create Database"
4. Choose "Start in production mode"
5. Select your region (closest to your users)

### 2. Set Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only authenticated users can access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Published apps - anyone can read, only owner can write
    match /published_apps/{shareId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 3. Enable Firebase Authentication

1. Go to Firebase Console → Authentication
2. Click "Get Started"
3. Click "Google" provider
4. Enable it
5. Add your app's SHA-1 fingerprint:
   ```bash
   cd flutter/android
   ./gradlew signingReport
   ```

---

## Flutter Setup

### 1. Create Flutter Project Structure

```bash
cd flutter
flutter pub get
```

### 2. Configure Firebase for Android

1. Download `google-services.json` from Firebase Console:
   - Project Settings → Your Apps → Android
   - Download the file
2. Place it in `flutter/android/app/google-services.json`

### 3. Configure Firebase for iOS

1. Download `GoogleService-Info.plist` from Firebase Console:
   - Project Settings → Your Apps → iOS
   - Download the file
2. Place it in `flutter/ios/Runner/GoogleService-Info.plist`
3. Add to Xcode:
   ```bash
   cd flutter/ios
   open Runner.xcworkspace
   # Drag GoogleService-Info.plist into Runner folder
   ```

### 4. Update Firebase Options

Edit `flutter/lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY',
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_FIREBASE_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);
```

Get these values from `google-services.json`.

### 5. Configure API Service

Edit `flutter/lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-backend-url.com';
```

### 6. Run Flutter App

```bash
flutter run
```

---

## AdMob Configuration

### 1. Create AdMob Account

1. Go to [AdMob Console](https://admob.google.com/)
2. Sign in with your Google account
3. Click "Get Started"

### 2. Register Your App

1. Click "Apps" → "Add App"
2. Select "Android" or "iOS"
3. Enter app name and store ID
4. Accept terms and create app

### 3. Create Ad Units

For each ad type, click "Ad units" → "Create new ad unit":

**Banner Ad:**
- Format: Banner
- Name: "Dashboard Banner"
- Copy the Ad Unit ID

**Interstitial Ad:**
- Format: Interstitial
- Name: "Dashboard Interstitial"
- Copy the Ad Unit ID

**Rewarded Ad:**
- Format: Rewarded
- Name: "Download Rewarded"
- Copy the Ad Unit ID

### 4. Update Ad Constants

Edit `flutter/lib/constants/ad_constants.dart`:

```dart
// For development (test IDs):
static const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';

// For production (your IDs):
// static const String androidBannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyy';
```

---

## Google Play Billing Setup

### 1. Create Google Play Developer Account

1. Go to [Google Play Console](https://play.google.com/console/)
2. Sign in with your Google account
3. Accept terms and create developer account
4. Pay $25 registration fee

### 2. Create Your App

1. Click "Create app"
2. Enter app name: "V Astra Create"
3. Select app type: "App"
4. Fill in required information

### 3. Create Subscription Products

1. Go to "Monetize" → "Products" → "Subscriptions"
2. Click "Create subscription"

**Plus Plan:**
- Product ID: `v_astra_plus_monthly`
- Name: "V Astra Plus"
- Description: "5 credits per month"
- Price: $4.99/month

**Pro Plan:**
- Product ID: `v_astra_pro_monthly`
- Name: "V Astra Pro"
- Description: "10 credits per month"
- Price: $9.99/month

**Ultra Plan:**
- Product ID: `v_astra_ultra_monthly`
- Name: "V Astra Ultra"
- Description: "15 credits per month"
- Price: $19.99/month

### 4. Create Service Account

1. Go to "Setup" → "API access"
2. Click "Create new service account"
3. Follow the link to Google Cloud Console
4. Create service account with "Editor" role
5. Create JSON key
6. Download and save for GitHub Actions

---

## GitHub Actions CI/CD

### 1. Create Android Keystore

```bash
keytool -genkey -v -keystore ~/v-astra-create.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias v-astra-create
```

### 2. Encode Keystore to Base64

```bash
base64 ~/v-astra-create.jks | tr -d '\n'
```

### 3. Add GitHub Secrets

1. Go to GitHub repository → Settings → Secrets and variables → Actions
2. Add the following secrets:

| Secret Name | Value |
|-------------|-------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore |
| `KEYSTORE_PASSWORD` | Your keystore password |
| `KEY_ALIAS` | `v-astra-create` |
| `KEY_PASSWORD` | Your key password |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | JSON service account key |

### 4. Trigger Build

Push to `main` or `develop` branch:

```bash
git push origin main
```

Builds will be available in "Actions" tab.

---

## Testing

### 1. Test Backend Endpoints

```bash
# Health check
curl http://localhost:5000/api/health

# Initialize user (requires Firebase token)
curl -X POST http://localhost:5000/api/user/init \
  -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
  -H "Content-Type: application/json"
```

### 2. Test Firebase Connection

```bash
# In Flutter app, check logs:
flutter logs
# Should show: "Firebase initialized successfully"
```

### 3. Test AdMob (Development)

- Use test Ad Unit IDs
- Check logs for ad loading

### 4. Test Google Play Billing

- Use test account from Google Play Console
- Test purchase flow in app

---

## Deployment

### 1. Deploy Backend

**Option A: Cloud Run**

```bash
gcloud run deploy v-astra-create-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

**Option B: Heroku**

```bash
heroku create v-astra-create-backend
git push heroku main
```

### 2. Build APK for Testing

```bash
cd flutter
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### 3. Build AAB for Production

```bash
cd flutter
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### 4. Upload to Google Play

1. Go to Google Play Console → Your App
2. Click "Release" → "Production"
3. Click "Create new release"
4. Upload AAB file
5. Add release notes
6. Review and publish

---

## Troubleshooting

### Firebase Issues
- **Error: "Project not found"** → Check `FIREBASE_PROJECT_ID` in `.env`
- **Error: "Permission denied"** → Check Firestore security rules
- **Error: "Service account invalid"** → Regenerate service account key

### AdMob Issues
- **Ads not showing** → Use test Ad Unit IDs for development
- **Error: "Ad unit not found"** → Check Ad Unit IDs in `ad_constants.dart`

### Google Play Issues
- **Error: "Invalid product ID"** → Ensure products are created in Play Console
- **Purchase fails** → Use test account from Play Console

### Build Issues
- **Gradle error** → Run `flutter clean && flutter pub get`
- **Pod error (iOS)** → Run `cd ios && pod install && cd ..`

---

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review logs: `flutter logs`
3. Check GitHub Issues
4. Contact support@vastracreate.app

---

**Last Updated:** June 2024
**Version:** 1.0.0
