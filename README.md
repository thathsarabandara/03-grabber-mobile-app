# 📱 Grabber Mobile App

> **Repository `03`** · Flutter cross-platform mobile application for remote control, live monitoring, and camera viewing of the Grabber robotic arm.

[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue)]()
[![Language](https://img.shields.io/badge/Language-Dart-informational)]()
[![Framework](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter)]()
[![Protocol](https://img.shields.io/badge/Protocol-MQTT%20%7C%20WebSocket-green)]()
[![Status](https://img.shields.io/badge/Status-Stage%204%20Planned-yellow)]()

---

## 🧭 What Is This Repository?

This is the **Flutter mobile application** that lets users remotely control, monitor, and interact with their Grabber robotic arm from any iOS or Android device. It communicates with the backend through the API Gateway over REST and WebSocket.

Key capabilities:
- Authenticate and pair with a physical robot using a serial key
- Control all 4 joints via touch sliders and a virtual joystick
- Watch the live camera feed in real time
- Receive push notifications for errors, disconnections, and task completion

---

## 📦 Module Structure

```
03-grabber-mobile-app/
├── lib/
│   ├── auth/              ← Login, register, robot pairing via serial key
│   ├── control/           ← Touch-based joint sliders, virtual joystick
│   ├── monitoring/        ← Live telemetry cards, connection status
│   ├── camera/            ← Live stream viewer, snapshot gallery
│   └── notifications/     ← Push alerts for errors, disconnections, task completion
├── assets/                ← Icons, images, fonts
├── pubspec.yaml           ← Flutter dependencies
└── README.md
```

---

## 🖼️ Screen Overview

| Screen | Description |
|---|---|
| **Login / Register** | Email + password authentication, JWT session management |
| **Robot Pairing** | Enter serial key to bind a physical robot to your account |
| **Control Panel** | Joint sliders (J1–J4), speed selector, mode switcher |
| **Virtual Joystick** | On-screen analog joystick for intuitive arm movement |
| **Telemetry Dashboard** | Live cards: joint angles, voltage, temperature, connection state |
| **Camera Viewer** | Full-screen MJPEG live stream with snapshot button |
| **Snapshot Gallery** | Browse, view, and share previously captured images |
| **Notifications** | In-app and push alerts for robot events |

---

## 🔌 Backend Integration

| Service | Method | Purpose |
|---|---|---|
| `06-auth-service` | REST (via Gateway) | Login, register, token refresh |
| `07-robot-service` | REST (via Gateway) | Send joint commands, mode control |
| `08-telemetry-service` | WebSocket | Live telemetry streaming |
| `08-telemetry-service` | MJPEG (via Gateway) | Live camera feed |

All requests are routed through **`05-grabber-api-gateway`** — the app never calls backend services directly.

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.x
- Dart ≥ 3.x
- Android Studio / Xcode for device deployment
- A running Grabber backend stack (see [`10-grabber-devops-infras`](https://github.com/thathsarabandara/10-grabber-devops-infras))

### Setup

```bash
# Clone the repo
git clone https://github.com/thathsarabandara/03-grabber-mobile-app.git
cd 03-grabber-mobile-app

# Install dependencies
flutter pub get

# Configure the API gateway URL
# Edit lib/config/env.dart
```

```dart
// lib/config/env.dart
const String apiBaseUrl = 'https://your-gateway-url';
const String wsBaseUrl  = 'wss://your-gateway-url';
```

### Run

```bash
# Run on connected device or emulator
flutter run

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

---

## 📈 Feature Roadmap

| # | Feature | Stage | Status |
|---|---|---|---|
| F15 | Mobile App Control | 🟣 4 | Planned |
| F10 | Live Camera Feed | 🔵 3 | Planned |
| F12 | Snapshot Capture | 🔵 3 | Planned |
| F16 | Multi-User View Mode | 🟣 4 | Planned |

---

## 🔗 Related Repositories

| Repo | Role |
|---|---|
| [`01-grabber-architecture`](https://github.com/thathsarabandara/01-grabber-architecture) | System architecture and API contracts |
| [`05-grabber-api-gateway`](https://github.com/thathsarabandara/05-grabber-api-gateway) | All app traffic enters here |
| [`06-grabber-auth-service`](https://github.com/thathsarabandara/06-grabber-auth-service) | Auth backend |
| [`07-grabber-robot-service`](https://github.com/thathsarabandara/07-grabber-robot-service) | Command backend |
| [`08-grabber-telemetry-service`](https://github.com/thathsarabandara/08-grabber-telemetry-service) | Telemetry + camera stream |

---

<div align="center">
  <sub>Part of the <strong>Grabber</strong> AI-Powered Industrial Robotic Arm Platform</sub>
</div>
