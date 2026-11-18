# GymManager - Offline-First Gym Management & Member Tracking App

A modern, high-performance **Flutter** application built with an **offline-first Cloud Firestore** architecture. Designed for gym owners, fitness studios, and trainers to manage memberships, attendance, billing, and workouts.

---

## 🚀 Key Features

- **Member Management**:
  - Full member lifecycle (Active, Expiring in 1-3 days, Expired, Frozen/Paused).
  - Search by name or phone number, and filter by status.
  - Digital Member ID card with auto-generated QR code.
  - One-tap WhatsApp renewal reminders with pre-filled message templates.
  - Membership Freeze / Pause functionality (for injury/travel).

- **Attendance System**:
  - Instant camera **QR Code Scanner** for contactless desk check-ins.
  - Auto-warning alert when an expired member attempts to check in.
  - Manual punch dialog for fast front-desk logs.
  - Today's punch logs and real-time count metrics.

- **Fee Collection & Invoicing**:
  - Full support for partial payments & installment tracking (`totalAmount`, `paidAmount`, `dueAmount`).
  - Automated PDF invoice generator (official receipts with gym branding, itemized table, and printing/sharing).
  - One-click bulk WhatsApp payment reminders for all members with pending dues.

- **Workout Routine Master**:
  - Pre-loaded master workout routines (Push-Pull-Legs, Upper-Lower, Fat Loss Circuit, etc.).
  - One-tap assignment and WhatsApp sharing directly to members' phones.

- **Offline-First Firebase Backend**:
  - Local caching with unlimited cache size enabled via `Settings(persistenceEnabled: true)`.
  - Works 100% offline at the gym desk and syncs automatically when an internet connection is available.

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart 3.x)
- **Architecture**: Feature-First with Riverpod State Management
- **Backend & Database**: Firebase Core & Cloud Firestore (Offline Persistence)
- **QR Code Tools**: `mobile_scanner` (camera reader) & `qr_flutter` (card renderer)
- **PDF & Invoicing**: `pdf` & `printing`
- **Communication**: `url_launcher` (WhatsApp & direct phone dialing)
- **CI/CD**: GitHub Actions automated pipeline

---

## 📂 Project Structure

```text
lib/
├── main.dart
├── core/
│   ├── constants/             # App constants, collection names, enums
│   ├── services/              # Firebase & offline persistence initialization
│   ├── theme/                 # Dark slate fitness theme (Material 3)
│   └── utils/                 # Date formatters, currency, WhatsApp launcher
└── features/
    ├── dashboard/             # Overview tab, KPI cards, quick actions
    ├── members/               # Models, repositories, List, Add, and Detail screens
    ├── attendance/            # Models, repositories, Daily punch, QR camera scanner
    ├── billing/               # Models, Billing dashboard, PDF Invoice generator
    └── workouts/              # Models, Master workout templates & WhatsApp sender
```

---

## 🔧 Firebase Setup

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Enable **Cloud Firestore** and **Firebase Authentication**.
3. Download `google-services.json` and place it in `android/app/google-services.json`.
4. Run `flutter pub get`.

---

## 🤖 GitHub Actions CI/CD Pipeline

The repository includes a ready-to-run GitHub Actions workflow located at `.github/workflows/flutter_ci.yml` that automatically:
1. Sets up the Flutter stable SDK and Java 17.
2. Installs dependencies (`flutter pub get`).
3. Runs static code analysis (`flutter analyze`).
4. Executes unit and widget tests (`flutter test`).
5. Compiles and packages an **Android Debug APK** (`flutter build apk --debug`).
6. Uploads the built APK as a downloadable GitHub Actions artifact.
