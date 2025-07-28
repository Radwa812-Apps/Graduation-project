# 📍 NearMe – Real-Time Group Location & Safety App

NearMe is a smart mobile application designed to help families, friends, and school supervisors stay connected through real-time location sharing, geofencing alerts, and safety features.

---

## 📱 Key Features

- *🔴 Live Location Tracking*Share your real-time location with group members on an interactive map using Google Maps API.
- *🚧 Geofencing Notifications*Automatic alerts when members enter or exit predefined safe zones (e.g., home, school).
- *🚨 Emergency Mode via Lock Screen*Instantly send an SOS message with your location using a dedicated lock screen button.
- *👥 Group & Private Chat*Secure built-in messaging system for group communication and one-on-one chats.
- *📢 Public Notification Board*Centralized feed showing all general announcements across different groups.
- *🔒 Risk Mode*
  Send quick danger alerts with live location if the user feels unsafe.

---

## 🧱 Architecture & Tech Stack

| Layer               | Technologies                        |
| ------------------- | ----------------------------------- |
| *Frontend*        | Flutter (Dart)                      |
| *Authentication*  | Firebase Authentication             |
| *Database*        | Cloud Firestore (Firebase)          |
| *Real-time Sync*  | Firebase Realtime + Cloud Messaging |
| *Maps & Location* | Google Maps API + Geofencing        |
| *Notifications*   | Firebase Cloud Messaging            |

---

## 👨‍👩‍👧‍👦 Target Users

- Families with children or elderly members
- Friends traveling together
- School field trip supervisors
- Any group needing real-time location safety

---

## 📸 Screenshots

![Home Screen](assets\screenshots\WhatsApp Image 2025-07-29 at 00.03.19_ce9f8294.jpg)
![Group inside](assets\screenshots\WhatsApp Image 2025-07-29 at 00.03.21_b05af999.jpg)
![sign in/ login](assets\screenshots\WhatsApp Image 2025-07-29 at 00.03.13_d3d72058.jpg)
![chats](assets\screenshots\WhatsApp Image 2025-07-29 at 00.03.21_246e4b42.jpg)

---

## 📦 Installation & Setup

1. *Clone the repository*bash
   git clone https://github.com/ShimaaAbdalraheem/NearMe-App.git
2. *Install dependencies*
   bash
   flutter pub get
3. *Run the app*
   bash
   flutter run

### Prerequisites

- Flutter SDK installed
- Android Studio/Xcode for emulators
- Firebase project configured

## ✨Future Enhancements

- Voice alerts for emergencies
- Admin dashboard for supervisors
- Offline location caching
- Dark mode support
- Periodic location sharing intervals
- Integration with wearables

## 📜 License

This project is developed as part of an academic graduation requirement.
For collaboration, contributions, or reuse permission – feel free to reach out.

## 📧 Contact

📧 Email: emamradwa417@gmail.com
🔗 GitHub: https://github.com/Radwa812-Apps

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
