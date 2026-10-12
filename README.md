# Smart Expense Manager (MobyMoney)

Enterprise financial management Flutter mobile application with Google OAuth 2.0, multi-currency accounting (INR, USD, EUR, GBP, AED), interactive visual analytics, conversational AI financial assistant, and resilient zero-crash offline architecture.

---

## ⚙️ Central API & Endpoints Configuration

All backend server configurations and endpoint URLs can be modified in a single location:

- **Master Configuration**: [`lib/core/config/app_config.dart`](file:///c:/Users/ABHI/StudioProjects/mobymoney/lib/core/config/app_config.dart)
- **Endpoints URI Registry**: [`lib/core/networking/api_endpoints.dart`](file:///c:/Users/ABHI/StudioProjects/mobymoney/lib/core/networking/api_endpoints.dart)
- **Base URL & Environment**: `.env` and [`lib/core/constants/app_constants.dart`](file:///c:/Users/ABHI/StudioProjects/mobymoney/lib/core/constants/app_constants.dart)

```dart
// Usage examples across the app:
AppConfig.apiBaseUrl;        // Server host
AppConfig.googleAuth;        // '/api/mobile/auth/google'
AppConfig.dailyExpense;      // '/dailyexpense'
AppConfig.chartData;         // '/chart-data'
AppConfig.aiChat;            // '/api/ai/chat'
```

## 🚀 Step-by-Step Project Setup Guide

### 1. Prerequisites
- **Flutter SDK**: `^3.8.1` (or Flutter 3.29+)
- **Dart SDK**: `^3.8.1`
- **Android Studio** (with Android SDK 35+) / **Xcode** (for iOS builds)
- **Git**

### 2. Environment File Setup
Create or verify a `.env` file in the project root directory (`mobymoney/.env`):
```env
API_BASE_URL=https://expensemanager-0ac3.onrender.com
GOOGLE_SERVER_CLIENT_ID=<your-google-web-client-id>.apps.googleusercontent.com
```

### 3. Install Dependencies
Run the following command in the project root to fetch all packages:
```bash
flutter pub get
```

### 4. Code Quality & Analysis
Verify that the project is completely error-free:
```bash
flutter analyze
```

### 5. Run the Application
Connect a real device or launch an emulator, then execute:
```bash
# Debug run
flutter run

# Run with specific backend URL directly (optional)
flutter run --dart-define=API_BASE_URL=https://expensemanager-0ac3.onrender.com
```

### 6. Production Builds
```bash
# Build Android App Bundle (.aab) for Google Play Store:
flutter build appbundle --release

# Build Android APK (.apk):
flutter build apk --release

# Build iOS Archive / IPA for Apple App Store:
flutter build ipa --release
```

---

## 📁 Delivery & Technical Documentation Package

Complete architectural blueprints, developer guides, and master documentation are available in:
- [`SmartExpense_Delivery/`](file:///c:/Users/ABHI/StudioProjects/mobymoney/SmartExpense_Delivery/README.md)
  - `Documentation/SmartExpense_Technical_Documentation.pdf`
  - `Documentation/SmartExpense_Technical_Documentation.docx`
  - `Architecture/SmartExpense_System_Architecture.svg`
  - `Architecture/SmartExpense_System_Architecture.png`


