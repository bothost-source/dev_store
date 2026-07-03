# DEVSTORE

A real app store for Android built with Flutter, Firebase, and Storj.

## Features

- **Public App Store**: Browse, search, download, and install Android apps
- **Developer Portal**: Upload apps, manage versions, track downloads
- **Admin Panel**: Approve/reject apps, manage developers, view analytics
- **Multi-language**: English, French, Spanish
- **Dark/Light/System Theme**: User preference or follow system
- **Push Notifications**: App updates, new releases
- **App Reporting**: Users can report inappropriate apps
- **Reviews & Ratings**: Community feedback system
- **Similar Apps**: Recommendations based on category
- **Top Charts**: Most downloaded apps ranked

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Frontend | Flutter 3.22+ |
| State Management | Flutter BLoC + Provider |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Storj (S3-compatible, 25GB free) |
| Push Notifications | Firebase Cloud Messaging |
| CI/CD | GitHub Actions |

## Setup Instructions

### 1. Firebase Setup

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create a new project named `devstore`
3. **Disable Google Analytics** during creation
4. Go to **Project Settings** (gear icon)
5. Under **Your apps**, click **"</>"** (Web app)
6. Register app name: `devstore`
7. Copy the `firebaseConfig` values

### 2. Configure Firebase in the App

Open `lib/core/services/firebase_options.dart` and replace ALL placeholder values:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_REAL_API_KEY',           // From firebaseConfig
  appId: 'YOUR_REAL_APP_ID',             // From firebaseConfig
  messagingSenderId: 'YOUR_REAL_SENDER', // From firebaseConfig
  projectId: 'YOUR_PROJECT_ID',          // From firebaseConfig
  storageBucket: 'YOUR_BUCKET',          // From firebaseConfig
);
```

### 3. Enable Firebase Services

In Firebase Console:
- **Authentication** → Get started → Enable **Email/Password**
- **Firestore Database** → Create database → **Start in test mode**
- **Cloud Messaging** → Enable (for push notifications)

### 4. Configure Storj Secret Key

Open `lib/core/services/storj_service.dart` and replace:
```dart
secretKey: 'YOUR_SECRET_KEY_HERE',
```
with your actual Storj secret key.

**IMPORTANT**: In production, NEVER hardcode secrets. Use Firebase Cloud Functions or environment variables.

### 5. Firestore Security Rules

Go to Firestore Database → Rules → Paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /apps/{appId} {
      allow read: if resource.data.status == 'approved' || request.auth != null;
      allow create: if request.auth != null && request.resource.data.developerId == request.auth.uid;
      allow update, delete: if request.auth != null && (resource.data.developerId == request.auth.uid || request.auth.token.admin == true);
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    match /reports/{reportId} {
      allow create: if request.auth != null;
      allow read, update: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

### 6. Install Dependencies

```bash
flutter pub get
flutter gen-l10n
```

### 7. Run the App

```bash
# For Android
flutter run

# For Web (Admin Panel)
flutter run -d chrome
```

### 8. Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Web (Admin Panel)
flutter build web --release
```

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants, categories
│   ├── theme/           # Light/Dark themes, colors
│   ├── utils/           # Helpers, formatters
│   └── services/        # Auth, Storj, Download, Notifications
├── data/
│   ├── models/          # App, User, Review, Report models
│   └── repositories/    # Firestore operations
├── presentation/
│   ├── bloc/            # BLoC state management
│   ├── providers/       # Theme & Locale providers
│   ├── screens/
│   │   ├── auth/        # Login, Register
│   │   ├── public/      # Home, Search, App Detail, Settings
│   │   ├── developer/   # Dashboard, Upload App
│   │   └── admin/       # Dashboard, Approvals, Analytics
│   └── widgets/         # Reusable UI components
└── l10n/                # Translations (EN/FR/ES)
```

## Approval Workflow

```
Developer Uploads App
        │
        ▼
   Status: PENDING
        │
        ▼
Admin Reviews in Panel
        │
   ┌────┴────┐
   ▼         ▼
APPROVE   REJECT
   │         │
   ▼         ▼
Public    Hidden
Store     (with reason)
```

## Multi-Bucket Storage

Storj uses 2 buckets with auto-failover:
- `devstore-apps-1` (Primary)
- `devstore-apps-2` (Failover)

When bucket 1 is near full, uploads automatically switch to bucket 2.

## License

MIT License - Built with ❤️ for the developer community.
