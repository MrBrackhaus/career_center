# Changelog

## [0.9.1] - 2026-10-01

### Fixed (critical)
- Weekly goal <= 0 caused an infinite loop on the UI isolate (app hung on every start); goal is now validated (1–100) and clamped.
- Calendar crashed from 2027-01-01 (hard-coded `lastDay`); now localized and starting on Monday.
- SMTP: STARTTLS enforced on non-465 ports, auth mechanism negotiated, HTML body escaped.
- Windows single-instance guard (named mutex + `AppMutex`); app restarts after silent auto-update.

### Fixed (data loss)
- Editor: template autosave no longer inserts duplicates; pending edits flushed on close; revision-based dirty tracking; save errors surfaced.
- CV profile and letter header fields persisted (`applications.cvContent` JSON / settings).
- Templates: partial updates keep `applicationId`, `filePath`, `createdAt`; delete asks for confirmation and removes the copied PDF.
- Application form: file drops only extract on the basic-data tab and ask before overwriting; custom fields merged; unsaved-changes prompt; Ctrl+S on any tab.
- Kanban drag, e-mail composer and AI cover letter use partial updates instead of full-row rewrites.
- Legacy status values normalized (schema v15 migration + on read).

### Jobcenter report & PDFs
- Date range, only sent applications, sorted; honest follow-up and channel columns; no placeholders.
- Bundled Noto Sans (OFL) for Unicode PDF output; CV and cover-letter PDF export implemented.

### Backup & privacy
- Recovery key display; import of backups encrypted with another key; key-loss guard renames the unreadable DB instead of overwriting.
- Documents stored in the app support directory; files deleted with their records.
- Removed Clearbit logo requests; feedback dialog privacy notice, limits and timeouts.

### Extraction
- Job pages classified on visible text; URL imports are always job postings (fixes raw HTML in fields with the synthetic model).
- Fixed quadratic title/e-mail regexes, case-insensitive legal-form/contact regexes, JSON-LD salary, phone/address/date parsing, interview detection, ICS escaping/folding/UIDs, CSV injection guard, keyword tokenizer, ML stop words and online pruning.
- Unique index on `emails(application_id, message_id)` with duplicate cleanup.

### Tests & CI
- Integration tests run against an in-memory database via a shared harness (no more access to the real user database); removed data-wiping and assertion-free tests.
- Re-enabled localization integrity test; removed a test that only tested its own reimplementation; ~30 new regression tests.
- CI: secret injected via env, release tag must match pubspec version, nightly concurrency group.

## [0.9.0] - 2026-10-01

### Security & Privacy
- **Database encryption actually enabled**: SQLCipher is now bundled via the `sqlite3` build hook (`hooks: user_defines: sqlite3: source: sqlcipher`). Before, the EOL `sqlcipher_flutter_libs` package did nothing and `PRAGMA key` was ignored, so databases were stored unencrypted. Existing databases are migrated on first start with a verified backup.
- **Companion token pairing**: `/api/status` no longer leaks the API token. The token is shown in the settings and entered once in the browser extension (v1.2.0). Token comparison is constant-time.
- **AI API key in secure storage**: moved out of the settings table (automatic migration).
- **AI endpoint selection by URL only**: keys starting with `sk-` no longer redirect requests (and the key) to api.openai.com.
- **MCP**: `get_user_profile` returns only an allowlist of profile fields; proper JSON-RPC errors.
- **Personal data removed** from editor defaults and the ML training data; legacy model files are deleted.
- **Updater integrity**: downloads are verified against the SHA-256 digest of the GitHub release asset.

### Fixed
- Statuses are normalized (`bestaetigung` → `versendet`, `angebot` → `zusage`), so applications no longer disappear from the Kanban board.
- Updating an application no longer resets its priority (partial update instead of `replace`).
- IMAP: original-case mail bodies, Message-ID de-duplication, better Sent-folder detection, STARTTLS on port 143, no leaked connections.
- Settings: "last sync" display, consistent backup export (`VACUUM INTO`), validated backup import.
- Double-encoded umlauts in the job-posting extractor and application form (broken regexes and UI text).
- ISO week calculation for the weekly streak (year boundaries, DST).
- Mock interview now includes the cover letter; bold text in AI cover letters is kept.
- Learned ML corrections are no longer deleted on every start.
- Auto-updater uses a UTF-8 PowerShell script (paths with umlauts/apostrophes) and closes the database before exiting.
- Browser extension autofill: textarea crash, password/company/username false matches, date fields, oversized payloads.

### Changed
- License headers updated to "All rights reserved" (consistent with README).
- Added `lib/core/secrets.example.dart` and build instructions.

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
