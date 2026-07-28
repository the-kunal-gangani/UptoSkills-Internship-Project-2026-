<div align="center">

# 🍼 TinySteps — Personal Daycare App

**In-Home Babysitting & Daycare Management Platform**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![GitHub](https://img.shields.io/badge/GitHub-Workflow-181717?logo=github)](https://github.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> Connecting parents, caregivers, and organisers — for professional in-home childcare.

</div>

---

## 📖 Table of Contents
- [About the Project](#-about-the-project)
- [Key Features](#-key-features-mvp)
- [Tech Stack](#-tech-stack)
- [Getting Started](#-getting-started)
- [Contributing Guidelines](#-contributing-guidelines)
- [Future Phases](#-future-phases)
- [License](#-license)

---

## 🌟 About the Project

**TinySteps** is a mobile-first personal daycare & babysitting management app for children aged **0–5 years**.

Unlike a nursery centre app, TinySteps is designed for **individual/private caregivers** who visit families at home. It gives:
- **Parents** a real-time window into their child's daily care.
- **Caregivers (Staff)** a simple tool to log attendance and activities from the parent's home.
- **Admins (Organisation Handlers)** full visibility to manage staff, parents, and children across all sessions.

### 🎯 Target Users
| Role | Description | App Capabilities |
|------|-------------|-----------------|
| **Admin** | Organisation handler | Approve staff, manage groups, view all activity & attendance. |
| **Staff / Caregiver** | Goes to parent's home for babysitting / daycare | Manually mark child check-in/out, log daily activities. |
| **Parent** | Engages the service for their child | View child's attendance, activity logs, and daily reports. |

---

## ✅ Key Features (MVP)

### 🔐 Authentication & Role-Based Access
- Secure Email/Password registration with mandatory email verification.
- Role routing: Parent → Parent Dashboard, Staff → Caregiver Dashboard, Admin → Admin Panel.
- Supabase Auth with secure role-gated navigation via referral codes.

### 👶 Child Digital Profiles
- Parents can add, edit, and view comprehensive child profiles.
- Track: Name, Date of Birth, Blood Type, Allergies, Medical Notes, Home Address.
- Photo upload via device camera or local gallery.

### ✅ Manual Attendance
- Caregivers manually mark each child as **Checked In** or **Checked Out** per session.
- Timestamped logs stored in real time — parents can see exact session times.
- Undo support for accidental markings.

### 📋 Daily Activity Logging
- Staff can log mood, sleep duration, meal notes, and caregiver observations per child.
- Parents view a timestamped activity feed from their child's day.

### 🎛️ Admin Control Panel
- Centralised dashboard: all staff, parents, and children in one place.
- Approve or reject staff account applications.
- Assign caregivers to child groups; track daily session summaries.

---

## 🛠️ Tech Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Frontend** | Flutter 3.x (Dart) | Cross-platform mobile app (Android & iOS). |
| **State Management** | Riverpod | Scalable, maintainable state across all roles. |
| **Backend & DB** | Supabase (PostgreSQL) | Managed relational database with Row Level Security. |
| **Storage** | Supabase Storage | Secure hosting for child photos and documents. |
| **Routing** | Go Router | Declarative routing with role-based navigation guards. |
| **Calendar** | table_calendar | Session scheduling and attendance calendar view. |

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install)
- Dart 3.x (included with Flutter)
- IDE: Android Studio, VS Code, or IntelliJ
- A [Supabase](https://supabase.com/) account (for backend environment setup)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/tinysteps-daycare.git
   cd tinysteps-daycare
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   cp .env.example .env
   ```
   *Open `.env` and add your Supabase credentials:*
   ```env
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```
   > ⚠️ **Note:** Ensure `.env` is listed in your `.gitignore` to prevent leaking secrets.

4. **Run the application**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing Guidelines

Contributions are what make this project grow. Any contributions are **greatly appreciated**.

1. **Fork the Project**

2. **Create your Feature Branch**
   ```bash
   git checkout -b feat/YourFeatureName
   ```

3. **Commit your Changes** (follow conventional commits)
   ```bash
   git commit -m "feat: add some feature"
   ```

4. **Push & Open a Pull Request**
   ```bash
   git push origin feat/YourFeatureName
   ```

> **Note:** Never hardcode credentials. Use `.env`. Ensure code passes `flutter analyze` before submitting a PR.

---

## 🔮 Future Phases

The following features are planned for upcoming releases:
- 🔔 Push notifications for session start/end and activity updates.
- 📊 Weekly/monthly child development reports for parents.
- 📅 Session booking & scheduling by parents.
- 🤝 In-app messaging between parents and caregivers.
- 🌡️ IoT environmental monitoring (room temperature, air quality).
- 🥗 AI-powered nutritional recommendations.

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.

---
<div align="center">
<b>Built with ❤️ by the TinySteps Development Team</b>
</div>


# passwords
  Parent side
     ashpecit628@gmail.com 
     1234567890

  Teachers side
     dongaonkarsandesh001@gmail.com
     11111111

  Admin
     sc884900@gmail.com 
     12345678