# 🩺 GlucoCare AI
### *Explainable & Senior-Centric Diabetes Management Platform with Live Gemini LLM*

[![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![AI Engine](https://img.shields.io/badge/AI-Google%20Gemini%201.5%20Flash-4285F4?logo=google&logoColor=white)](https://ai.google.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> **"The goal isn't to make seniors understand complicated diabetes data.**  
> **The goal is to turn that data into simple actions they can understand and follow."**

---

## 🌟 Executive Summary

**GlucoCare AI** is an intelligent, senior-accessible diabetes management application engineered for elderly patients (e.g., **Rajesh Sharma, 67, Type-2 Diabetes**) and their family caregivers (**Priya Sharma**).

Instead of overwhelming seniors with confusing spreadsheets and clinical jargon, GlucoCare AI combines **1-tap glucose and medication tracking**, **explainable AI pattern detection**, a **conversational AI Food Advisor powered by Google Gemini 1.5 Flash**, and a **live remote Caregiver Dashboard**.

---

## 📱 Core Product Experience (5 Navigation Tabs)

```
┌─────────────────────────────────────────────────────────┐
│                      GlucoCare AI                       │
├─────────────────────────────────────────────────────────┤
│  🏠 Home      │ Senior Dashboard: Blood Sugar, Next     │
│               │ Meds, Next Meal & AI Today's Insight    │
├───────────────┼─────────────────────────────────────────┤
│  📊 Health    │ 7-Day Glucose Charts, Averages, Range   │
│               │ Distribution & AI Pattern Detection     │
├───────────────┼─────────────────────────────────────────┤
│  🍎 Food AI   │ Hero Feature: Food Advisor with traffic │
│  (Hero)       │ light verdicts, portion advice & swaps  │
├───────────────┼─────────────────────────────────────────┤
│  💊 Medicine  │ Daily schedule, one-tap 'Taken' logs &  │
│               │ weekly adherence percentage             │
├───────────────┼─────────────────────────────────────────┤
│  👤 Caregiver │ Senior profile, Caregiver Remote View,  │
│    & Profile  │ Alert dispatch & Demo Scenario switcher │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Key Features

### 1. 🏠 Senior Home Dashboard
- **Senior Greeting**: Large dynamic greeting and high-visibility date display (`Good morning, Rajesh 👋`).
- **Blood Sugar Hero Card**: Displays latest reading (`128 mg/dL`), status badge (`✓ Within your usual range`), meal context (`• Fasting`), and large `[ Log Reading ]` button.
- **Actionable Medication Card**: Highlights next scheduled dose (`Metformin 500 mg · 9:00 AM`) with 1-tap `[ ✓ Taken ]` or `[ Later ]`.
- **Next Meal Planner**: Displays upcoming meal schedule with quick shortcut to the Food AI.
- **AI Daily Insight**: Highlights active health patterns with instant root-cause explanation.

### 2. 📊 Health Trends & Analytics
- **Interactive 7-Day Glucose Chart**: Built with `fl_chart` with target zone shading (90–140 mg/dL) and spike markers.
- **Metric Triad**: Real-time calculated **7-Day Average**, **Highest**, and **Lowest** glucose values.
- **Medication Adherence Bar**: Color-coded progress bar (e.g. 90% adherence).
- **Detected AI Pattern Banner**: Highlights detected anomalies (e.g. `⚠️ Evening Glucose Trend Detected`) with tap-to-explain.
- **Recent Readings Log**: Chronological log of recent checks with compact status pills.

### 3. 🍎 AI Food Advisor *(Hero Feature)*
- **Live Google Gemini 1.5 Flash LLM**: Ask any natural-language food question (e.g., *"Can I eat 2 dosas with sambar?"*, *"How much rice can I eat?"*, *"Can I have mango?"*).
- **Patient Context Injection**: Automatically injects patient profile (age 67, Type 2 diabetes, vegetarian, current blood sugar `128 mg/dL`, missed medication flags).
- **Structured Traffic-Light Verdicts**:
  - 🟢 **GOOD CHOICE**: Safe for regular senior portions.
  - 🟡 **HAVE WITH CARE**: Portion control and vegetable pairing required.
  - 🔴 **CONSIDER AVOIDING**: High glycemic spike risk.
- **Senior Portion Advice**: Concrete serving measurements (e.g., `1–2 small dosa with generous sambar`).
- **Explainable Reasoning**: Clear breakdown of carbohydrate absorption and glucose impact.
- **💡 Healthier Swaps**: Suggests alternatives like Vegetable Oats Dosa or Multigrain Roti.
- **`[ Add to Today's Meal ]`**: 1-tap logging into daily history with simulated post-meal tracking.

### 4. 💊 Medication Tracker
- **Daily Slot Schedule**: Categorized by Morning, Afternoon, Evening, and Night.
- **1-Tap Compliance**: Update status with `✓ Taken`, `Missed`, or `Undo`.
- **Custom Prescriptions**: Bottom sheet modal to add custom medications and instructions.

### 5. 👨‍👩‍👧 Caregiver Remote Dashboard & Demo Presets
- **Caregiver Mode Switcher**: View the app from daughter Priya Sharma's perspective.
- **Live Synced Snapshot**: Real-time glucose, 90% adherence rate, and active risk alerts.
- **Action Triggers**: 1-tap `[ Call Rajesh ]` and `[ Send Reminder ]`.
- **Explainable Root-Cause Sheet**:
  - Breakdown of **"WHY DID THIS HAPPEN?"** (4 evening spikes, delayed dinner, missed Metformin).
  - Actionable non-pharmacological recommendations.
  - **`[ Tell Caregiver ]`** button to dispatch immediate push notifications.
- **1-Click Demo Scenario Switcher** (Ideal for Judges & Testing):
  - **Scenario 1**: Evening Rise + Missed Metformin *(Default PS Demo Flow)*.
  - **Scenario 2**: Post-Carb Spike (194 mg/dL after family celebration meal).
  - **Scenario 3**: Stable Baseline (104 mg/dL with 100% adherence).
- **In-App Gemini API Key Config**: Input custom Google AI API keys or use default.
- **Emergency SOS Card**: One-touch caregiver alert dispatcher.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | **Flutter 3.38+ / Dart 3.10+** | Cross-platform mobile, desktop, and web frontend |
| **State Management** | **Provider (`ChangeNotifier`)** | Reactive state architecture |
| **AI / LLM** | **Google Gemini 1.5 Flash REST API** | Real-time clinical dietary reasoning |
| **Charts** | **`fl_chart`** | Interactive glucose trend lines & target range bands |
| **Local Storage** | **`shared_preferences` + JSON** | Offline database persistence across app restarts |
| **Design & Typography** | **`google_fonts` (`Outfit`)** | Senior-accessible high-contrast theme & large typography |
| **Utilities** | **`intl` & `uuid`** | Date formatting and unique record IDs |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Root app entry point & theme initialization
├── theme/
│   └── app_theme.dart                 # High-contrast senior design tokens
├── models/
│   ├── user_profile.dart              # Senior profile & caregiver metadata
│   ├── glucose_reading.dart           # Glucose logs & clinical range enums
│   ├── medication.dart                # Prescription & daily dose logs
│   ├── food_query.dart                # AI Food Advisor response models
│   ├── health_insight.dart            # Explainable AI pattern models
│   └── caregiver_alert.dart           # Caregiver notifications model
├── services/
│   ├── ai_food_service.dart           # Gemini 1.5 Flash API + Offline fallback engine
│   ├── pattern_detection_service.dart # Multi-factor clinical pattern detector
│   └── database_service.dart          # Local storage persistence & demo scenarios
├── providers/
│   └── health_provider.dart           # Central reactive state manager
├── screens/
│   ├── main_navigation_screen.dart    # 5-Tab bottom navigation controller
│   ├── home_screen.dart               # 1️⃣ Senior Dashboard
│   ├── health_screen.dart             # 2️⃣ Health Trends & 7-Day Chart
│   ├── food_advisor_screen.dart       # 3️⃣ AI Food Advisor
│   ├── medicine_screen.dart           # 4️⃣ Medication Tracker & Adherence
│   └── profile_caregiver_screen.dart  # 5️⃣ Caregiver Mode & Scenario Switcher
└── widgets/
    ├── senior_card.dart               # Tactile senior card wrapper
    ├── status_badge.dart              # Adaptive clinical status pill
    ├── log_glucose_modal.dart         # Numeric glucose stepper modal
    ├── add_medication_modal.dart      # Add prescription bottom sheet
    └── ai_insight_sheet.dart          # Explainable "Why?" bottom sheet
```

---

## ⚡ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) ($\ge 3.24.0$)
- [Dart SDK](https://dart.dev/get-dart) ($\ge 3.5.0$)

### Installation
```bash
# Clone the repository
git clone https://github.com/mansikardile/GlucoCare-AI.git
cd GlucoCare-AI

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

### Running Tests & Static Analysis
```bash
# Run automated widget & smoke tests
flutter test

# Run static code analysis
flutter analyze
```

---

## 📄 Documentation
For the complete technical specifications and problem statement breakdown, see [FEATURES_AND_TECH_STACK.md](FEATURES_AND_TECH_STACK.md) and [ps.md](ps.md).
