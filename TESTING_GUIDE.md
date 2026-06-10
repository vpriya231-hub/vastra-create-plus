# V Astra Create - Testing Guide

This guide provides comprehensive testing procedures for the Flutter mobile app and Node.js backend.

## Table of Contents

1. [Unit Testing](#unit-testing)
2. [Integration Testing](#integration-testing)
3. [UI Testing](#ui-testing)
4. [Backend Testing](#backend-testing)
5. [Firebase Testing](#firebase-testing)
6. [Google Play Billing Testing](#google-play-billing-testing)
7. [AdMob Testing](#admob-testing)
8. [Performance Testing](#performance-testing)

---

## Unit Testing

### Flutter Unit Tests

Unit tests verify individual functions and classes in isolation.

#### Running Unit Tests

```bash
cd flutter
flutter test
```

#### Running Tests with Coverage

```bash
flutter test --coverage
cd ..
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

#### Test File Structure

```
flutter/test/
├── services/
│   ├── api_service_test.dart
│   ├── firebase_service_test.dart
│   ├── billing_service_test.dart
│   └── admob_service_test.dart
├── providers/
│   └── user_provider_test.dart
└── utils/
    └── credit_calculator_test.dart
```

#### Example Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:v_astra_create/services/api_service.dart';

void main() {
  group('ApiService', () {
    test('generateApp deducts credits correctly', () async {
      final apiService = ApiService();
      
      // Mock the HTTP response
      final result = await apiService.generateApp(
        prompt: 'Test prompt',
        appName: 'Test App',
      );
      
      expect(result['creditsDeducted'], 1);
      expect(result['appId'], isNotNull);
    });
  });
}
```

### Backend Unit Tests

```bash
cd backend
npm test
```

---

## Integration Testing

### Flutter Integration Tests

Integration tests verify how different parts of the app work together.

#### Running Integration Tests

```bash
cd flutter
flutter drive --target=test_driver/app.dart
```

#### Integration Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:v_astra_create/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('User can generate an app', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.tap(find.byIcon(Icons.login));
      await tester.pumpAndSettle();

      // Navigate to generate
      await tester.tap(find.text('Generate New App'));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(find.byType(TextField).first, 'My App');
      await tester.enterText(find.byType(TextField).last, 'A test app');
      await tester.tap(find.text('Generate App'));
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('App generated successfully!'), findsOneWidget);
    });
  });
}
```

---

## UI Testing

### Widget Testing

Test individual UI components.

```bash
cd flutter
flutter test test/widgets/
```

#### Widget Test Example

```dart
testWidgets('Dashboard displays user tier', (WidgetTester tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MaterialApp(home: DashboardPage()),
    ),
  );

  expect(find.text('Plus Plan'), findsOneWidget);
  expect(find.text('5 / 25'), findsOneWidget); // Credits
});
```

### Manual UI Testing Checklist

- [ ] **Login Page**
  - [ ] Google Sign-In button works
  - [ ] Legal links open correctly
  - [ ] Loading state displays during auth
  - [ ] Error messages show on auth failure

- [ ] **Dashboard Page**
  - [ ] User tier displays correctly
  - [ ] Credits progress bar updates
  - [ ] "Generate New App" button is disabled when no credits
  - [ ] Banner ad displays for free tier
  - [ ] Upgrade card shows for free tier users

- [ ] **Generate Page**
  - [ ] Form validation works
  - [ ] Credit cost displays correctly
  - [ ] Loading state during generation
  - [ ] Error messages on generation failure
  - [ ] Success navigation to preview

- [ ] **Subscription Page**
  - [ ] All 4 plans display correctly
  - [ ] "Most Popular" badge on Plus plan
  - [ ] Subscribe buttons trigger purchase flow
  - [ ] Restore Purchases button works
  - [ ] Pricing displays correctly

- [ ] **Settings Page**
  - [ ] Legal links open in browser
  - [ ] Sign out works correctly
  - [ ] Account info displays

---

## Backend Testing

### API Endpoint Testing

#### Using cURL

```bash
# Initialize user
curl -X POST https://api.vastracreate.app/api/user/init \
  -H "Authorization: Bearer <firebase-token>" \
  -H "Content-Type: application/json"

# Generate app
curl -X POST https://api.vastracreate.app/api/generate \
  -H "Authorization: Bearer <firebase-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Create a todo list app",
    "appName": "My Todo App"
  }'

# Verify purchase
curl -X POST https://api.vastracreate.app/api/billing/verify-purchase \
  -H "Authorization: Bearer <firebase-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "productId": "v_astra_plus_monthly",
    "purchaseToken": "<purchase-token>"
  }'
```

#### Using Postman

1. Import the API collection from `backend/postman_collection.json`
2. Set up environment variables:
   - `firebase_token` - Your Firebase ID token
   - `base_url` - Backend URL
3. Run requests and verify responses

### Backend Unit Tests

```bash
cd backend
npm test

