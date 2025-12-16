# OneBank Revamp

This is a  **full‑stack digital banking prototype** built with **Flutter**, **Firebase**, and **Cloud Functions**, designed to demonstrate **real‑world fintech architecture**, transaction notifications, and scheduled financial insights.

> ⚠️ **Disclaimer**: This project is for **educational and research purposes only**. It is **NOT** a licensed banking application and should not be used in production to handle real money.

---

## 📌 Project Overview

**OneBank Revamp** simulates the core features of a modern digital bank:

*  Authentication (Firebase Auth)
* Transactions (credits & debits)
* Real‑time credit alerts (FCM + Cloud Functions)
* Weekly financial insights and Analytics service (Cloud Scheduler)
* Flutter mobile app (Android / iOS ready)
* Serverless backend (Firebase Functions v2)

This project is intentionally open‑source to help **students, junior developers, and fintech learners** understand how modern banking apps are structured, and to challenge the norms of design, software architecture and best practices.

---

## Architecture Overview

```
Flutter App
   │
   ├── Firebase Auth
   ├── Firestore (users, transactions, fcm_tokens, notifications, accounts)
   ├── Firebase Cloud Messaging
   │
Firebase Functions (Node.js 24)
   ├── sendCreditAlert (Firestore trigger)
   └── sendWeeklyInsights (Cloud Scheduler)
```

---

## Tech Stack

### Frontend

* Flutter (Dart)
* Firebase Auth
* Cloud Firestore
* Firebase Messaging (FCM)
* flutter_local_notifications

### Backend

* Firebase Cloud Functions (2nd Gen)
* Node.js 24
* Firestore
* Cloud Scheduler
* Eventarc

---

## Repository Structure

```
onebank_revamp/
├── android/
├── ios/
├── lib/
│   ├── services/
│   │   └── notification_service.dart
|   |   |__ transaction_service.dart
|   |___ models/
|   |___ screens/
|   |___ widgets/
|   | 
│   └── main.dart
├── functions/
│   ├── index.js
│   └── package.json
├── firebase.json
├── firestore.rules
├── pubspec.yaml
└── README.md
```

---

## Getting Started

### Prerequisites

Make sure you have the following installed:

* Flutter SDK (latest stable)
* Node.js ≥ 20 (recommended: 24)
* Firebase CLI
* Android Studio / Xcode

```bash
flutter doctor
firebase --version
node --version
```

---

### Clone the Repository

```bash
git clone https://github.com/WisdomEhirim06/onebank-revamp.git
cd onebank-revamp
```

---

### Firebase Setup

1. Create a Firebase project

2. Enable:

   * Authentication (Email/Password)
   * Firestore
   * Cloud Messaging
   * Cloud Functions (2nd Gen)
   * Cloud Scheduler

3. Download config files:

   * `google-services.json` → `android/app/`
   * `GoogleService-Info.plist` → `ios/Runner/`

---

### Firestore Data Model

#### Users

```json
users/{userId} {
  "fullName": "John Doe",
  "email": "john@example.com"
}
```

#### Transactions

```json
transactions/{transactionId} {
  "userId": "uid",
  "amount": 5000,
  "isCredit": false,
  "recipientName": "Netflix",
  "timestamp": Timestamp
}
```

#### FCM Tokens

```json
fcm_tokens/{userId} {
  "userId": "uid",
  "token": "fcm_token_here",
  "platform": "android",
  "lastUpdated": Timestamp
}
```

---

### Install Dependencies

#### Flutter

```bash
flutter pub get
```

#### Cloud Functions

```bash
cd functions
npm install
```

---

### Run the App

```bash
flutter run
```

Make sure USB debugging is enabled on Android.

---

### Deploy Backend

```bash
firebase deploy --only functions
```

To test weekly insights manually:

```bash
firebase functions:shell
> sendWeeklyInsights()
```

---

## Notification Features

### Credit Alerts

Triggered when a document is added to:

```
notification_queue/{notificationId}
```

### Weekly Insights

* Runs every **Sunday at 8 PM (Africa/Lagos)**
* Summarizes:

  * Total expenses
  * Spending patterns
  * Top recipients
  * Highest spending day

---

## 🧪 Educational Focus

This project is intentionally designed to demonstrate:

* Event‑driven architecture
* ACID‑safe Firestore reads
* Background job scheduling
* Token‑based push notifications
* Real‑world fintech constraints

It is ideal for:

* Final year projects
* Internship preparation
* System design interviews
* Open‑source collaboration

---

## 📜 License

### **MIT License**

This project is licensed under the MIT License.

You are free to:

* Use
* Modify
* Distribute
* Learn from

As long as attribution is preserved.

> MIT was chosen to encourage **learning, experimentation, and extension** without legal friction.

---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create a feature branch
3. Commit changes with clear messages
4. Open a pull request

---

## ⚠️ Disclaimer

This project:

* Is **NOT** a real bank
* Does **NOT** handle real money
* Is for **learning purposes only**

Do not deploy with real financial data.

---

## 👤 Author

**Wisdom Ehirim**
Software Engineering & Fintech Systems

---

## ⭐ Support

If this project helped you learn something:

* ⭐ Star the repo
* 🍴 Fork it
* 🧠 Share with others

Happy building 🚀
