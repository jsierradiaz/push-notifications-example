# Push Notifications Example

A complete, production-ready example demonstrating push notifications implementation using Firebase Cloud Messaging (FCM) with a Flutter mobile application and a NestJS backend server.

## 📋 Overview

This repository contains two main components that work together to demonstrate a full push notification system:

1. **Flutter Mobile App** (`push_notifications_mobile_app/`) - A cross-platform mobile application (Android & iOS) that receives and handles push notifications
2. **NestJS Backend** (`push-notifications-backend/`) - A backend server that sends push notifications to devices using FCM HTTP v1 API

## 🏗️ Architecture

```text
┌─────────────────────────────┐
│   Flutter Mobile App        │
│  (Android, iOS, Web, etc.)  │
│                             │
│  - Firebase initialization  │
│  - Token management         │
│  - Notification handling    │
│  - Topic subscriptions      │
└──────────────┬──────────────┘
               │
               │ FCM Token
               │ Receives notifications
               │
┌──────────────▼──────────────┐
│  Firebase Cloud Messaging   │
│         (FCM)               │
└──────────────▲──────────────┘
               │
               │ Send notifications
               │ via HTTP v1 API
               │
┌──────────────┴──────────────┐
│     NestJS Backend          │
│                             │
│  - FCM HTTP v1 integration  │
│  - Google OAuth2            │
│  - REST API endpoints       │
└─────────────────────────────┘
```

## 🚀 Features

### Mobile App Features

- ✅ Firebase Cloud Messaging integration
- ✅ Foreground notification handling (in-app)
- ✅ Background/terminated notification handling
- ✅ Notification tap handling (app opened/launched)
- ✅ FCM token retrieval and management
- ✅ Token refresh handling
- ✅ Topic subscription/unsubscription
- ✅ Cross-platform support (Android, iOS, Web, Linux, macOS, Windows)

### Backend Features

- ✅ FCM HTTP v1 API integration
- ✅ Google OAuth2 authentication
- ✅ Send notifications to specific device tokens
- ✅ Send notifications to topics
- ✅ RESTful API endpoints
- ✅ TypeScript with NestJS framework
- ✅ Environment-based configuration

## 📂 Project Structure

```text
push-notifications-example/
├── push_notifications_mobile_app/    # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart                 # App entry point with FCM setup
│   │   └── firebase_options.dart     # Firebase configuration
│   ├── android/                      # Android-specific code
│   ├── ios/                          # iOS-specific code
│   └── pubspec.yaml                  # Flutter dependencies
│
└── push-notifications-backend/       # NestJS backend server
    ├── src/
    │   ├── fcm/                      # FCM module
    │   │   ├── fcm.controller.ts     # REST API endpoints
    │   │   ├── fcm.service.ts        # FCM business logic
    │   │   └── dto/                  # Data transfer objects
    │   └── main.ts                   # Server entry point
    ├── secrets/                      # Firebase service account keys (gitignored)
    └── package.json                  # Node.js dependencies
```

## 🛠️ Prerequisites

### For Mobile App

- Flutter SDK (3.4.1 or higher)
- Android Studio or Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
- A physical iOS device (simulator cannot receive push notifications)
- Firebase project with Cloud Messaging enabled

### For Backend

- Node.js (LTS version recommended)
- npm or yarn
- Firebase project with Cloud Messaging enabled
- Firebase service account key with appropriate permissions

### Common Requirements

- Firebase project (create one at [Firebase Console](https://console.firebase.google.com/))
- Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

## 📱 Getting Started

### 1. Firebase Setup

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Enable Firebase Cloud Messaging
3. Add Android and/or iOS apps to your Firebase project
4. Download configuration files:
   - `google-services.json` for Android → Place in `push_notifications_mobile_app/android/app/`
   - `GoogleService-Info.plist` for iOS → Place in `push_notifications_mobile_app/ios/Runner/`
5. Generate a service account key:
   - Go to Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save the JSON file in `push-notifications-backend/secrets/`

### 2. Mobile App Setup

```powershell
# Navigate to the mobile app directory
cd push_notifications_mobile_app

# Install dependencies
flutter pub get

# Configure FlutterFire (generates firebase_options.dart)
flutterfire configure

# Run on Android
flutter run

# Run on iOS (macOS only)
flutter run -d ios
```

For detailed mobile app setup instructions, see [`push_notifications_mobile_app/README.md`](./push_notifications_mobile_app/README.md)

### 3. Backend Setup

```powershell
# Navigate to the backend directory
cd push-notifications-backend

# Install dependencies
npm install

# Create a .env file with your configuration
# FIREBASE_PROJECT_ID=your-project-id
# GOOGLE_APPLICATION_CREDENTIALS=C:\full\path\to\secrets\your-service-account.json

# Start the development server
npm run start:dev

# The server will run on http://localhost:3000
```

For detailed backend setup instructions, see [`push-notifications-backend/README.md`](./push-notifications-backend/README.md)

## 📡 Sending Notifications

### Using the Backend API

Once both the mobile app and backend are running:

1. **Get the FCM token** from the mobile app (displayed in the app UI)
2. **Send a notification** using the backend API:

```powershell
# Send to a specific device token
curl -X POST http://localhost:3000/fcm/send `
  -H "Content-Type: application/json" `
  -d '{
    "token": "YOUR_DEVICE_FCM_TOKEN",
    "title": "Hello!",
    "body": "This is a test notification",
    "data": {
      "key1": "value1",
      "key2": "value2"
    }
  }'
```

### Testing Topic Notifications

1. **Subscribe to a topic** in the mobile app (e.g., "test")
2. **Send to the topic** from the backend:

```powershell
curl -X POST http://localhost:3000/fcm/send-topic `
  -H "Content-Type: application/json" `
  -d '{
    "topic": "test",
    "title": "Topic Notification",
    "body": "This goes to all subscribers"
  }'
```

## 🧪 Testing Scenarios

The mobile app demonstrates the following notification scenarios:

1. **Foreground** - App is open and active
2. **Background** - App is minimized but running
3. **Terminated** - App is completely closed
4. **Notification Tap** - User taps on a notification
5. **Initial Message** - App launched by tapping a notification while terminated

## 📚 Tech Stack

### Mobile App

- **Framework**: Flutter 3.4.1+
- **Language**: Dart
- **Firebase**: `firebase_core: ^4.1.1`, `firebase_messaging: ^16.0.2`
- **Platforms**: Android, iOS, Web, Linux, macOS, Windows

### Backend

- **Framework**: NestJS 10.x
- **Language**: TypeScript
- **Runtime**: Node.js
- **Key Libraries**:
  - `google-auth-library` - OAuth2 authentication
  - `axios` - HTTP client for FCM API calls
  - `@nestjs/config` - Environment configuration

## 🔒 Security Notes

- **Never commit** service account keys or credentials to version control
- The `secrets/` folder should be in `.gitignore`
- Use environment variables for sensitive configuration
- Validate all incoming requests on the backend
- Implement proper authentication/authorization for production use

## 📖 Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [NestJS Documentation](https://docs.nestjs.com/)
- [FCM HTTP v1 API Reference](https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages)

## 📝 License

This project is provided as-is for educational and reference purposes.

## 🤝 Contributing

This is an example project. Feel free to fork and modify it for your own use cases.

## 💡 Use Cases

This example can be adapted for:

- 📧 Real-time messaging apps
- 🛒 E-commerce order updates
- 📰 News and content updates
- 🎮 Gaming notifications
- 📱 Social media alerts
- 🚨 Alert and monitoring systems
- 📊 Business and productivity apps

---

**Happy coding!** 🚀
