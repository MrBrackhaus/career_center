# Changelog

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
