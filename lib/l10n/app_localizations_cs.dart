// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appName => 'Kariérní centrum';

  @override
  String get navDashboard => 'Přehled';

  @override
  String get navApplications => 'Žádosti';

  @override
  String get navCalendar => 'Kalendář';

  @override
  String get navTemplates => 'Moje dokumenty';

  @override
  String get navSettings => 'Nastavení';

  @override
  String get applicationsTitle => 'Moje žádosti';

  @override
  String get btnNewApplication => 'Nová žádost';

  @override
  String get statusOpen => 'Otevřená';

  @override
  String get statusSent => 'Odeslaná';

  @override
  String get statusInterview => 'Pohovor';

  @override
  String get statusAccepted => 'Přijata';

  @override
  String get statusRejected => 'Zamítnuta';

  @override
  String get kanbanPreparation => '📝 V přípravě';

  @override
  String get kanbanWaiting => '⏳ Čekání na odpověď';

  @override
  String get kanbanInterview => '🗣️ Pohovory';

  @override
  String get kanbanOffers => '🎉 Nabídky';

  @override
  String get kanbanArchive => '🗑️ Archiv (zamítnuto)';

  @override
  String get searchPlaceholder => 'Hledat společnost, pozici...';

  @override
  String get emptyApplicationsTitle => 'Zatím žádné žádosti';

  @override
  String get emptyApplicationsDesc =>
      'Vypadá to, že jste zatím nepřidali žádné žádosti. Začněte kliknutím na \'Nová žádost\'!';

  @override
  String get dashboardTitle => 'Statistiky žádostí';

  @override
  String get dashboardOverview => 'PŘEHLED';

  @override
  String get dashboardApplications => 'ŽÁDOSTI';

  @override
  String get dashboardOpen => 'OTEVŘENÉ';

  @override
  String get dashboardRejections => 'ZAMÍTNUTÉ';

  @override
  String get dashboardResponseRate => 'MÍRA ODPOVĚDÍ';

  @override
  String get dashboardRejectionRate => 'MÍRA ZAMÍTNUTÍ';

  @override
  String get dashboardInterviews => 'POHOVORY';

  @override
  String get dashboardCommute => 'PRŮM. DOBA DOJÍŽDĚNÍ';

  @override
  String get dashboardAppsPerMonth => 'ŽÁDOSTI ZA MĚSÍC';

  @override
  String get dashboardTopRejectionReasons => 'HLAVNÍ DŮVODY ZAMÍTNUTÍ';

  @override
  String get dashboardNoRejectionReasons =>
      'Zatím nebyly zaznamenány žádné důvody zamítnutí.';

  @override
  String get calendarTitle => 'Kalendář žádostí';

  @override
  String get calendarNoEvents => 'V tento den nejsou žádné události.';

  @override
  String get templatesTitle => 'Šablony a motivační dopisy';

  @override
  String get templatesNew => 'Nová šablona';

  @override
  String get templatesEmpty => 'Zatím nebyly vytvořeny žádné šablony.';

  @override
  String get templatesCreateFirst =>
      'Vytvořte svůj první motivační dopis nebo textový blok!';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsLanguage => 'Jazyk / Language';

  @override
  String get settingsTheme => 'Režim vzhledu';

  @override
  String get settingsThemeLight => 'Světlý';

  @override
  String get settingsThemeDark => 'Tmavý';

  @override
  String get settingsThemeSystem => 'Výchozí systémový';

  @override
  String get settingsPreset => 'Přednastavený motiv';

  @override
  String get settingsAccentColor => 'Barva zvýraznění';

  @override
  String get settingsJobcenterMode => 'Režim Úřad práce / Jobcenter';

  @override
  String get reportTitle => 'Doklad o vlastní snaze';

  @override
  String get reportSavePdf => 'Uložit PDF';

  @override
  String get reportDate => 'DATUM ŽÁDOSTI';

  @override
  String get reportCompany => 'SPOLEČNOST';

  @override
  String get reportPosition => 'POZICE';

  @override
  String get reportStatus => 'STAV';

  @override
  String get reportRejectionReason => 'DŮVOD ZAMÍTNUTÍ';

  @override
  String get settingsLanguageTitle => 'Jazyk';

  @override
  String get settingsAppLanguage => 'Jazyk aplikace';

  @override
  String get settingsDesignTitle => 'Vzhled a přizpůsobení';

  @override
  String get settingsDesignMode => 'Režim vzhledu';

  @override
  String get settingsAccentColorTitle => 'Barva zvýraznění';

  @override
  String get settingsPresetTheme => 'Přednastavený motiv';

  @override
  String get settingsPresetDesc => 'Předpřipravené kombinace vzhledu';

  @override
  String get settingsJobcenterTitle => 'Režim Úřadu práce';

  @override
  String get settingsJobcenterDesc =>
      'Zobrazí záložku \'Doklad o vlastní snaze\'';

  @override
  String get settingsFieldTitle => 'Váš obor a vlastní sloupce';

  @override
  String get settingsFieldSelect => 'Vybrat obor';

  @override
  String get settingsCustomCols => 'Vlastní sloupce (oddělené čárkou)';

  @override
  String get settingsPersonalData => 'Osobní údaje (pro export do PDF)';

  @override
  String get settingsYourName => 'Vaše jméno';

  @override
  String get settingsYourAddress => 'Vaše adresa';

  @override
  String get dashboardTabWeek => 'Aktuální týden';

  @override
  String get dashboardTabTotal => 'Celkový přehled';

  @override
  String get dashboardMsgStart => 'Každá cesta začíná prvním krokem!';

  @override
  String get dashboardMsgGood => 'Dobrý začátek! Jen tak dál!';

  @override
  String get dashboardMsgStrong => 'Skvělý výkon tento týden!';

  @override
  String get dashboardMsgFantastic => 'FANTASTICKÁ PRÁCE TENTO TÝDEN!';

  @override
  String get dashboardNewApps => 'NOVÉ ŽÁDOSTI';

  @override
  String get dashboardActiveApps => 'AKTIVNÍ ŽÁDOSTI';

  @override
  String get dashboardGoal => 'Týdenní cíl: ';

  @override
  String get dashboardThisWeek => 'Tento týden ';

  @override
  String get dashboardFooter =>
      'Pokračujte! Každý krok vás posouvá blíže k vaší vysněné práci. 🚀';

  @override
  String get dashboardVsLastWeek => ' oproti minulému týdnu ';

  @override
  String get dashboardAppsLabel => ' žádostí';

  @override
  String get appSearch => 'Hledat';

  @override
  String get appSearchHint => 'Hledat firmu, pozici, lokalitu...';

  @override
  String get appFilterAll => 'Vše';

  @override
  String get appCheckInbox => 'Zkontrolovat doručenou poštu';

  @override
  String get appEmptyTitle => 'Čas na první krok!';

  @override
  String get appEmptyDesc =>
      'Vytvořte svou první žádost a naplánujte si cestu k vysněné práci.';

  @override
  String get calClickDetails => 'Klikněte na zvýrazněný den pro podrobnosti.';

  @override
  String get calOverdue => 'Po termínu';

  @override
  String get calFollowUp => 'Následný kontakt';

  @override
  String get reportGeneratedOn => 'Vygenerováno dne: ';

  @override
  String get reportNoApps => 'Nebyly nalezeny žádné žádosti.';

  @override
  String get navJobcenter => 'Přehled pro Úřad práce';

  @override
  String get settingsImapTitle => 'Synchronizace e-mailů (IMAP)';

  @override
  String get settingsImapDesc => 'Automaticky přijímá zamítnutí/pozvánky';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Tato funkce je stále ve vývoji. Automatické rozpoznávání názvů společností a žádostí nemusí být přesné. Zkontrolujte prosím importované záznamy ručně.';

  @override
  String get settingsImapProvider => 'Poskytovatel';

  @override
  String get settingsImapManual => 'Ruční / Vlastní server';

  @override
  String get settingsImapServer => 'IMAP server';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'E-mailová adresa';

  @override
  String get settingsImapPassword => 'Heslo (heslo aplikace)';

  @override
  String get settingsImapSave => 'Uložit údaje';

  @override
  String get settingsExportTitle => 'Export dat';

  @override
  String get settingsExportPdf => 'Exportovat přehled pro Úřad práce (PDF)';

  @override
  String get settingsExportCsv => 'Exportovat jako CSV';

  @override
  String get settingsExportBackup => 'Exportovat zálohu databáze (.sqlite)';

  @override
  String get settingsExportRestore => 'Obnovit databázi ze zálohy';

  @override
  String get settingsExportRestart =>
      'Informace: Po importu je vyžadován restart aplikace.';

  @override
  String get settingsAppQuit => 'Ukončit aplikaci';

  @override
  String get appNotFoundTitle => 'Nebylo nic nalezeno.';

  @override
  String get appNotFoundDesc =>
      'Pro toto nastavení filtru nebyly nalezeny žádné výsledky.';

  @override
  String get formTabBasic => 'Základní údaje';

  @override
  String get formTabEmails => 'E-maily a kontakty';

  @override
  String get formTabDocs => 'Dokumenty';

  @override
  String get formTabNotes => 'Poznámky';

  @override
  String get formBasicContact => 'Kontakt a adresa';

  @override
  String get formBasicSave => 'Uložit';

  @override
  String get formBasicInterview => 'Pohovor';

  @override
  String get formBasicSalary => 'Očekávaný plat (€/rok)';

  @override
  String get formBasicOpen => 'Otevřená';

  @override
  String get formBasicAccepted => 'Nabídka';

  @override
  String get formBasicRejected => 'Zamítnuta';

  @override
  String get formBasicJobLink => 'Odkaz na nabídku práce';

  @override
  String get formBasicJobLinkHint =>
      'Vložte odkaz na práci nebo nahrajte PDF (např. z Úřadu práce) pro extrakci dat.';

  @override
  String get formBasicAutofill => 'Vyplnit';

  @override
  String get formBasicCommute => 'Doba dojíždění (min.)';

  @override
  String get formBasicRejectionReason => 'Důvod zamítnutí';

  @override
  String get formBasicUploadPdf => 'Nebo nahrát PDF';

  @override
  String get formBasicStatus => 'Stav';

  @override
  String get formBasicCompanyWeb =>
      'Webová stránka společnosti (např. https://)';

  @override
  String get formBasicMagic => 'Magické automatické vyplnění';

  @override
  String get formBasicDelete => 'Smazat';

  @override
  String get formBasicSent => 'Odeslána';

  @override
  String get reportGeneratedAt => 'Vygenerováno v:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Týdenní cíl:';

  @override
  String get weeklyGoalSuffix => ' z 5 žádostí';

  @override
  String get weeklyThisWeek => 'Tento týden ';

  @override
  String get weeklyVs => ' žádostí oproti minulému týdnu ';

  @override
  String get weeklyApplications => ' žádostí';

  @override
  String get weeklyMotivationalFooter =>
      'Jen tak dál! Každý krok vás posouvá blíže k dokonalé práci. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Jen tak dál! Každý krok vás posouvá blíže k dokonalé práci.';

  @override
  String get templatesTabMy => 'Moje šablony';

  @override
  String get templatesTabExamples => 'Vzory a příklady';

  @override
  String get promptTitle => 'Generátor AI promptů';

  @override
  String get promptDesc =>
      'Vyplňte pole a vygenerujte profesionální prompt, který můžete použít v ChatGPT, Claude nebo jakékoli jiné AI dle vašeho výběru.';

  @override
  String get promptPosition => 'Pozice / Název pozice';

  @override
  String get promptCompany => 'Společnost';

  @override
  String get promptSkills => 'Vaše hlavní dovednosti a zkušenosti';

  @override
  String get promptTone => 'Tón';

  @override
  String get promptToneDefault => 'profesionální a přátelský';

  @override
  String get promptGenerate => 'Vygenerovat prompt';

  @override
  String get tplInitiative => 'Žádost z vlastní iniciativy';

  @override
  String get tplReply => 'Odpověď na inzerát';

  @override
  String get tplFollowUp => 'Připomenutí / Další kontakt';

  @override
  String get tplRejection => 'Zdvořilá odpověď na zamítnutí';

  @override
  String get tplTypeCover => 'MOTIVAČNÍ DOPIS';

  @override
  String get tplTypeSnippet => 'TEXTOVÝ BLOK';

  @override
  String get noAppsFound => 'Nebyly nalezeny žádné žádosti.';

  @override
  String get templatesEmptyState => 'Zatím nebyly vytvořeny žádné šablony.';

  @override
  String get templatesEmptyStateSub =>
      'Vytvořte svůj první motivační dopis nebo textový blok!';

  @override
  String get promptSubtitle =>
      'Vyplňte pole a vygenerujte profesionální prompt, který můžete použít v ChatGPT, Claude nebo jakékoli jiné AI dle vašeho výběru.';
}
