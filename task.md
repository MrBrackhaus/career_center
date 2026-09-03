# JobTracker Redesign & Phase 2 Tasks

- [x] **1. Dependencies & Setup**
  - [x] Add `flutter_quill` to `pubspec.yaml`
  - [x] Add `html` (or `metadata_fetch`) to `pubspec.yaml`
  - [x] Run `flutter pub get`

- [x] **2. Database & Models**
  - [x] Update `Applications` table in `lib/data/database/app_database.dart` to include `customFields`
  - [x] Run `flutter pub run build_runner build`

- [x] **3. Navigation & Main Screen**
  - [x] Update `lib/presentation/screens/main_screen.dart` to use Top Navigation/Tab Bar
  - [x] Wire up new screens to tabs

- [x] **4. Dynamic Columns & Profile Presets**
  - [x] Implement UI in `SettingsScreen` to choose profession preset and edit active columns
  - [x] Add presets logic (IT, Handwerk, etc.)

- [x] **5. Profi-Übersicht (Dashboard/List)**
  - [x] Redesign `applications_screen.dart` into a data table layout
  - [x] Integrate rendering of dynamic `customFields` columns

- [x] **6. Application Form & Magic Auto-Fill**
  - [x] Add dynamic fields rendering to `application_form_screen.dart` based on active columns
  - [x] Add "Magic Auto-Fill" URL input and `html` fetching logic

- [x] **7. Wochenbericht (Weekly Report)**
  - [x] Create `weekly_report_screen.dart`
  - [x] Implement progress bar, motivational text, and comparison logic

- [x] **8. Templates & Editor**
  - [x] Create `templates_screen.dart` (List of templates, Prompt Generator UI)
  - [x] Create `template_editor_screen.dart` using `flutter_quill` (plain text MVP)

- [x] **9. Statistiken & Reports**
  - [x] Update `dashboard_screen.dart` to match "Statistiken" UI (BarChart, Top Rejections)
  - [x] Create `jobcenter_report_screen.dart` preview and PDF generation button
