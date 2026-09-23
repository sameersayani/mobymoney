# MobyMoney — Final Project Delivery Package

Welcome to the **MobyMoney** enterprise documentation and technical delivery package.

This folder contains the complete architecture specifications, developer onboarding manual, high-resolution system diagrams, and build guides necessary for developers, contractors, QA teams, and project stakeholders.

---

## 📁 Package Contents

```text
MobyMoney_Delivery/
│
├── Documentation/
│   ├── MobyMoney_Technical_Documentation.docx    # Editable Master Word Document
│   └── MobyMoney_Technical_Documentation.pdf     # Fixed Client/Executive Delivery PDF
│
├── Architecture/
│   ├── MobyMoney_System_Architecture.png         # High-Resolution Architecture Diagram (Raster)
│   └── MobyMoney_System_Architecture.svg         # Scalable Vector Graphics Diagram (Vector)
│
└── README.md                                     # This Delivery Index
```

---

## 📄 Documentation Highlights

The documentation files cover:

1. **Executive Summary & Project Purpose**: Overview of features, target audience, and business goals.
2. **High-Level System Architecture**: End-to-end data flow: `User -> UI -> Riverpod State Notifiers -> Domain Repositories -> Dio Network Interceptors -> Backend & Cloud Services`.
3. **Application Design Patterns**: Feature-first architecture, unidirectional state management, declarative GoRouter navigation guards.
4. **Codebase Navigation Guide**: Complete folder breakdown with key file responsibilities.
5. **Authentication & Session Security**: Google OAuth 2.0 pipeline, parallel hardware token storage (Android Keystore / iOS Keychain), automatic 401 token expiration redirect.
6. **API Specification**: Full REST contract list (`/api/mobile/auth/*`, `/dailyexpense/*`, `/chart-data`, `/download-report`, `/api/ai/*`).
7. **Zero-Crash Resilience**: Pure Dart DNS socket heartbeats (`google.com`, `cloudflare.com`, `apple.com`) eliminating native channel crashes.
8. **Multi-Currency System**: Reactive multi-currency state propagation (`INR ₹`, `USD $`, `EUR €`, `GBP £`) across charts, totals, inputs, and exports.
9. **Build & Release Guide**: Environment configuration (`.env`), keystore signing setup, and commands for Android AAB and iOS IPA generation.
10. **Troubleshooting & Developer Pitfalls**: Render cold-start mitigation, Google SHA-1 keystore requirements, and cache clearing.

---

## 🚀 Quick Start for New Developers

### 1. Prerequisites
- **Flutter SDK**: `^3.8.1` (or compatible Flutter 3.29+)
- **Dart SDK**: `^3.8.1`
- **Android Studio / Xcode** for platform emulators and signing
- **Android**: `minSdk = 23`, `targetSdk = 35`, `compileSdk = 36`
- **iOS**: Portrait orientation locked, `CADisableMinimumFrameDurationOnPhone = true` (120Hz ProMotion enabled)

### 2. Environment Setup
Ensure a `.env` file exists in the project root:
```env
API_BASE_URL=https://expensemanager-0ac3.onrender.com
GOOGLE_SERVER_CLIENT_ID=<your-web-client-id>.apps.googleusercontent.com
```

### 3. Verification & Local Run
```bash
# Verify code quality (Current status: 0 issues found)
flutter analyze

# Run on connected device / emulator
flutter run

# Build Android App Bundle (Play Store release)
flutter build appbundle --release

# Build iOS IPA (App Store release)
flutter build ipa --release
```

### 4. Key Architecture Notes
- **Authentication**: Google Sign-In only (email/password UI is present but routes to Google Sign-In)
- **File Export**: Uses system `share_plus` sheet — files are saved to app temp dir then shared via native OS picker
- **Offline Detection**: Pure Dart DNS via `InternetAddress.lookup()` — no `connectivity_plus` native channel involved
- **Google Fonts**: Runtime fetching disabled (`GoogleFonts.config.allowRuntimeFetching = false`) — works fully offline

---

## 📋 Changelog (Latest)

| Version | Date | Changes |
|---|---|---|
| v1.0.0 | Sep 2026 | Initial production release |
| v1.0.1 | Sep 2026 | Android targetSdk pinned to 35, FileProvider added, ProGuard expanded, DNS fallback fixed, iOS Info.plist bundle name corrected, Google Fonts offline mode enabled |
