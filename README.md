# AgriPortal 🌾

A Flutter-based agricultural land leasing platform for Nepal that connects **land owners** with **farmers**.

## Features

### Mobile App (Flutter)
- 🔐 Firebase Auth — Google Sign-In & Phone OTP
- 👩‍🌾 Farmer home — browse, filter, and save land listings
- 🏡 Land owner dashboard — list, manage, and approve applications
- 📋 KYC verification with real document upload (ImgBB)
- 💰 Wallet system — Rs 20 listing fee, transaction history
- 💬 Real-time chat (Firebase Realtime Database)
- 🔔 Push notifications (Firebase Cloud Messaging)
- 📍 Location map integration
- ❤️ Save/unsave lands (Firestore)
- 📨 In-app support messages

### Admin Panel (Web)
- 📊 Dashboard with live stats
- ✅ KYC approval/rejection with document image preview
- 🌿 Land listing approval/rejection
- 👥 User management
- 📬 Support messages (open/resolve)
- 📈 Analytics charts
- 💬 Message feed (Firebase RTDB)

## Tech Stack

- **Flutter** 3.x (Dart)
- **Firebase** — Auth, Firestore, Realtime Database, Messaging
- **ImgBB** — Image hosting for land photos and KYC documents
- **go_router** — Navigation
- **Admin Panel** — Vanilla HTML/CSS/JS + Bootstrap 5

## Setup

### 1. Firebase
- Create a Firebase project
- Add Android app with package `com.agriportal.app`
- Download `google-services.json` → `android/app/`
- Enable Authentication (Google + Phone), Firestore, Realtime Database, Messaging

### 2. Firestore Rules
Copy `firebase/firestore.rules` content to Firebase Console → Firestore → Rules → Publish

### 3. ImgBB API Key
Get a free key at [api.imgbb.com](https://api.imgbb.com) and set it in `lib/core/imgbb_service.dart`

### 4. Run
```bash
flutter pub get
flutter run
```

### 5. Admin Panel
Open `admin_panel/index.html` in any browser. Sign in with a Firebase admin account.

## Project Structure

```
lib/
├── core/           # Services (Firebase, Wallet, Notifications, ImgBB)
├── presentation/   # All screens
├── routes/         # go_router config
├── theme/          # App theme
└── widgets/        # Shared widgets

admin_panel/
├── index.html      # Admin dashboard
├── css/admin.css   # Styles
└── js/
    ├── admin.js         # Dashboard logic
    └── firebase-init.js # Firebase SDK init
```

## Security Notes

- `google-services.json` and `env.json` are excluded from version control
- Never commit API keys to public repositories
- Set Firestore rules before going to production