# With coverage
npm run test:coverage
```

### Load Testing

```bash
# Install Artillery
npm install -g artillery

# Run load test
artillery run backend/load-test.yml
```

---

## Firebase Testing

### Firebase Emulator Suite

#### Setup

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Start emulator
firebase emulators:start
```

#### Test Firebase Auth

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  test('Firebase auth mock', () async {
    final auth = MockFirebaseAuth();
    
    // Test sign in
    final user = await auth.signInWithGoogle();
    expect(user.uid, isNotNull);
  });
}
```

#### Test Firestore

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloud_firestore_mocks/cloud_firestore_mocks.dart';

void main() {
  test('Firestore mock', () async {
    final firestore = FakeFirebaseFirestore();
    
    // Test write
    await firestore.collection('users').doc('test').set({
      'tier': 'free',
      'credits': 2,
    });
    
    // Test read
    final doc = await firestore.collection('users').doc('test').get();
    expect(doc['tier'], 'free');
  });
}
```

---

## Google Play Billing Testing

### Test Purchases

1. **Add test account to Google Play Console**
   - Go to Settings > License Testing
   - Add your test email

2. **Use test product IDs**
   - `android.test.purchased` - Simulates successful purchase
   - `android.test.canceled` - Simulates canceled purchase
   - `android.test.refunded` - Simulates refunded purchase

3. **Test on device**
   ```bash
   flutter run --release
   ```

4. **Verify purchase verification**
   - Check backend logs for verification
   - Confirm user tier updated
   - Verify credits increased

### Billing Test Checklist

- [ ] Free tier user cannot purchase
- [ ] Purchase flow initiates correctly
- [ ] Backend verifies purchase token
- [ ] User tier updates after purchase
- [ ] Credits increase after purchase
- [ ] Ads disappear for paid tier
- [ ] Restore purchases works
- [ ] Subscription management opens Play Store

---

## AdMob Testing

### Test Ad Unit IDs

Use Google's test ad unit IDs during development:

```dart
// Banner
ca-app-pub-3940256099942544/6300978111

// Interstitial
ca-app-pub-3940256099942544/1033173712

// Rewarded
ca-app-pub-3940256099942544/5224354917
```

### AdMob Test Checklist

- [ ] **Free Tier Users**
  - [ ] Banner ads display on dashboard
  - [ ] Interstitial ads show on generate
  - [ ] Rewarded ads trigger on download
  - [ ] Ad impressions tracked

- [ ] **Paid Tier Users**
  - [ ] No banner ads displayed
  - [ ] No interstitial ads shown
  - [ ] No rewarded ads triggered
  - [ ] Ad loading skipped

- [ ] **Ad Behavior**
  - [ ] Ads load within 3 seconds
  - [ ] Click-through works
  - [ ] Close button works
  - [ ] Multiple ad cycles work

---

## Performance Testing

### Flutter Performance

```bash
cd flutter
flutter run --profile

# In DevTools, check:
# - Frame rate (60 FPS target)
# - Memory usage
# - CPU usage
# - Jank detection
```

### Backend Performance

```bash
# Load test
ab -n 1000 -c 100 https://api.vastracreate.app/api/health

# Response time analysis
artillery run backend/load-test.yml
```

### Performance Metrics

| Metric | Target | Tool |
|--------|--------|------|
| App startup | < 2s | DevTools |
| API response | < 500ms | Postman |
| Generate app | < 10s | Manual |
| Ad load | < 3s | AdMob |
| Memory usage | < 100MB | DevTools |
| Frame rate | 60 FPS | DevTools |

---

## Continuous Integration Testing

### GitHub Actions

The CI/CD pipeline runs tests automatically:

```yaml
- name: Run Flutter tests
  run: flutter test --coverage

- name: Run backend tests
  run: npm test
```

### Pre-commit Hooks

```bash
# Install husky
npm install husky --save-dev

# Add pre-commit hook
npx husky add .husky/pre-commit "flutter analyze && npm run lint"
```

---

## Test Coverage Goals

- **Flutter**: Minimum 80% coverage
- **Backend**: Minimum 85% coverage
- **Critical paths**: 100% coverage

### Generate Coverage Report

```bash
# Flutter
cd flutter
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Backend
cd backend
npm run test:coverage
```

---

## Troubleshooting

### Common Test Issues

| Issue | Solution |
|-------|----------|
| Firebase auth fails | Use Firebase emulator or mock |
| Google Play billing fails | Use test product IDs |
| AdMob ads don't show | Use test ad unit IDs |
| Tests timeout | Increase timeout in test config |
| Memory issues | Run tests with `--memory-limit` |

---

## Next Steps

1. Set up CI/CD pipeline with GitHub Actions
2. Configure code coverage reporting
3. Set up automated testing on every push
4. Monitor test results and coverage trends
5. Implement performance monitoring
