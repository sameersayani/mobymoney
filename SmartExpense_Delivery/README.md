# Smart Expense Manager (MobyMoney) — Final Project Delivery Package

Welcome to the **Smart Expense Manager** (formerly MobyMoney) enterprise documentation and technical delivery package.

This folder contains the complete architecture specifications, developer onboarding manual, high-resolution system diagrams, and build guides necessary for developers, contractors, QA teams, and project stakeholders.

---

## 📁 Package Contents

```text
SmartExpense_Delivery/
│
├── Documentation/
│   ├── SmartExpense_Technical_Documentation.md      # Universal Markdown Technical Documentation
│   ├── SmartExpense_Technical_Documentation.pdf     # Fixed Client/Executive Delivery PDF (3 Pages)
│   └── SmartExpense_Technical_Documentation.docx    # Editable Master Word Document
│
├── Architecture/
│   ├── SmartExpense_System_Architecture.png         # High-Resolution Architecture Diagram (Raster)
│   └── SmartExpense_System_Architecture.svg         # Scalable Vector Graphics Diagram (Vector)
│
└── README.md                                        # This Delivery Index
```

---

## 📱 Application Screens Catalog (12 Complete Screens & Modals)

Every application page and modal in the production build:

| Screen Name | Path / Route | Description |
|---|---|---|
| **Splash Screen** | `/splash` | Mint animated branding with brand emblem and auto-authentication guard |
| **Onboarding Screen** | `/onboarding` | 3-step intro highlighting AI Expense Logging & Smart Budgeting |
| **Login Screen** | `/login` | Modern login with Google OAuth 2.0 and brand typography |
| **Register Screen** | `/register` | Registration entry point routed to Google Identity pipeline |
| **Home Dashboard** | `/` | Hero spending card, multi-currency totals breakdown, KPI metrics, weekly trend |
| **Expenses Screen** | `/expenses` | Tabbed monthly expense log with date navigator and category badges |
| **All Expenses Screen** | `/all-expenses` | Transaction list with live search, filters (Tag, Category, Sorting), and multi-currency KPI |
| **Expense Detail Screen**| `/expense-detail` | Detailed view of item with quantity, unit price, and deletion modal |
| **Analytics Screen** | `/analytics` | Multi-chart analytics (Donut Category Split, Daily Peaks Bar, Trend Line) |
| **AI Hub / AI Chat** | `/ai-chat` | Interactive AI Financial Advisor with inline expense parsing, confirmation, and categorization |
| **Settings Screen** | `/settings` | Profile info, Currency selector modal (5 currencies), CSV/XLSX export |
| **Expense Types Screen**| `/settings/expense-types`| Category management list with custom colors and icons |
| **Add Expense Dialog** | Modal | Bottom sheet / dialog for creating and editing expenses with multi-currency selector |
| **Offline Screen** | Full-Screen Overlay | Automatic overlay during internet disconnection with pure Dart DNS heartbeat |

---

## 📄 Documentation Highlights

The documentation files cover:

1. **Executive Summary & Brand Identity**: Smart Expense Manager features, target audience, and business goals.
2. **High-Level System Architecture**: End-to-end data flow: `User -> UI -> Riverpod State Notifiers -> Domain Repositories -> Dio Network Interceptors -> Backend & Cloud Services`.
3. **Application Design Patterns**: Feature-first architecture, unidirectional state management, declarative GoRouter navigation guards.
4. **Codebase Navigation Guide**: Complete folder breakdown with key file responsibilities.
5. **Authentication & Session Security**: Google OAuth 2.0 pipeline, parallel hardware token storage (Android Keystore / iOS Keychain), automatic 401 token expiration redirect.
6. **API Specification**: Full REST contract list (`/api/mobile/auth/*`, `/dailyexpense/*`, `/chart-data`, `/download-report`, `/api/ai/*`).
7. **Zero-Crash Resilience**: Pure Dart DNS socket heartbeats (`google.com`, `cloudflare.com`, `apple.com`) eliminating native channel crashes.
8. **Multi-Currency System**: Reactive multi-currency state propagation across 5 global currencies:
   - **INR** (`₹`) — Indian Rupee
   - **USD** (`$`) — US Dollar
   - **EUR** (`€`) — Euro
   - **GBP** (`£`) — British Pound
   - **AED** (`د.إ`) — UAE Dirham
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
- **API Endpoints & Central Configuration**: All backend endpoints and configuration can be modified in a single location:
  - `lib/core/config/app_config.dart`: Master config aggregating Base URL, timeouts, and all endpoint getters (`AppConfig.dailyExpense`, `AppConfig.aiChat`, etc.)
  - `lib/core/networking/api_endpoints.dart`: Central endpoint URI string definitions (`/api/mobile/auth/*`, `/dailyexpense/*`, `/chart-data`, `/api/ai/*`)
  - `lib/core/constants/app_constants.dart` & `.env`: Host Base URL configuration (`API_BASE_URL`)
- **Authentication**: Google Sign-In only (email/password UI is present but routes to Google Sign-In)
- **File Export**: Uses system `share_plus` sheet — files are saved to app temp dir then shared via native OS picker
- **Offline Detection**: Pure Dart DNS via `InternetAddress.lookup()` — no `connectivity_plus` native channel involved
- **Google Fonts**: Runtime fetching disabled (`GoogleFonts.config.allowRuntimeFetching = false`) — works fully offline

---

## 📋 Changelog (Latest)

| Version | Date | Changes |
|---|---|---|
| v1.0.0 | Sep 2026 | Initial release |
| v1.0.1 | Sep 2026 | Android targetSdk pinned to 35, FileProvider added, ProGuard expanded, DNS fallback fixed, iOS Info.plist bundle name corrected, Google Fonts offline mode enabled |
| v1.1.0 | Sep 2026 | Rebranded to Smart Expense Manager, added Onboarding flow, full multi-currency system (INR, USD, EUR, GBP, AED), floating bottom nav dock, centralized AppConfig endpoint file, AI bubble overflow fixes |


