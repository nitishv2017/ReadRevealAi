# read_reveal_ai
Here's a high-level `task.md` file for the **ReadRevealAi** app. This file outlines the major tasks and milestones needed to build the app in a structured, modular way.

---

### 📄 `task.md` – ReadRevealAi PRD Tasks

---

## 📘 Overview

**App Name**: ReadRevealAi
**Purpose**: A minimal offline-first mobile app that allows users to capture book pages and get word explanations via Gemini API, with local history and API key management.

---

## 🗂️ Pages & Features

### 1. 📷 Camera Page

* [ ] Integrate device camera using `image_picker` or `camera` package
* [ ] Add capture button
* [ ] On image capture:

  * [ ] Convert image to base64
  * [ ] Send image and prompt to Gemini API
  * [ ] Display explanations in a draggable bottom sheet
* [ ] Allow user to save the result in local history

### 2. ⚙️ Settings Page

* [ ] Create input form for Gemini API key
* [ ] Store API key securely using `flutter_secure_storage`
* [ ] Add validation to ensure the key is stored before any request is made

### 3. 🕘 History Page

* [ ] Use `hive` or `sqflite` for local database
* [ ] Save each scanned entry:

  * image path
  * explanation response
  * timestamp
* [ ] Display scrollable list of history items

  * [ ] Thumbnail + summary text
  * [ ] On tap: show full explanation
  * [ ] Delete option for individual entries

---

## 📦 Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── camera_screen.dart
│   ├── settings_screen.dart
│   └── history_screen.dart
├── widgets/
│   ├── bottom_result_sheet.dart
├── services/
│   ├── gemini_service.dart
│   ├── storage_service.dart
├── models/
│   └── history_entry.dart
```

---

## 🔐 Security

* [ ] Never hardcode API key
* [ ] Store securely using `flutter_secure_storage`
* [ ] Validate key before sending requests

---

## 🚀 Milestones

| Milestone          | Description                            | Status |
| ------------------ | -------------------------------------- | ------ |
| Project Setup      | Flutter init, dependencies             | ☐      |
| Camera Integration | Image capture                          | ☐      |
| Gemini API Call    | Image + prompt => explanation          | ☐      |
| Bottom Sheet UI    | Display explanation                    | ☐      |
| Settings Page      | Input and store API key                | ☐      |
| History Storage    | Save and list previous captures        | ☐      |
| Final UI Polish    | Styling, dark mode, edge case handling | ☐      |
| Testing & QA       | Manual testing on Android & iOS        | ☐      |

---

## 📱 Tech Stack

* Flutter (Dart)
* Packages:

  * `camera` or `image_picker`
  * `flutter_secure_storage`
  * `hive` or `sqflite`
  * `http`
  * `path_provider`

---

## 📤 Gemini API (example usage)

**Prompt:**

> "Explain the difficult words in this image. Provide only concise word-level explanations."

**Expected Response:**

```json
{
  "words": [
    {"word": "ineffable", "meaning": "too great to be expressed in words"},
    {"word": "lucid", "meaning": "clearly expressed"}
  ]
}
```

---

Let me know if you'd like a GitHub README version of this or a Notion-compatible version.

