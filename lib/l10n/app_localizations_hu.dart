// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appName => 'Karrierközpont';

  @override
  String get navDashboard => 'Irányítópult';

  @override
  String get navApplications => 'Jelentkezések';

  @override
  String get navCalendar => 'Naptár';

  @override
  String get navTemplates => 'Dokumentumaim';

  @override
  String get navSettings => 'Beállítások';

  @override
  String get applicationsTitle => 'Jelentkezéseim';

  @override
  String get btnNewApplication => 'Új jelentkezés';

  @override
  String get statusOpen => 'Nyitott';

  @override
  String get statusSent => 'Elküldve';

  @override
  String get statusInterview => 'Interjú';

  @override
  String get statusAccepted => 'Elfogadva';

  @override
  String get statusRejected => 'Elutasítva';

  @override
  String get kanbanPreparation => '📝 Előkészületben';

  @override
  String get kanbanWaiting => '⏳ Válaszra vár';

  @override
  String get kanbanInterview => '🗣️ Interjú alatt';

  @override
  String get kanbanOffers => '🎉 Ajánlatok';

  @override
  String get kanbanArchive => '🗑️ Archívum (Elutasított)';

  @override
  String get searchPlaceholder => 'Keresés cég, pozíció szerint...';

  @override
  String get emptyApplicationsTitle => 'Még nincsenek jelentkezések';

  @override
  String get emptyApplicationsDesc =>
      'Úgy tűnik, még nem adtál hozzá egyetlen jelentkezést sem. Kattints az \'Új jelentkezés\' gombra a kezdéshez!';

  @override
  String get dashboardTitle => 'Jelentkezési statisztikák';

  @override
  String get dashboardOverview => 'ÁTTEKINTÉS';

  @override
  String get dashboardApplications => 'JELENTKEZÉSEK';

  @override
  String get dashboardOpen => 'NYITOTT';

  @override
  String get dashboardRejections => 'ELUTASÍTVA';

  @override
  String get dashboardResponseRate => 'VÁLASZADÁSI ARÁNY';

  @override
  String get dashboardRejectionRate => 'ELUTASÍTÁSI ARÁNY';

  @override
  String get dashboardInterviews => 'INTERJÚK';

  @override
  String get dashboardCommute => 'ÁTL. UTAZÁSI IDŐ';

  @override
  String get dashboardAppsPerMonth => 'HAVI JELENTKEZÉSEK';

  @override
  String get dashboardTopRejectionReasons => 'LEGGYAKORIBB ELUTASÍTÁSI OKOK';

  @override
  String get dashboardNoRejectionReasons =>
      'Még nincsenek rögzített elutasítási okok.';

  @override
  String get calendarTitle => 'Jelentkezési naptár';

  @override
  String get calendarNoEvents => 'Nincs esemény ezen a napon.';

  @override
  String get templatesTitle => 'Sablonok és kísérőlevelek';

  @override
  String get templatesNew => 'Új sablon';

  @override
  String get templatesEmpty => 'Még nincsenek létrehozott sablonok.';

  @override
  String get templatesCreateFirst =>
      'Hozd létre az első kísérőleveledet vagy szövegrészletedet!';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String get settingsLanguage => 'Nyelv / Language';

  @override
  String get settingsTheme => 'Megjelenési mód';

  @override
  String get settingsThemeLight => 'Világos';

  @override
  String get settingsThemeDark => 'Sötét';

  @override
  String get settingsThemeSystem => 'Rendszer alapértelmezés';

  @override
  String get settingsPreset => 'Előre beállított téma';

  @override
  String get settingsAccentColor => 'Kiemelő szín';

  @override
  String get settingsJobcenterMode => 'Munkaügyi központ / Álláskeresési mód';

  @override
  String get reportTitle => 'Álláskeresési tevékenység igazolása';

  @override
  String get reportSavePdf => 'PDF mentése';

  @override
  String get reportDate => 'JELENTKEZÉS DÁTUMA';

  @override
  String get reportCompany => 'CÉG';

  @override
  String get reportPosition => 'POZÍCIÓ';

  @override
  String get reportStatus => 'ÁLLAPOT';

  @override
  String get reportRejectionReason => 'ELUTASÍTÁS OKA';

  @override
  String get settingsLanguageTitle => 'Nyelv';

  @override
  String get settingsAppLanguage => 'Alkalmazás nyelve';

  @override
  String get settingsDesignTitle => 'Megjelenés és testreszabás';

  @override
  String get settingsDesignMode => 'Megjelenési mód';

  @override
  String get settingsAccentColorTitle => 'Kiemelő szín';

  @override
  String get settingsPresetTheme => 'Előre beállított téma';

  @override
  String get settingsPresetDesc => 'Előre összeállított színkombinációk';

  @override
  String get settingsJobcenterTitle => 'Munkaügyi központ mód';

  @override
  String get settingsJobcenterDesc =>
      'Megjeleníti a \'Tevékenység igazolása\' lapot';

  @override
  String get settingsFieldTitle => 'Szakma és egyéni oszlopok';

  @override
  String get settingsFieldSelect => 'Szakma kiválasztása';

  @override
  String get settingsCustomCols => 'Egyéni oszlopok (vesszővel elválasztva)';

  @override
  String get settingsPersonalData => 'Személyes adatok (PDF-exportáláshoz)';

  @override
  String get settingsYourName => 'Neved';

  @override
  String get settingsYourAddress => 'Címed';

  @override
  String get dashboardTabWeek => 'Aktuális hét';

  @override
  String get dashboardTabTotal => 'Teljes áttekintés';

  @override
  String get dashboardMsgStart => 'Minden utazás egyetlen lépéssel kezdődik!';

  @override
  String get dashboardMsgGood => 'Jó kezdet! Csak így tovább!';

  @override
  String get dashboardMsgStrong => 'Kiváló teljesítmény ezen a héten!';

  @override
  String get dashboardMsgFantastic => 'FANTASZTIKUS MUNKA EZEN A HÉTEN!';

  @override
  String get dashboardNewApps => 'ÚJ JELENTKEZÉSEK';

  @override
  String get dashboardActiveApps => 'AKTÍV JELENTKEZÉSEK';

  @override
  String get dashboardGoal => 'Heti cél: ';

  @override
  String get dashboardThisWeek => 'Ezen a héten ';

  @override
  String get dashboardFooter =>
      'Ne add fel! Minden lépés közelebb visz az álommunkádhoz. 🚀';

  @override
  String get dashboardVsLastWeek => ' az előző héthez képest ';

  @override
  String get dashboardAppsLabel => ' jelentkezés';

  @override
  String get appSearch => 'Keresés';

  @override
  String get appSearchHint => 'Keresés cég, pozíció, helyszín alapján...';

  @override
  String get appFilterAll => 'Összes';

  @override
  String get appCheckInbox => 'Bejövő levelek ellenőrzése';

  @override
  String get appEmptyTitle => 'Itt az idő az első lépésre!';

  @override
  String get appEmptyDesc =>
      'Hozd létre az első jelentkezésedet, és szervezd meg az utadat az álommunkád felé.';

  @override
  String get calClickDetails => 'Kattints egy kijelölt napra a részletekért.';

  @override
  String get calOverdue => 'Lejárt';

  @override
  String get calFollowUp => 'Utánkövetés';

  @override
  String get reportGeneratedOn => 'Létrehozva: ';

  @override
  String get reportNoApps => 'Nem találhatók jelentkezések.';

  @override
  String get navJobcenter => 'Munkaügyi jelentés';

  @override
  String get settingsImapTitle => 'E-mail szinkronizálás (IMAP)';

  @override
  String get settingsImapDesc =>
      'Automatikusan fogadja az elutasításokat és meghívásokat';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Ez a funkció még fejlesztés alatt áll. A cégnevek és jelentkezések automatikus felismerése pontatlan lehet. Kérjük, ellenőrizd manuálisan az importált bejegyzéseket.';

  @override
  String get settingsImapProvider => 'Szolgáltató';

  @override
  String get settingsImapManual => 'Kézi / Saját szerver';

  @override
  String get settingsImapServer => 'IMAP szerver';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'E-mail cím';

  @override
  String get settingsImapPassword => 'Jelszó (alkalmazásjelszó)';

  @override
  String get settingsImapSave => 'Adatok mentése';

  @override
  String get settingsExportTitle => 'Adatexportálás';

  @override
  String get settingsExportPdf => 'Munkaügyi jelentés exportálása (PDF)';

  @override
  String get settingsExportCsv => 'Exportálás CSV-ként';

  @override
  String get settingsExportBackup =>
      'Adatbázis biztonsági mentés exportálása (.sqlite)';

  @override
  String get settingsExportRestore =>
      'Adatbázis visszaállítása biztonsági mentésből';

  @override
  String get settingsExportRestart =>
      'Infó: Az importálás után újra kell indítani az alkalmazást.';

  @override
  String get settingsAppQuit => 'Kilépés az alkalmazásból';

  @override
  String get appNotFoundTitle => 'Nincs találat.';

  @override
  String get appNotFoundDesc =>
      'Ezekkel a szűrőbeállításokkal nincsenek találatok.';

  @override
  String get formTabBasic => 'Alapadatok';

  @override
  String get formTabEmails => 'E-mailek és kapcsolatok';

  @override
  String get formTabDocs => 'Dokumentumok';

  @override
  String get formTabNotes => 'Jegyzetek';

  @override
  String get formBasicContact => 'Kapcsolattartó és cím';

  @override
  String get formBasicSave => 'Mentés';

  @override
  String get formBasicInterview => 'Interjú';

  @override
  String get formBasicSalary => 'Bérigény (€/év)';

  @override
  String get formBasicOpen => 'Nyitott';

  @override
  String get formBasicAccepted => 'Ajánlat';

  @override
  String get formBasicRejected => 'Elutasítva';

  @override
  String get formBasicJobLink => 'Álláshirdetés hivatkozása';

  @override
  String get formBasicJobLinkHint =>
      'Illessz be egy álláshirdetés-hivatkozást, vagy tölts fel egy PDF-et az adatok kinyeréséhez.';

  @override
  String get formBasicAutofill => 'Automatikus kitöltés';

  @override
  String get formBasicCommute => 'Utazási idő (perc)';

  @override
  String get formBasicRejectionReason => 'Elutasítás oka';

  @override
  String get formBasicUploadPdf => 'Vagy tölts fel PDF-et';

  @override
  String get formBasicStatus => 'Állapot';

  @override
  String get formBasicCompanyWeb => 'A cég weboldala (pl. https://)';

  @override
  String get formBasicMagic => 'Magic Auto-Fill';

  @override
  String get formBasicDelete => 'Törlés';

  @override
  String get formBasicSent => 'Elküldve';

  @override
  String get reportGeneratedAt => 'Létrehozva:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Heti cél:';

  @override
  String get weeklyGoalSuffix => ' az 5 jelentkezésből';

  @override
  String get weeklyThisWeek => 'Ezen a héten ';

  @override
  String get weeklyVs => ' jelentkezés a múlt heti ';

  @override
  String get weeklyApplications => ' jelentkezéshez képest';

  @override
  String get weeklyMotivationalFooter =>
      'Csak így tovább! Minden lépés közelebb visz a tökéletes álláshoz. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Csak így tovább! Minden lépés közelebb visz a tökéletes álláshoz.';

  @override
  String get templatesTabMy => 'Saját sablonok';

  @override
  String get templatesTabExamples => 'Minták és példák';

  @override
  String get promptTitle => 'AI prompt generátor';

  @override
  String get promptDesc =>
      'Töltsd ki a mezőket egy professzionális prompt létrehozásához, amelyet a ChatGPT-ben, Claude-ban vagy bármely más tetszőleges mesterséges intelligenciában használhatsz.';

  @override
  String get promptPosition => 'Pozíció / Munkakör';

  @override
  String get promptCompany => 'Cég';

  @override
  String get promptSkills => 'Főbb készségeid és tapasztalataid';

  @override
  String get promptTone => 'Hangnem';

  @override
  String get promptToneDefault => 'professzionális és barátságos';

  @override
  String get promptGenerate => 'Prompt generálása';

  @override
  String get tplInitiative => 'Spontán jelentkezés';

  @override
  String get tplReply => 'Válasz álláshirdetésre';

  @override
  String get tplFollowUp => 'Emlékeztető / Utánkövetés';

  @override
  String get tplRejection => 'Udvarias válasz elutasításra';

  @override
  String get tplTypeCover => 'KÍSÉRŐLEVÉL';

  @override
  String get tplTypeSnippet => 'SZÖVEGRÉSZLET';

  @override
  String get noAppsFound => 'Nem találhatók jelentkezések.';

  @override
  String get templatesEmptyState => 'Még nincsenek létrehozott sablonok.';

  @override
  String get templatesEmptyStateSub =>
      'Hozd létre az első kísérőleveledet vagy szövegrészletedet!';

  @override
  String get promptSubtitle =>
      'Töltsd ki a mezőket, és hozz létre egy professzionális promptot, amelyet a ChatGPT-ben, Claude-ban vagy bármely más tetszőleges mesterséges intelligenciában használhatsz.';
}
