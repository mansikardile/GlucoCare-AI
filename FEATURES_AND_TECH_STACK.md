# 🩺 GlucoCare AI — Features & Tech Stack Documentation

> **Intelligent, Explainable & Senior-Centric Diabetes Management Platform**  
> *Engineered for Seniors (e.g., Rajesh Sharma, 67, Type-2 Diabetes) & Caregivers (Priya Sharma)*

---

## 🌟 1. Executive Summary & Product Vision

**GlucoCare AI** bridges the gap between complex diabetes biomarkers and senior-friendly daily actions. Rather than presenting seniors with overwhelming data charts, GlucoCare AI turns vital readings into **simple, explainable, and actionable steps**, while keeping family caregivers in the loop with live synchronized alerts.

### 📖 The Core Story & UX Flow
$$\text{Senior Opens App} \longrightarrow \text{Views Today's Tasks \& Glucose} \longrightarrow \text{Logs Glucose / Meds (1 Tap)} \longrightarrow \text{Asks AI About Food} \longrightarrow \text{AI Detects Health Patterns} \longrightarrow \text{Caregiver Alert Dispatched}$$

---

## 🛠️ 2. Comprehensive Tech Stack

| Layer | Technology / Package | Purpose & Justification |
| :--- | :--- | :--- |
| **Framework** | **Flutter 3.38+ / Dart 3.10+** | Cross-platform (Android, iOS, Windows Desktop, Web) with 60fps tactile animations |
| **Architecture & State** | **Provider Pattern (`ChangeNotifier`)** | Clean reactive state management, decoupling business logic from UI |
| **AI / LLM Engine** | **Google Gemini 1.5 Flash REST API** | Real-time generative reasoning, structured JSON outputs, and empathetic senior-tailored advice |
| **Data Visualization** | **`fl_chart` (v1.2.0)** | Smooth interactive line charts with target range shaded bands (90–140 mg/dL) and high-glucose markers |
| **Persistence & Database** | **`shared_preferences` + JSON Serializers** | Full offline persistence for glucose logs, medicine schedules, food queries, and caregiver alerts |
| **Typography & Styling** | **`google_fonts` (`Outfit`)** | High-contrast, senior-accessible typography with generous line-heights and touch targets (>48dp) |
| **Date & Time Formatting** | **`intl` (v0.20.3)** | Localized date parsing and human-readable timestamps (`Tuesday, 6 October`, `8:30 AM`) |
| **Identifier Generation** | **`uuid` (v4.6.0)** | Globally unique identifiers for clinical records, logs, and notification dispatches |
| **Networking** | **`http` (v1.6.0)** | Asynchronous HTTP communication with Gemini endpoints featuring timeout fallbacks |

---

## 📱 3. Complete Feature Breakdown (Tab by Tab)

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

### 1️⃣ 🏠 Home Screen (Senior Dashboard)
* **Senior Greeting Header**: Displays dynamic time-of-day greeting (`Good morning, Rajesh 👋`), current full date (`Tuesday, 6 October`), and connected caregiver status pill (`👩 Priya`).
* **Blood Sugar Hero Card**:
  - Displays latest glucose value (`128 mg/dL`) with color-coded status badge (`✓ Within your usual range`, `⚠️ Slightly Above Baseline`, or `🚨 High Spike`).
  - Context tag showing reading conditions (e.g. `• Fasting`, `• After Dinner`).
  - Large tactile **`[ ⊕ Log Reading ]`** button.
* **Today's Actionable Medication Card**:
  - Highlights the immediate next scheduled dose (`Metformin 500 mg · 9:00 AM`).
  - Large 1-tap **`[ ✓ Taken ]`** button (instantly updates adherence and celebrates completion).
  - 1-tap **`[ Later ]`** snooze button.
  - Converts into celebration card (*"🎉 All Medicines Taken!"*) when daily regimen is complete.
* **Next Meal Planning Card**:
  - Displays next meal window (`Breakfast · 9:30 AM`) with a direct **`Ask AI >`** shortcut to the Food Advisor.
* **AI Daily Insight Card**:
  - Highlights top detected patterns with direct tap-to-open explainability (`View AI Explanation & Why`).

---

### 2️⃣ 📊 Health Trends & Analytics Screen
* **Interactive 7-Day Glucose Chart**:
  - Built with `fl_chart` plotting readings across days.
  - Safe clinical target range band highlighted between **90 mg/dL and 140 mg/dL**.
  - Dot painters highlighting normal readings (Blue) and spike readings (Amber/Coral).
* **Summary Metric Triad**:
  - **7-Day Average**: Dynamic computation (e.g. `130 mg/dL`).
  - **Highest Reading**: Peak detection (e.g. `158 mg/dL`).
  - **Lowest Reading**: Safe boundary monitoring (e.g. `110 mg/dL`).
* **Medication Adherence Bar**:
  - Visual percentage progress bar (e.g., `90%` — `9 of 10 doses taken`).
  - Color thresholds (Green for $\ge 85\%$, Amber for $<85\%$).
* **Detected AI Pattern Banner**:
  - Amber warning banner for clinical patterns (`⚠️ Evening Glucose Trend Detected`).
  - Action button: **`[ See AI Explanation ]`** opening root-cause details.
* **Recent Readings Log History**:
  - Chronological list of logged checks with meal context tags, timestamps, notes, and compact clinical status badges (`✓ In Range`, `⚠️ Elevated`, `🚨 High`).

---

### 3️⃣ 🍎 AI Food Advisor (Hero Feature)
* **Real-time Google Gemini LLM Integration**:
  - Connects to Google Gemini 1.5 Flash to evaluate ANY meal (traditional Indian meals, street food, western dishes, fruits, sweets, beverages).
  - Prompts automatically inject patient context (Rajesh, age 67, Type 2 diabetes, vegetarian, current blood sugar `128 mg/dL`, missed medication flag).
* **Curated Offline Clinical Knowledge Base**:
  - Fallback database for 50+ dishes (Dosa, Mango, White Rice, Biryani, Roti, Idli, Dal Makhani, Gulab Jamun, Oats, Moong Dal Khichdi, Paneer Tikka, Samosa, Masala Chai, etc.).
* **Quick Suggestion Prompt Chips**:
  - 1-tap questions: `🥞 Can I eat dosa?`, `🥭 Can I eat mango?`, `🍚 How much rice?`, `🍛 Biryani?`, `🫓 Roti?`, `🍯 Gulab Jamun?`, `🥣 Oats?`, `☕ Chai?`.
* **Structured Clinical Response Card**:
  - **Visual Traffic-Light Badge**: 🟢 GOOD CHOICE / 🟡 HAVE WITH CARE / 🔴 CONSIDER AVOIDING.
  - **Recommended Senior Portion**: Exact portion control (e.g. `1–2 small dosa with generous sambar & vegetable chutney`).
  - **Why & Glycemic Breakdown**: Clear carbohydrate digestion impact.
  - **Personalized Clinical Impact**: Linked directly to recent blood sugar readings.
  - **💡 Healthier Swaps / Alternatives**: (e.g. `Vegetable Rava Dosa or Oats Dosa + green mint chutney`).
  - **`[ 🍽️ Add to Today's Meal ]` Button**: Adds meal to daily history and estimates post-prandial glucose impact.
* **Search History Log**:
  - Quick recall of previous food evaluations with compact verdict badges.

---

### 4️⃣ 💊 Medication Tracker Screen
* **Daily Schedule Breakdown**:
  - Segmented by time-of-day slots: 🌅 Morning, ☀️ Afternoon, 🌆 Evening, 🌙 Bedtime.
* **One-Tap Status Toggles**:
  - `✓ Taken`: Records completion with timestamp.
  - `Missed`: Flags dose for AI pattern engine.
  - `Undo`: Resets to pending status.
* **Weekly Adherence Progress Widget**:
  - Live recalculation of compliance percentage.
* **`[ + Add New Medicine ]` Modal**:
  - Add custom prescription with name, dosage strength, meal relation, and time slot.
* **Prescription Reference Regimen**:
  - Quick reference list of patient's prescribed routine (Metformin, Glimepiride, Atorvastatin).

---

### 5️⃣ 👨‍👩‍👧 Caregiver Mode & Senior Profile Screen
* **Senior vs Caregiver Mode Switcher**:
  - Toggle between **👴 Senior View** and **👩 Caregiver View**.
* **Live Remote Caregiver Dashboard (Priya Sharma)**:
  - Live synced health status snapshot of Rajesh.
  - Glucose status & 7-day adherence indicator.
  - Active Attention Alerts (e.g. `⚠️ Evening glucose trend detected`).
  - 1-tap **`[ Call Rajesh ]`** & **`[ Send Reminder ]`** actions.
  - Live Caregiver notifications feed with timestamps.
* **Explainable AI Root-Cause Sheet (`AIInsightSheet`)**:
  - **Title & Summary**: Pattern overview.
  - **WHY DID THIS HAPPEN?**: Multi-point root-cause analysis (e.g. *4 evening readings above baseline*, *Dinner delayed 45 minutes*, *Missed evening Metformin*).
  - **💡 RECOMMENDATIONS**: Actionable non-pharmacological steps (meal timing consistency, clinician consult).
  - **`[ Tell Caregiver (Priya Sharma) ]` Button**: Dispatches instant alert to caregiver.
  - Medical safety disclaimer (does not alter prescribed dosages).
* **Demo Scenario Switcher (1-Click Presets for Hackathon)**:
  - **Scenario 1 (Default PS Hero Flow)**: Evening rise (128 → 158 mg/dL), missed evening Metformin, AI root-cause insight, and caregiver alert.
  - **Scenario 2 (Post-Carb Spike)**: 194 mg/dL post-lunch spike after family feast (Biryani & Gulab Jamun).
  - **Scenario 3 (Stable Controlled Baseline)**: Ideal 104 mg/dL baseline, 100% adherence.
* **Live Gemini API Key Configuration Modal**:
  - In-app dialog to input/update Google Gemini API key or switch between live LLM and offline engine.
* **Emergency SOS Contact Card**:
  - Quick 1-tap emergency dispatch button linked to caregiver contact details.

---

### 6️⃣ 🩸 Log Glucose Stepper Modal (`LogGlucoseModal`)
* Senior-friendly large numeric stepper with `+` / `-` buttons and quick jump chips (`-10`, `-5`, `+5`, `+10`).
* Meal context selection chips (`Fasting`, `Before Breakfast`, `After Breakfast`, `Before Lunch`, `After Lunch`, `Before Dinner`, `After Dinner`, `Bedtime`, `Other`).
* Optional meal note text field.
* Animated checkmark confirmation screen upon saving.

---

## 🗂️ 4. Project Directory Structure

```
d:\hackathon\cortex\
├── lib\
│   ├── main.dart                          # App entry point, MultiProvider & MaterialApp
│   ├── theme\
│   │   └── app_theme.dart                 # High-contrast senior design tokens & typography
│   ├── models\
│   │   ├── user_profile.dart              # Senior profile & caregiver details
│   │   ├── glucose_reading.dart           # Glucose models, MealContext & ranges
│   │   ├── medication.dart                # Medication & daily logs
│   │   ├── food_query.dart                # AI Food Advisor response & verdict models
│   │   ├── health_insight.dart            # Explainable AI pattern model & recommendations
│   │   └── caregiver_alert.dart           # Caregiver notifications model
│   ├── services\
│   │   ├── ai_food_service.dart           # Gemini 1.5 Flash REST API + Offline clinical knowledge base
│   │   ├── pattern_detection_service.dart # Multi-factor health risk & pattern detection engine
│   │   └── database_service.dart          # Local database persistence & synthetic scenario seeders
│   ├── providers\
│   │   └── health_provider.dart           # Central ChangeNotifier managing reactive state
│   ├── screens\
│   │   ├── main_navigation_screen.dart    # 5-Tab bottom navigation controller
│   │   ├── home_screen.dart               # Tab 1: Senior Dashboard
│   │   ├── health_screen.dart             # Tab 2: Health Trends & 7-Day Chart
│   │   ├── food_advisor_screen.dart       # Tab 3: AI Food Advisor (Hero feature)
│   │   ├── medicine_screen.dart           # Tab 4: Medication Tracker & Adherence
│   │   └── profile_caregiver_screen.dart  # Tab 5: Profile, Caregiver Remote & Scenario Switcher
│   └── widgets\
│       ├── senior_card.dart               # Reusable tactile senior card
│       ├── status_badge.dart              # Adaptive clinical badge (normal & compact modes)
│       ├── log_glucose_modal.dart         # Large numeric glucose logging bottom sheet
│       ├── add_medication_modal.dart      # Schedule new medicine bottom sheet
│       └── ai_insight_sheet.dart          # Explainable "Why?" AI Insight bottom sheet
├── test\
│   └── widget_test.dart                   # Automated smoke and widget test suite
├── ps.md                                  # Original hackathon problem statement
├── FEATURES_AND_TECH_STACK.md             # Complete feature & architecture documentation
└── pubspec.yaml                           # Project dependencies and asset definitions
```

---

## 🧪 5. Testing & Verification Summary

| Test Suite / Tool | Command | Result |
| :--- | :--- | :--- |
| **Static Code Analyzer** | `flutter analyze --no-pub` | **0 issues found** (Clean) |
| **Widget & Smoke Tests** | `flutter test` | **All tests passed (100%)** |
| **Layout & Overflow** | Mobile Viewport Verification | **0 pixel overflows across all screens** |

---

## 🚀 6. How to Run the App

To run on any connected Android / iOS device, Windows Desktop, or Chrome:

```powershell
# Run on default connected device
flutter run

# Run on Chrome
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows
```
