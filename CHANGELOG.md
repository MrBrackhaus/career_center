# Changelog

## [0.8.0] - 2026-09-18

### Added
- **Global Text Color Picker**: Added a full Material Color picker (`flutter_colorpicker`) to the Editor toolbar, allowing precise global text color selection across all CV and cover letter designs.
- **Massive Localization Expansion**: Added complete translations and localizations for 100 languages, including rare and fictional languages (Esperanto, Sindarin, Klingon).
- **Extensive Test Framework**: Integrated over 50 new Unit, Widget, and Integration tests. App is now protected by GitHub Actions CI/CD pipelines.
- **Mock Interviews (`ai_interview_service`)**: Drafted a new AI-powered interactive mock interview practice feature.
- **ICS Calendar Export**: You can now export application and interview dates as `.ics` files for Outlook or Google Calendar.
- **Magic Clipboard**: Added a smart clipboard service to auto-detect and paste relevant application information.
- **AI Email Extraction (`ai_email_extractor_service`)**: Integrated LLMs to parse and automatically categorize incoming HR emails.

### Changed
- **CV Editor Overhaul**: Completely modernized the CV editor. Dummy data is gone. The left sidebar now dynamically renders real database entries, while the right side updates the PDF in real-time.
- **Native Forms & Validation**: "Berufserfahrung" and "Ausbildung" now use native Flutter DatePickers. Inputs are validated before saving.
- **Edit Custom Sections**: Added the ability to edit existing custom sections ("Eigene Abschnitte") via a pencil icon instead of having to delete and recreate them.
- **Smart DIN 5008 Elements**: Header and footer toggles now intelligently hide themselves when editing the CV, and only appear in the Cover Letter mode.
- **Licensing Update**: Changed the project license from GPL to "All Rights Reserved" with updated legal attribution.
- **IMAP System Optimization**: Improved the email fetching and filtering logic (`imap_service.dart`) to robustly handle complex HR responses.

### Fixed
- **Margin Sliders**: Fixed a bug where page margin sliders in the editor did not update the PDF view.
- **Dark Mode Readability**: Fixed a contrast bug where text in the left sidebar was unreadable (black on dark grey) in Dark Mode.


## [0.7.4] - 2026-09-15

### Added
- **Headless InAppWebView Fallback**: Improved scraping reliability for JS-heavy job portals by falling back to a background headless browser when raw HTTP parsing fails.
- **English Stop Words**: Upgraded the local Machine Learning Model's TextPreprocessor to natively filter English stop words, drastically improving precision for English IT job postings.
- **AI Cover Letter Post-Processing**: Added a sanitization layer that automatically strips conversational boilerplate (e.g. "Here is your letter:") and markdown artifacts from AI outputs.
- **Automated Integration Tests**: Built an extensive suite of 15 automated UI workflows (`integration_test/workflows/`) for end-to-end quality assurance.

### Changed
- **ML Math Optimization**: Fixed a critical calculation logic bug in the Naive Bayes Classifier where TF-IDF weighting accidentally penalized rare keywords due to negative logarithms.
- **Extractor Logic Improvements**: Optimized regex patterns in `JobPostingExtractor` and `EmailResponseExtractor` for better detection of HR roles, phone numbers, and academic titles (Dr./Prof.). 
- **Spam Filter Enhancements**: Fixed a bug where emails containing the word "Bewerbung" were incorrectly classified as spam/advertising.

### Fixed
- **Database Migrations**: Hardened SQLite upgrade paths with comprehensive simulation tests simulating upgrades from v1 to v12 to guarantee zero data loss.
- **Auto-Updater Stability**: Improved network resilience so API rate-limits or temporary connection drops no longer cause app crashes.
