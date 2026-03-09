# 🕵️‍♂️ PocketForensics

A professional mobile digital forensics tool designed for metadata extraction (EXIF) and digital evidence integrity verification through cryptographic hashing (SHA-256). All processing is performed 100% on-device to ensure privacy and maintain the chain of custody.

## ✨ Key Features
* **Integrity Analysis (SHA-256):** Generates unique digital signatures from raw file bytes to detect any unauthorized alterations.
* **EXIF Metadata Extraction:** Deep-scan of hidden information in images, including GPS coordinates, camera models, and original timestamps.
* **Secure Local Processing:** No internet connection required; files never leave the device, ensuring data sovereignty.
* **Forensic UI/UX:** Modern Dark Mode interface featuring glassmorphism effects and fluid animations for real-time status feedback.

## 📸 User Interface

<p align="center">
  <img src="screenshots/start_screen.png" width="300" alt="Start Screen">
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="screenshots/result_screen.png" width="300" alt="Analysis Results">
</p>

## 🛠️ Architecture & Tech Stack
This project is built with **Flutter & Dart**, adhering to Clean Architecture principles:
* **Feature-First Structure:** Highly decoupled modules including `scanner`, `report`, and `history`.
* **MVVM Pattern:** Strict separation between UI (Views/Animations) and state logic (ViewModels).
* **Core Packages:** `crypto` for hashing, `exif` for metadata extraction, and `image_picker` for evidence handling.

## 🚀 Getting Started
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` (Supports Android, iOS, and Web/Desktop for rapid debugging).