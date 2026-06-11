# AgriPortal Admin Panel (Next.js)

A full-featured admin dashboard built with **Next.js 16**, **TypeScript**, **Tailwind CSS**, and **Firebase**.

## Stack
- **Next.js 16** (App Router, static export)
- **TypeScript** — fully typed
- **Tailwind CSS** — utility-first styling
- **Firebase** — Firestore + Realtime Database + Auth
- **Lucide React** — icons

## Features
- 🔐 Firebase Email/Password + Google Sign-In with demo fallback
- 📊 Overview dashboard with live activity feed
- 👥 Users management — search, filter, toggle active, view details
- 🪪 KYC Verification — approve/reject with document thumbnails
- 🌾 Land Listings — approve/deactivate/delete with Firestore write
- 📋 Applications — approve/reject with real-time updates
- 💬 Messages — live conversation viewer (Realtime Database)
- 🎧 Support Messages — open/resolve/delete
- 📈 Analytics — bar charts for users, KYC, provinces, applications
- ⚙️ Settings — profile, notification toggles, Firebase config

## Getting started

```bash
npm install
npm run dev       # development server on http://localhost:3000
npm run build     # production build → out/
npm run start     # serve the build
```

## Firebase Setup
The project is pre-configured for `agriportal-9ee3d`. To use your own project:
1. Update `lib/firebase.ts` with your config
2. Enable Email/Password in Firebase Console → Authentication → Sign-in method
3. Optionally add your admin UID to `admins/{uid}` in Firestore

## Demo mode
If Firebase is unreachable, the panel runs on built-in seed data. Any email/password logs you in.
