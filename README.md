# V Astra Create - Flutter Mobile App

A powerful AI-driven mobile app generator with subscription management, AdMob integration, and Google Play billing.

## Features

### 🤖 AI-Powered App Generation
- **Hybrid AI Routing**: Free tier users → Hugging Face API, Paid users → Gemini API
- **Prompt-Based Generation**: Users write prompts to generate complete web apps
- **App Editing**: Edit generated apps with new prompts (each costs 1 credit)
- **Web-Responsive Apps**: All generated apps are mobile-responsive

### 💳 Subscription Management
- **Tier System**: Free, Plus, Pro, Ultra with different credit limits
- **Credit System**: Each prompt/edit costs 1 credit
  - Free: 5 total prompts/edits per month
  - Plus: 25 total prompts/edits per month
  - Pro: 60 total prompts/edits per month
  - Ultra: 100 total prompts/edits per month
- **Google Play Billing**: Secure in-app purchases via Google Play Console
- **Purchase Restoration**: Restore purchases across devices

### 📱 AdMob Integration
- **Free Tier Ads**: Banner and Interstitial ads for free users
- **Rewarded Ads**: Rewarded video ads during downloads/publishing (Free tier only)
- **Ad-Free Experience**: Paid tier users see no ads
- **Test IDs Configured**: Easy swap to production IDs

### 🔐 Security & Authentication
- **Firebase Authentication**: Google Sign-In integration
- **Secure Backend**: All AI keys stored on backend (never exposed to client)
- **UID-Based Persistence**: User data linked to Firebase UID
- **Token Verification**: Backend verifies all purchases with Google Play

### 📤 App Publishing
- **Shareable Links**: Generate shareable web links for published apps
- **View Tracking**: Track number of views for each published app
- **Mobile-Responsive**: Published apps work on all devices

### ⚙️ Developer Tools
- **GitHub Actions CI/CD**: Automated APK/AAB builds
- **Environment Configuration**: Easy setup via .env files
- **Modular Architecture**: Clean separation of concerns

## Project Structure

```
v-astra-mobile/
├── backend/                          # Node.js/Express backend
│   ├── server.js                     # Main server with all endpoints
│   ├── package.json                  # Backend dependencies
│   └── .env.example                  # Environment variables template
├── flutter/                          # Flutter mobile app
│   ├── lib/
│   │   ├── constants/
│   │   │   └── ad_constants.dart     # AdMob configuration
│   │   ├── services/
│   │   │   ├── api_service.dart      # Backend API client
│   │   │   ├── firebase_service.dart # Firebase authentication
│   │   │   ├── admob_service.dart    # AdMob management
│   │   │   └── billing_service.dart  # Google Play billing
│   │   ├── pages/                    # UI pages (to be created)
│   │   └── main.dart                 # App entry point (to be created)
│   ├── pubspec.yaml                  # Flutter dependencies
│   └── android/                      # Android-specific config
├── .github/
│   └── workflows/
│       └── build.yml                 # GitHub Actions CI/CD
└── README.md                         # This file
```

## Setup Instructions

### Prerequisites
- Flutter 3.16.0 or higher
- Node.js 18.0.0 or higher
- Firebase project
- Google Play Console account
- AdMob account
- Gemini API key
- Hugging Face API token

### Backend Setup

