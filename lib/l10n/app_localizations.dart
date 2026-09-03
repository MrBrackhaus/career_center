import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In de, this message translates to:
  /// **'Bewerbungszentrale'**
  String get appName;

  /// No description provided for @navDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navApplications.
  ///
  /// In de, this message translates to:
  /// **'Bewerbungen'**
  String get navApplications;

  /// No description provided for @navCalendar.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get navCalendar;

  /// No description provided for @navTemplates.
  ///
  /// In de, this message translates to:
  /// **'Vorlagen'**
  String get navTemplates;

  /// No description provided for @navSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get navSettings;

  /// No description provided for @applicationsTitle.
  ///
  /// In de, this message translates to:
  /// **'Meine Bewerbungen'**
  String get applicationsTitle;

  /// No description provided for @btnNewApplication.
  ///
  /// In de, this message translates to:
  /// **'Neue Bewerbung'**
  String get btnNewApplication;

  /// No description provided for @statusOpen.
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get statusOpen;

  /// No description provided for @statusSent.
  ///
  /// In de, this message translates to:
  /// **'Versendet'**
  String get statusSent;

  /// No description provided for @statusInterview.
  ///
  /// In de, this message translates to:
  /// **'Interview'**
  String get statusInterview;

  /// No description provided for @statusAccepted.
  ///
  /// In de, this message translates to:
  /// **'Zusage'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In de, this message translates to:
  /// **'Absage'**
  String get statusRejected;

  /// No description provided for @kanbanPreparation.
  ///
  /// In de, this message translates to:
  /// **'📝 In Vorbereitung'**
  String get kanbanPreparation;

  /// No description provided for @kanbanWaiting.
  ///
  /// In de, this message translates to:
  /// **'⏳ Warten auf Antwort'**
  String get kanbanWaiting;

  /// No description provided for @kanbanInterview.
  ///
  /// In de, this message translates to:
  /// **'🗣️ Im Gespräch'**
  String get kanbanInterview;

  /// No description provided for @kanbanOffers.
  ///
  /// In de, this message translates to:
  /// **'🎉 Angebote'**
  String get kanbanOffers;

  /// No description provided for @kanbanArchive.
  ///
  /// In de, this message translates to:
  /// **'🗑️ Archiv (Absagen)'**
  String get kanbanArchive;

  /// No description provided for @searchPlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Firma, Position, Ort...'**
  String get searchPlaceholder;

  /// No description provided for @emptyApplicationsTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Bewerbungen'**
  String get emptyApplicationsTitle;

  /// No description provided for @emptyApplicationsDesc.
  ///
  /// In de, this message translates to:
  /// **'Es sieht so aus, als hättest du noch keine Bewerbungen hinzugefügt. Klicke auf \'Neue Bewerbung\', um loszulegen!'**
  String get emptyApplicationsDesc;

  /// No description provided for @dashboardTitle.
  ///
  /// In de, this message translates to:
  /// **'Bewerbungs-Statistiken'**
  String get dashboardTitle;

  /// No description provided for @dashboardOverview.
  ///
  /// In de, this message translates to:
  /// **'ÜBERBLICK'**
  String get dashboardOverview;

  /// No description provided for @dashboardApplications.
  ///
  /// In de, this message translates to:
  /// **'BEWERBUNGEN'**
  String get dashboardApplications;

  /// No description provided for @dashboardOpen.
  ///
  /// In de, this message translates to:
  /// **'NOCH OFFEN'**
  String get dashboardOpen;

  /// No description provided for @dashboardRejections.
  ///
  /// In de, this message translates to:
  /// **'ABSAGEN'**
  String get dashboardRejections;

  /// No description provided for @dashboardResponseRate.
  ///
  /// In de, this message translates to:
  /// **'ANTWORTQUOTE'**
  String get dashboardResponseRate;

  /// No description provided for @dashboardRejectionRate.
  ///
  /// In de, this message translates to:
  /// **'ABSAGEQUOTE'**
  String get dashboardRejectionRate;

  /// No description provided for @dashboardInterviews.
  ///
  /// In de, this message translates to:
  /// **'INTERVIEWS'**
  String get dashboardInterviews;

  /// No description provided for @dashboardCommute.
  ///
  /// In de, this message translates to:
  /// **'Ø PENDELZEIT'**
  String get dashboardCommute;

  /// No description provided for @dashboardAppsPerMonth.
  ///
  /// In de, this message translates to:
  /// **'BEWERBUNGEN PRO MONAT'**
  String get dashboardAppsPerMonth;

  /// No description provided for @dashboardTopRejectionReasons.
  ///
  /// In de, this message translates to:
  /// **'TOP ABSAGEGRÜNDE'**
  String get dashboardTopRejectionReasons;

  /// No description provided for @dashboardNoRejectionReasons.
  ///
  /// In de, this message translates to:
  /// **'Bisher keine Absagegründe erfasst.'**
  String get dashboardNoRejectionReasons;

  /// No description provided for @calendarTitle.
  ///
  /// In de, this message translates to:
  /// **'Bewerbungskalender'**
  String get calendarTitle;

  /// No description provided for @calendarNoEvents.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine an diesem Tag.'**
  String get calendarNoEvents;

  /// No description provided for @templatesTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorlagen & Anschreiben'**
  String get templatesTitle;

  /// No description provided for @templatesNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Vorlage'**
  String get templatesNew;

  /// No description provided for @templatesEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Vorlagen erstellt.'**
  String get templatesEmpty;

  /// No description provided for @templatesCreateFirst.
  ///
  /// In de, this message translates to:
  /// **'Erstelle Dein erstes Anschreiben oder einen Textbaustein!'**
  String get templatesCreateFirst;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache / Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In de, this message translates to:
  /// **'Design-Modus'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In de, this message translates to:
  /// **'System-Standard'**
  String get settingsThemeSystem;

  /// No description provided for @settingsPreset.
  ///
  /// In de, this message translates to:
  /// **'Preset-Theme'**
  String get settingsPreset;

  /// No description provided for @settingsAccentColor.
  ///
  /// In de, this message translates to:
  /// **'Akzentfarbe'**
  String get settingsAccentColor;

  /// No description provided for @settingsJobcenterMode.
  ///
  /// In de, this message translates to:
  /// **'Jobcenter / Arbeitsamt-Modus'**
  String get settingsJobcenterMode;

  /// No description provided for @reportTitle.
  ///
  /// In de, this message translates to:
  /// **'Nachweis Eigenbemühungen'**
  String get reportTitle;

  /// No description provided for @reportSavePdf.
  ///
  /// In de, this message translates to:
  /// **'PDF Speichern'**
  String get reportSavePdf;

  /// No description provided for @reportDate.
  ///
  /// In de, this message translates to:
  /// **'BEWERBUNGSDATUM'**
  String get reportDate;

  /// No description provided for @reportCompany.
  ///
  /// In de, this message translates to:
  /// **'UNTERNEHMEN'**
  String get reportCompany;

  /// No description provided for @reportPosition.
  ///
  /// In de, this message translates to:
  /// **'POSITION'**
  String get reportPosition;

  /// No description provided for @reportStatus.
  ///
  /// In de, this message translates to:
  /// **'STATUS'**
  String get reportStatus;

  /// No description provided for @reportRejectionReason.
  ///
  /// In de, this message translates to:
  /// **'ABSAGEGRUND'**
  String get reportRejectionReason;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache / Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsAppLanguage.
  ///
  /// In de, this message translates to:
  /// **'App Sprache'**
  String get settingsAppLanguage;

  /// No description provided for @settingsDesignTitle.
  ///
  /// In de, this message translates to:
  /// **'Design & Personalisierung'**
  String get settingsDesignTitle;

  /// No description provided for @settingsDesignMode.
  ///
  /// In de, this message translates to:
  /// **'Design Modus'**
  String get settingsDesignMode;

  /// No description provided for @settingsAccentColorTitle.
  ///
  /// In de, this message translates to:
  /// **'Akzentfarbe'**
  String get settingsAccentColorTitle;

  /// No description provided for @settingsPresetTheme.
  ///
  /// In de, this message translates to:
  /// **'Preset Theme'**
  String get settingsPresetTheme;

  /// No description provided for @settingsPresetDesc.
  ///
  /// In de, this message translates to:
  /// **'Vorgefertigte Design-Kombinationen'**
  String get settingsPresetDesc;

  /// No description provided for @settingsJobcenterTitle.
  ///
  /// In de, this message translates to:
  /// **'Jobcenter-Modus'**
  String get settingsJobcenterTitle;

  /// No description provided for @settingsJobcenterDesc.
  ///
  /// In de, this message translates to:
  /// **'Zeigt den \'Nachweis\'-Tab an'**
  String get settingsJobcenterDesc;

  /// No description provided for @settingsFieldTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Berufsfeld & Eigene Spalten'**
  String get settingsFieldTitle;

  /// No description provided for @settingsFieldSelect.
  ///
  /// In de, this message translates to:
  /// **'Berufsfeld auswählen'**
  String get settingsFieldSelect;

  /// No description provided for @settingsCustomCols.
  ///
  /// In de, this message translates to:
  /// **'Zusätzliche Spalten (kommagetrennt)'**
  String get settingsCustomCols;

  /// No description provided for @settingsPersonalData.
  ///
  /// In de, this message translates to:
  /// **'Persönliche Daten (für PDF-Export)'**
  String get settingsPersonalData;

  /// No description provided for @settingsYourName.
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get settingsYourName;

  /// No description provided for @settingsYourAddress.
  ///
  /// In de, this message translates to:
  /// **'Deine Adresse'**
  String get settingsYourAddress;

  /// No description provided for @dashboardTabWeek.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Woche'**
  String get dashboardTabWeek;

  /// No description provided for @dashboardTabTotal.
  ///
  /// In de, this message translates to:
  /// **'Gesamtübersicht'**
  String get dashboardTabTotal;

  /// No description provided for @dashboardMsgStart.
  ///
  /// In de, this message translates to:
  /// **'Jede Reise beginnt mit dem ersten Schritt!'**
  String get dashboardMsgStart;

  /// No description provided for @dashboardMsgGood.
  ///
  /// In de, this message translates to:
  /// **'Guter Start! Weiter so!'**
  String get dashboardMsgGood;

  /// No description provided for @dashboardMsgStrong.
  ///
  /// In de, this message translates to:
  /// **'Starke Leistung diese Woche!'**
  String get dashboardMsgStrong;

  /// No description provided for @dashboardMsgFantastic.
  ///
  /// In de, this message translates to:
  /// **'FANTASTISCHE ARBEIT DIESE WOCHE!'**
  String get dashboardMsgFantastic;

  /// No description provided for @dashboardNewApps.
  ///
  /// In de, this message translates to:
  /// **'NEUE BEWERBUNGEN'**
  String get dashboardNewApps;

  /// No description provided for @dashboardActiveApps.
  ///
  /// In de, this message translates to:
  /// **'AKTIVE BEWERBUNGEN'**
  String get dashboardActiveApps;

  /// No description provided for @dashboardGoal.
  ///
  /// In de, this message translates to:
  /// **'Wochenziel: '**
  String get dashboardGoal;

  /// No description provided for @dashboardThisWeek.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche '**
  String get dashboardThisWeek;

  /// No description provided for @dashboardFooter.
  ///
  /// In de, this message translates to:
  /// **'Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀'**
  String get dashboardFooter;

  /// No description provided for @dashboardVsLastWeek.
  ///
  /// In de, this message translates to:
  /// **' vs. letzte Woche '**
  String get dashboardVsLastWeek;

  /// No description provided for @dashboardAppsLabel.
  ///
  /// In de, this message translates to:
  /// **' Bewerbungen'**
  String get dashboardAppsLabel;

  /// No description provided for @appSearch.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get appSearch;

  /// No description provided for @appSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Firma, Position, Ort...'**
  String get appSearchHint;

  /// No description provided for @appFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get appFilterAll;

  /// No description provided for @appCheckInbox.
  ///
  /// In de, this message translates to:
  /// **'Posteingang checken'**
  String get appCheckInbox;

  /// No description provided for @appEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Zeit für den ersten Schritt!'**
  String get appEmptyTitle;

  /// No description provided for @appEmptyDesc.
  ///
  /// In de, this message translates to:
  /// **'Lege deine erste Bewerbung an und organisiere deinen Weg zum Traumjob.'**
  String get appEmptyDesc;

  /// No description provided for @calClickDetails.
  ///
  /// In de, this message translates to:
  /// **'Klicke auf einen markierten Tag für Details.'**
  String get calClickDetails;

  /// No description provided for @calOverdue.
  ///
  /// In de, this message translates to:
  /// **'Überfällig'**
  String get calOverdue;

  /// No description provided for @calFollowUp.
  ///
  /// In de, this message translates to:
  /// **'Nachhaken'**
  String get calFollowUp;

  /// No description provided for @reportGeneratedOn.
  ///
  /// In de, this message translates to:
  /// **'Generiert am: '**
  String get reportGeneratedOn;

  /// No description provided for @reportNoApps.
  ///
  /// In de, this message translates to:
  /// **'Keine Bewerbungen vorhanden.'**
  String get reportNoApps;

  /// No description provided for @navJobcenter.
  ///
  /// In de, this message translates to:
  /// **'Jobcenter-Nachweis'**
  String get navJobcenter;

  /// No description provided for @settingsImapTitle.
  ///
  /// In de, this message translates to:
  /// **'E-Mail Synchronisation (IMAP)'**
  String get settingsImapTitle;

  /// No description provided for @settingsImapDesc.
  ///
  /// In de, this message translates to:
  /// **'Empfängt Absagen/Einladungen automatisch'**
  String get settingsImapDesc;

  /// No description provided for @settingsImapExp.
  ///
  /// In de, this message translates to:
  /// **'EXPERIMENTELL'**
  String get settingsImapExp;

  /// No description provided for @settingsImapWarning.
  ///
  /// In de, this message translates to:
  /// **'Diese Funktion ist noch in Entwicklung. Die automatische Erkennung von Firmennamen und Bewerbungen kann ungenau sein. Importierte Einträge bitte manuell prüfen.'**
  String get settingsImapWarning;

  /// No description provided for @settingsImapProvider.
  ///
  /// In de, this message translates to:
  /// **'Anbieter'**
  String get settingsImapProvider;

  /// No description provided for @settingsImapManual.
  ///
  /// In de, this message translates to:
  /// **'Manuell / Eigener Server'**
  String get settingsImapManual;

  /// No description provided for @settingsImapServer.
  ///
  /// In de, this message translates to:
  /// **'IMAP Server'**
  String get settingsImapServer;

  /// No description provided for @settingsImapPort.
  ///
  /// In de, this message translates to:
  /// **'Port'**
  String get settingsImapPort;

  /// No description provided for @settingsImapEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail Adresse'**
  String get settingsImapEmail;

  /// No description provided for @settingsImapPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort (App-Passwort)'**
  String get settingsImapPassword;

  /// No description provided for @settingsImapSave.
  ///
  /// In de, this message translates to:
  /// **'Daten speichern'**
  String get settingsImapSave;

  /// No description provided for @settingsExportTitle.
  ///
  /// In de, this message translates to:
  /// **'Daten-Export'**
  String get settingsExportTitle;

  /// No description provided for @settingsExportPdf.
  ///
  /// In de, this message translates to:
  /// **'Jobcenter-Nachweis exportieren (PDF)'**
  String get settingsExportPdf;

  /// No description provided for @settingsExportCsv.
  ///
  /// In de, this message translates to:
  /// **'Export als CSV'**
  String get settingsExportCsv;

  /// No description provided for @settingsExportBackup.
  ///
  /// In de, this message translates to:
  /// **'Datenbank Backup exportieren (.sqlite)'**
  String get settingsExportBackup;

  /// No description provided for @settingsExportRestore.
  ///
  /// In de, this message translates to:
  /// **'Datenbank aus Backup wiederherstellen'**
  String get settingsExportRestore;

  /// No description provided for @settingsExportRestart.
  ///
  /// In de, this message translates to:
  /// **'Info: App-Neustart nach Import erforderlich.'**
  String get settingsExportRestart;

  /// No description provided for @settingsAppQuit.
  ///
  /// In de, this message translates to:
  /// **'App beenden'**
  String get settingsAppQuit;

  /// No description provided for @appNotFoundTitle.
  ///
  /// In de, this message translates to:
  /// **'Nichts gefunden.'**
  String get appNotFoundTitle;

  /// No description provided for @appNotFoundDesc.
  ///
  /// In de, this message translates to:
  /// **'Mit diesen Filtereinstellungen gibt es leider keine Treffer.'**
  String get appNotFoundDesc;

  /// No description provided for @formTabBasic.
  ///
  /// In de, this message translates to:
  /// **'Basisdaten'**
  String get formTabBasic;

  /// No description provided for @formTabEmails.
  ///
  /// In de, this message translates to:
  /// **'E-Mails & Kontakte'**
  String get formTabEmails;

  /// No description provided for @formTabDocs.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get formTabDocs;

  /// No description provided for @formTabNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get formTabNotes;

  /// No description provided for @formBasicContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt & Adresse'**
  String get formBasicContact;

  /// No description provided for @formBasicSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get formBasicSave;

  /// No description provided for @formBasicInterview.
  ///
  /// In de, this message translates to:
  /// **'Interview'**
  String get formBasicInterview;

  /// No description provided for @formBasicSalary.
  ///
  /// In de, this message translates to:
  /// **'Gehaltswunsch (€/Jahr)'**
  String get formBasicSalary;

  /// No description provided for @formBasicOpen.
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get formBasicOpen;

  /// No description provided for @formBasicAccepted.
  ///
  /// In de, this message translates to:
  /// **'Zusage'**
  String get formBasicAccepted;

  /// No description provided for @formBasicRejected.
  ///
  /// In de, this message translates to:
  /// **'Absage'**
  String get formBasicRejected;

  /// No description provided for @formBasicJobLink.
  ///
  /// In de, this message translates to:
  /// **'Link zur Stellenausschreibung'**
  String get formBasicJobLink;

  /// No description provided for @formBasicJobLinkHint.
  ///
  /// In de, this message translates to:
  /// **'Füge einen Job-Link ein oder lade ein PDF hoch (z.B. Jobcenter), um Daten zu extrahieren.'**
  String get formBasicJobLinkHint;

  /// No description provided for @formBasicAutofill.
  ///
  /// In de, this message translates to:
  /// **'Ausfüllen'**
  String get formBasicAutofill;

  /// No description provided for @formBasicCommute.
  ///
  /// In de, this message translates to:
  /// **'Pendelzeit Auto (Min.)'**
  String get formBasicCommute;

  /// No description provided for @formBasicRejectionReason.
  ///
  /// In de, this message translates to:
  /// **'Absagegrund'**
  String get formBasicRejectionReason;

  /// No description provided for @formBasicUploadPdf.
  ///
  /// In de, this message translates to:
  /// **'Oder PDF hochladen'**
  String get formBasicUploadPdf;

  /// No description provided for @formBasicStatus.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get formBasicStatus;

  /// No description provided for @formBasicCompanyWeb.
  ///
  /// In de, this message translates to:
  /// **'Webseite der Firma (z.B. https://)'**
  String get formBasicCompanyWeb;

  /// No description provided for @formBasicMagic.
  ///
  /// In de, this message translates to:
  /// **'Magic Auto-Fill'**
  String get formBasicMagic;

  /// No description provided for @formBasicDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get formBasicDelete;

  /// No description provided for @formBasicSent.
  ///
  /// In de, this message translates to:
  /// **'Versendet'**
  String get formBasicSent;

  /// No description provided for @reportGeneratedAt.
  ///
  /// In de, this message translates to:
  /// **'Generiert am:'**
  String get reportGeneratedAt;

  /// No description provided for @reportTimeSuffix.
  ///
  /// In de, this message translates to:
  /// **' Uhr'**
  String get reportTimeSuffix;

  /// No description provided for @weeklyGoal.
  ///
  /// In de, this message translates to:
  /// **'Wochenziel:'**
  String get weeklyGoal;

  /// No description provided for @weeklyGoalSuffix.
  ///
  /// In de, this message translates to:
  /// **' von 5 Bewerbungen'**
  String get weeklyGoalSuffix;

  /// No description provided for @weeklyThisWeek.
  ///
  /// In de, this message translates to:
  /// **'Diese Woche '**
  String get weeklyThisWeek;

  /// No description provided for @weeklyVs.
  ///
  /// In de, this message translates to:
  /// **' Bewerbungen vs. letzte Woche '**
  String get weeklyVs;

  /// No description provided for @weeklyApplications.
  ///
  /// In de, this message translates to:
  /// **' Bewerbungen'**
  String get weeklyApplications;

  /// No description provided for @weeklyMotivationalFooter.
  ///
  /// In de, this message translates to:
  /// **'Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job. 🚀'**
  String get weeklyMotivationalFooter;

  /// No description provided for @weeklyMotivationalFooterNoIcon.
  ///
  /// In de, this message translates to:
  /// **'Bleib dran! Jeder Schritt bringt dich näher an den perfekten Job.'**
  String get weeklyMotivationalFooterNoIcon;

  /// No description provided for @templatesTabMy.
  ///
  /// In de, this message translates to:
  /// **'Meine Vorlagen'**
  String get templatesTabMy;

  /// No description provided for @templatesTabExamples.
  ///
  /// In de, this message translates to:
  /// **'Muster & Beispiele'**
  String get templatesTabExamples;

  /// No description provided for @promptTitle.
  ///
  /// In de, this message translates to:
  /// **'KI Prompt Generator'**
  String get promptTitle;

  /// No description provided for @promptDesc.
  ///
  /// In de, this message translates to:
  /// **'Fülle die Felder aus und generiere einen professionellen Prompt, den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst.'**
  String get promptDesc;

  /// No description provided for @promptPosition.
  ///
  /// In de, this message translates to:
  /// **'Position / Stellentitel'**
  String get promptPosition;

  /// No description provided for @promptCompany.
  ///
  /// In de, this message translates to:
  /// **'Firma'**
  String get promptCompany;

  /// No description provided for @promptSkills.
  ///
  /// In de, this message translates to:
  /// **'Deine Top-Skills & Erfahrung'**
  String get promptSkills;

  /// No description provided for @promptTone.
  ///
  /// In de, this message translates to:
  /// **'Tonalität'**
  String get promptTone;

  /// No description provided for @promptToneDefault.
  ///
  /// In de, this message translates to:
  /// **'professionell und freundlich'**
  String get promptToneDefault;

  /// No description provided for @promptGenerate.
  ///
  /// In de, this message translates to:
  /// **'Prompt generieren'**
  String get promptGenerate;

  /// No description provided for @tplInitiative.
  ///
  /// In de, this message translates to:
  /// **'Initiativbewerbung'**
  String get tplInitiative;

  /// No description provided for @tplReply.
  ///
  /// In de, this message translates to:
  /// **'Antwort auf Stellenanzeige'**
  String get tplReply;

  /// No description provided for @tplFollowUp.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung / Follow-up'**
  String get tplFollowUp;

  /// No description provided for @tplRejection.
  ///
  /// In de, this message translates to:
  /// **'Absage höflich beantworten'**
  String get tplRejection;

  /// No description provided for @tplTypeCover.
  ///
  /// In de, this message translates to:
  /// **'ANSCHREIBEN'**
  String get tplTypeCover;

  /// No description provided for @tplTypeSnippet.
  ///
  /// In de, this message translates to:
  /// **'TEXTBAUSTEIN'**
  String get tplTypeSnippet;

  /// No description provided for @noAppsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Bewerbungen gefunden.'**
  String get noAppsFound;

  /// No description provided for @templatesEmptyState.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Vorlagen erstellt.'**
  String get templatesEmptyState;

  /// No description provided for @templatesEmptyStateSub.
  ///
  /// In de, this message translates to:
  /// **'Erstelle dein erstes Anschreiben oder einen Textbaustein!'**
  String get templatesEmptyStateSub;

  /// No description provided for @promptSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Fülle die Felder aus und generiere einen professionellen Prompt, den Du in ChatGPT, Claude oder einer anderen KI Deiner Wahl verwenden kannst.'**
  String get promptSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
