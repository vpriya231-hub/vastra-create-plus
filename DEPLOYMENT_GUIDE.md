# V Astra Create - Deployment Guide

Complete guide for deploying V Astra Create to production.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Backend Deployment](#backend-deployment)
3. [Flutter App Deployment](#flutter-app-deployment)
4. [Firebase Setup](#firebase-setup)
5. [Google Play Console](#google-play-console)
6. [AdMob Setup](#admob-setup)
7. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Prerequisites

### Required Accounts

- [ ] Google Cloud Platform (GCP) account
- [ ] Google Play Console account
- [ ] Firebase project
- [ ] AdMob account
- [ ] GitHub account with repository
- [ ] Slack workspace (optional, for notifications)

### Required Tools

```bash
# Install Flutter
curl -fsSL https://raw.githubusercontent.com/flutter/flutter/master/bin/flutter_install.sh | bash

# Install Node.js
curl -fsSL https://fnm.io/install | bash

# Install Firebase CLI
npm install -g firebase-tools

# Install Google Cloud CLI
curl https://sdk.cloud.google.com | bash

# Install Android SDK
# Download Android Studio from https://developer.android.com/studio
```

---

## Backend Deployment

### Option 1: Google Cloud Run (Recommended)

#### Step 1: Create GCP Project

```bash
gcloud projects create v-astra-create --name="V Astra Create"
gcloud config set project v-astra-create
```

#### Step 2: Enable Required APIs

```bash
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  artifactregistry.googleapis.com \
  firestore.googleapis.com
```

#### Step 3: Create Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy app code
COPY . .

# Build TypeScript
RUN npm run build

# Expose port
EXPOSE 3000

# Start app
CMD ["npm", "start"]
```

#### Step 4: Deploy to Cloud Run

```bash
cd backend

# Build and deploy
gcloud run deploy v-astra-backend \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars DATABASE_URL=$DATABASE_URL,JWT_SECRET=$JWT_SECRET,GEMINI_API_KEY=$GEMINI_API_KEY

# Get service URL
gcloud run services describe v-astra-backend --region us-central1
```

#### Step 5: Set Environment Variables

```bash
gcloud run services update v-astra-backend \
  --region us-central1 \
  --set-env-vars \
    DATABASE_URL="mysql://user:pass@host/db",\
    JWT_SECRET="your-secret-key",\
    GEMINI_API_KEY="your-gemini-key",\
    HUGGINGFACE_API_KEY="your-hf-key",\
    FIREBASE_PROJECT_ID="your-project-id"
```

### Option 2: Heroku

```bash
# Install Heroku CLI
npm install -g heroku

# Login
heroku login

# Create app
heroku create v-astra-backend

# Set environment variables
heroku config:set DATABASE_URL=mysql://...
heroku config:set JWT_SECRET=your-secret
heroku config:set GEMINI_API_KEY=your-key

# Deploy
git push heroku main
```

### Option 3: AWS EC2

```bash
# Launch EC2 instance
aws ec2 run-instances \
  --image-id ami-0c55b159cbfafe1f0 \
  --instance-type t3.medium \
  --key-name v-astra-key

# SSH into instance
ssh -i v-astra-key.pem ec2-user@your-instance-ip

# Install Node.js
curl -fsSL https://fnm.io/install | bash
fnm install 18

# Clone repo and deploy
git clone https://github.com/your-repo/v-astra-mobile.git
cd v-astra-mobile/backend
npm ci
npm run build
npm start
```

---

## Flutter App Deployment

### Step 1: Generate Signing Key

```bash
cd flutter/android

# Generate keystore
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias upload-key

# Note the passwords - you'll need them for CI/CD
```

### Step 2: Configure Signing

Update `flutter/android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
            storeFile file(System.getenv("KEYSTORE_PATH"))
            storePassword System.getenv("KEYSTORE_PASSWORD")
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 3: Build Release APK

```bash
cd flutter

# Build APK
flutter build apk --release

# Build AAB (for Play Store)
flutter build appbundle --release

# Output locations:
# APK: build/app/outputs/flutter-apk/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

### Step 4: Test Release Build

```bash
# Install on device
flutter install --release

# Or manually
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Firebase Setup

### Step 1: Create Firebase Project

```bash
firebase projects:create v-astra-create

# Or use existing project
firebase use v-astra-create
```

### Step 2: Enable Services

```bash
# Enable Firestore
firebase firestore:databases:create --region=us-central1

# Enable Authentication
firebase auth:enable

# Enable Storage
firebase storage:buckets:create
```

### Step 3: Configure Flutter App

Update `flutter/lib/firebase_options.dart`:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...',
  appId: '1:123456789:android:abc123...',
  messagingSenderId: '123456789',
  projectId: 'v-astra-create',
  databaseURL: 'https://v-astra-create.firebaseio.com',
  storageBucket: 'v-astra-create.appspot.com',
);
```

### Step 4: Setup Firestore Security Rules

```bash
# Deploy rules
firebase deploy --only firestore:rules
```

Update `firestore.rules`:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }

    // Published apps (public read)
    match /published/{shareId} {
      allow read: if true;
      allow write: if false;
    }

    // App analytics
    match /analytics/{appId} {
      allow read: if request.auth.uid == resource.data.uid;
      allow write: if false;
    }
  }
}
```

---

## Google Play Console

### Step 1: Create App

1. Go to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in app details:
   - Name: "V Astra Create"
   - Default language: English
   - App category: Productivity
   - Type: App

### Step 2: Set Up Billing

1. Go to Monetization setup
2. Add payment methods
3. Configure subscription products:
   - `v_astra_plus_monthly` - $4.99/month
   - `v_astra_pro_monthly` - $9.99/month
   - `v_astra_ultra_monthly` - $19.99/month

### Step 3: Upload AAB

1. Go to Release > Production
2. Click "Create new release"
3. Upload AAB file
4. Add release notes
5. Review and publish

### Step 4: Configure OAuth

1. Go to Settings > App signing
2. Note your app signing certificate
3. Go to [Google Cloud Console](https://console.cloud.google.com)
4. Create OAuth 2.0 credentials for Android

---

## AdMob Setup

### Step 1: Create AdMob Account

1. Go to [Google AdMob](https://admob.google.com)
2. Sign in with Google account
3. Accept terms

### Step 2: Create Ad Units

1. Go to Apps > Add app
2. Select "Android"
3. Fill in app details
4. Create ad units:
   - Banner: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy`
   - Interstitial: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy`
   - Rewarded: `ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy`

### Step 3: Update Flutter App

Update `flutter/lib/constants/ad_constants.dart`:

```dart
class AdConstants {
  static const String bannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy';
  static const String interstitialAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy';
  static const String rewardedAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/yyyyyyyyyyyyyy';
}
```

### Step 4: Test Ads

1. Use test device ID
2. Enable test ads in AdMob console
3. Test ad loading and display

---

## GitHub Actions CI/CD

### Step 1: Add Secrets

Go to GitHub repository > Settings > Secrets > Actions

Add secrets:

```
ANDROID_KEYSTORE_BASE64 = <base64-encoded-keystore>
KEYSTORE_PASSWORD = <your-password>
KEY_ALIAS = <your-alias>
KEY_PASSWORD = <your-key-password>
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON = <service-account-json>
GCP_PROJECT_ID = v-astra-create
GCP_SERVICE_ACCOUNT_KEY = <gcp-service-account-key>
SLACK_WEBHOOK = <slack-webhook-url>
```

### Step 2: Encode Keystore

```bash
# Encode keystore to base64
base64 -i flutter/android/upload-keystore.jks -o keystore.txt

# Copy content to ANDROID_KEYSTORE_BASE64 secret
```

### Step 3: Workflow Triggers

The workflow runs on:
- Push to `main` branch
- Push to `develop` branch
- Pull requests to `main`

---

## Monitoring & Maintenance

### Step 1: Set Up Monitoring

#### Google Cloud Monitoring

```bash
gcloud monitoring dashboards create \
  --config-from-file=monitoring-dashboard.yaml
```

#### Application Performance Monitoring

```bash
# Install APM agent
npm install elastic-apm-node
```

### Step 2: Logging

#### Cloud Logging

```bash
# View logs
gcloud logging read "resource.type=cloud_run_revision" \
  --limit 50 \
  --format json
```

#### Application Logs

```bash
# View Flutter app logs
flutter logs

# View backend logs
npm install winston
```

### Step 3: Alerts

#### Set Up Alerts

```bash
gcloud alpha monitoring policies create \
  --notification-channels=<channel-id> \
  --display-name="Backend Error Rate" \
  --condition-display-name="Error rate > 5%" \
  --condition-threshold-value=0.05
```

### Step 4: Backup & Recovery

#### Database Backup

```bash
# Backup Firestore
firebase firestore:export gs://v-astra-backups/backup-$(date +%s)

# Backup MySQL
mysqldump -u user -p database > backup.sql
```

#### Disaster Recovery Plan

1. **RTO (Recovery Time Objective)**: 1 hour
2. **RPO (Recovery Point Objective)**: 15 minutes
3. **Backup frequency**: Daily
4. **Backup retention**: 30 days

---

## Production Checklist

- [ ] Backend deployed to Cloud Run
- [ ] Database configured and backed up
- [ ] Firebase project set up
- [ ] Google Play Console app created
- [ ] Billing products configured
- [ ] AdMob ad units created
- [ ] GitHub Actions secrets configured
- [ ] SSL certificate configured
- [ ] Monitoring and alerts set up
- [ ] Logging configured
- [ ] Backup strategy implemented
- [ ] Security audit completed
- [ ] Load testing passed
- [ ] UAT testing completed
- [ ] Privacy policy published
- [ ] Terms of service published

---

## Post-Deployment

### Step 1: Monitor Metrics

Track:
- App crashes
- API error rates
- Response times
- User acquisition
- Subscription conversions
- Ad impressions

### Step 2: Gather Feedback

- Monitor app reviews
- Track user feedback
- Monitor support tickets
- Analyze usage patterns

### Step 3: Iterate

- Fix bugs based on feedback
- Optimize performance
- Add new features
- Improve user experience

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Build fails | Check environment variables and secrets |
| App crashes on startup | Check Firebase configuration |
| Ads don't show | Verify AdMob ad unit IDs |
| Billing not working | Check Google Play service account |
| Backend timeout | Increase Cloud Run timeout or optimize queries |

### Support

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [AdMob Help](https://support.google.com/admob)