1. **Install dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials
   ```

3. **Required environment variables**
   - Firebase service account credentials
   - Gemini API key
   - Hugging Face API token
   - Google Play product IDs
   - Package name

4. **Start backend**
   ```bash
   npm start
   # Or for development with auto-reload
   npm run dev
   ```

### Flutter Setup

1. **Install dependencies**
   ```bash
   cd flutter
   flutter pub get
   ```

2. **Configure Firebase**
   - Download `google-services.json` from Firebase Console
   - Place in `flutter/android/app/`
   - Download `GoogleService-Info.plist` for iOS

3. **Configure AdMob**
   - Update `lib/constants/ad_constants.dart` with your Ad Unit IDs
   - Use test IDs for development, production IDs for release

4. **Configure Google Play Billing**
   - Add product IDs to `lib/services/billing_service.dart`
   - Ensure products are created in Google Play Console

5. **Run app**
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication
- `POST /api/user/init` - Initialize or restore user
- `GET /api/user/profile` - Get user profile and subscription status

### App Generation
- `POST /api/generate` - Generate app from prompt
- `POST /api/edit/:appId` - Edit existing app

### Billing
- `POST /api/billing/verify-purchase` - Verify purchase token
- `POST /api/billing/restore-purchases` - Restore previous purchases

### Publishing
- `POST /api/publish/:appId` - Publish app to shareable link
- `GET /api/published/:shareId` - Get published app

## Tier Configuration

| Tier | Monthly Credits | Max Apps | Max Prompts | Price |
|------|-----------------|----------|-------------|-------|
| Free | 5 | 2 | 5 | Free |
| Plus | 25 | 5 | 25 | $4.99 |
| Pro | 60 | 15 | 60 | $9.99 |
| Ultra | 100 | 20 | 100 | $19.99 |

## AI Routing

### Free Tier
- **Provider**: Hugging Face API
- **Model**: Mistral-7B-Instruct or Llama-3
- **Cost**: Free

### Paid Tiers (Plus, Pro, Ultra)
- **Provider**: Google Gemini API
- **Model**: gemini-2.5-flash
- **Cost**: Per-request pricing

## AdMob Configuration

### Test Ad Unit IDs (Development)
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

### Production Ad Unit IDs
Replace test IDs in `lib/constants/ad_constants.dart` with your production IDs from AdMob Console.

## GitHub Actions CI/CD

The project includes automated builds via GitHub Actions:

1. **Triggers**: Push to main/develop, Pull requests
2. **Builds**: APK (debug/release) and AAB (release)
3. **Artifacts**: Available for download
4. **Optional**: Auto-upload to Google Play Store (requires service account)

### Required GitHub Secrets
- `ANDROID_KEYSTORE_BASE64`: Base64-encoded keystore file
- `KEYSTORE_PASSWORD`: Keystore password
- `KEY_ALIAS`: Key alias
- `KEY_PASSWORD`: Key password
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Google Play service account (optional)

## Security Best Practices

1. **Never commit secrets**: Use GitHub Secrets and environment variables
2. **Backend-only API keys**: All sensitive keys stored on backend
3. **Token verification**: Backend verifies all purchases with Google Play
4. **Firebase security rules**: Restrict database access to authenticated users
5. **HTTPS only**: All API calls use HTTPS

## Legal & Compliance

### Privacy Policy
- URL: https://sites.google.com/view/v-astra-create-privacy-policy/home
- Accessible from app settings

### Terms & Conditions
- URL: https://sites.google.com/view/v-astra-create-terms/home
- Accessible from app settings

## Troubleshooting

### Build Issues
- Clear Flutter cache: `flutter clean`
- Rebuild dependencies: `flutter pub get`
- Check Java version: `java -version` (should be 17+)

### Firebase Issues
- Verify service account credentials
- Check Firebase project settings
- Ensure Firestore is enabled

### AdMob Issues
- Use test Ad Unit IDs for development
- Check AdMob account status
- Verify app is registered in AdMob Console

### Billing Issues
- Ensure products are created in Google Play Console
- Check product IDs match configuration
- Test with test accounts first

## Future Enhancements

- [ ] Real-time app preview
- [ ] Collaboration features
- [ ] Template library
- [ ] Advanced analytics
- [ ] Custom domain support
- [ ] API marketplace

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review GitHub Issues
3. Contact support@vastracreate.app

## License

MIT License - See LICENSE file for details

## Credits

Built with Flutter, Firebase, Google Cloud, and Gemini AI.

---

**V Astra Create** - Transform Ideas into Apps with AI
