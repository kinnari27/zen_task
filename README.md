# 🧘 ZenTask — Mindful Productivity & Focus App

ZenTask is a premium, distraction-free productivity app designed to help you organize your tasks and maintain deep focus. Built with Flutter, it combines minimalist task management, a Pomodoro timer, integrated breathing guides, and calming ambient soundscapes to help you enter and stay in your **flow state**.

---

## ✨ Key Features

*   **🗂️ Mindful Task Stream**: Keep your daily tasks organized into distinct wellness and work categories:
    *   **Mind** 🧠 (Meditate, journal, reflect)
    *   **Work** 💼 (Professional duties, study sessions)
    *   **Health** 🍏 (Exercise, meals, self-care)
    *   **Personal** 👤 (Hobbies, chores, personal growth)
*   **⏱️ Breathing-Sync Pomodoro Timer**: A beautiful visual 25-minute Pomodoro timer that features a pulsing breathing guide (*Inhale • Exhale* micro-animations) to keep you grounded and reduce stress while working.
*   **🌧️ Calm Ambient Soundscapes**: Integrated ambient sounds to drown out distractions:
    *   *Zen Rain* 🌧️
    *   *Forest Echoes* 🌲
    *   *Tibetan Bowls* 🥣
    *   Fully integrated with the **System Audio Service** for background playback controls.
*   **📊 Progress Analytics & Balance Stats**:
    *   Visual progress indicators tracking task completions.
    *   An analytics dashboard demonstrating your focus balance across categories.
*   **💾 Local Storage**: Keep your data fully private and offline, persisted across app launches using `shared_preferences`.
*   **🎨 Premium HSL-Aligned Aesthetics**: A gorgeous dark theme styled in Obsidian Black (`#0F0F12`), Indigo (`#6366F1`) accents, and Mint Green (`#00F5D4`) highlights.

---

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev/) (SDK ^3.11.4)
*   **Theme**: Material 3 Design
*   **Audio Core**: `audio_service` & `audioplayers` for robust background audio play/pause states synced with the OS notification drawer.
*   **Storage**: `shared_preferences` for fast and lightweight data persistence.
*   **Utility & Date Parsing**: `intl` for clean date formatting.

---

## 🚀 Getting Started

### Prerequisites

Make sure you have Flutter installed on your system. To verify your installation, run:
```bash
flutter doctor
```

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/zen_task.git
   cd zen_task
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Launcher Icons** (Optional, if editing asset configurations):
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Launch the application**:
   ```bash
   flutter run
   ```

---

## 📐 Project Structure

```text
lib/
├── main.dart             # Application entry point and Theme configuration
├── models/
│   ├── focus_session.dart# Focus duration and stats models
│   └── task.dart         # Task priority and completion models
├── screens/
│   ├── home_screen.dart  # Core dashboard showing tasks, progress, & category filters
│   └── timer_screen.dart # Focus timer screen with ambient sounds & breathing guide
├── services/
│   ├── audio_handler.dart# System-level audio handler and state synchronization
│   └── storage_service.dart# SharedPreferences persistent task & session loader
└── widgets/              # Reusable UI cards, category chips, tiles, and sheets
```
