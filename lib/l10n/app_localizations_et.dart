// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appName => 'Karjäärikeskus';

  @override
  String get navDashboard => 'Töölaud';

  @override
  String get navApplications => 'Kandideerimised';

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navTemplates => 'Minu dokumendid';

  @override
  String get navSettings => 'Seaded';

  @override
  String get applicationsTitle => 'Minu kandideerimised';

  @override
  String get btnNewApplication => 'Uus kandideerimine';

  @override
  String get statusOpen => 'Avatud';

  @override
  String get statusSent => 'Saadetud';

  @override
  String get statusInterview => 'Intervjuu';

  @override
  String get statusAccepted => 'Pakkumine';

  @override
  String get statusRejected => 'Tagasi lükatud';

  @override
  String get kanbanPreparation => '📝 Ettevalmistamisel';

  @override
  String get kanbanWaiting => '⏳ Vastuse ootel';

  @override
  String get kanbanInterview => '🗣️ Vestlusel';

  @override
  String get kanbanOffers => '🎉 Pakkumised';

  @override
  String get kanbanArchive => '🗑️ Arhiiv (Tagasi lükatud)';

  @override
  String get searchPlaceholder => 'Otsi ettevõtet, ametit, asukohta...';

  @override
  String get emptyApplicationsTitle => 'Kandideerimisi pole veel';

  @override
  String get emptyApplicationsDesc =>
      'Tundub, et sa pole veel ühtegi kandideerimist lisanud. Alustamiseks klõpsa nupule \'Uus kandideerimine\'!';

  @override
  String get dashboardTitle => 'Kandideerimise statistika';

  @override
  String get dashboardOverview => 'ÜLEVAADE';

  @override
  String get dashboardApplications => 'KANDIDEERIMISED';

  @override
  String get dashboardOpen => 'AVATUD';

  @override
  String get dashboardRejections => 'TAGASI LÜKATUD';

  @override
  String get dashboardResponseRate => 'VASTAMISPROTSENT';

  @override
  String get dashboardRejectionRate => 'TAGASILÜKKAMISE PROTSENT';

  @override
  String get dashboardInterviews => 'INTERVJUUD';

  @override
  String get dashboardCommute => 'Ø TÖÖSÕIDU AEG';

  @override
  String get dashboardAppsPerMonth => 'KANDIDEERIMISED KUUS';

  @override
  String get dashboardTopRejectionReasons =>
      'PEAMISED TAGASILÜKKAMISE PÕHJUSED';

  @override
  String get dashboardNoRejectionReasons =>
      'Tagasilükkamise põhjuseid pole seni registreeritud.';

  @override
  String get calendarTitle => 'Kandideerimise kalender';

  @override
  String get calendarNoEvents => 'Selleks kuupäevaks pole sündmusi.';

  @override
  String get templatesTitle => 'Mallid ja kaaskirjad';

  @override
  String get templatesNew => 'Uus mall';

  @override
  String get templatesEmpty => 'Malle pole veel loodud.';

  @override
  String get templatesCreateFirst => 'Loo oma esimene kaaskiri või tekstijupp!';

  @override
  String get settingsTitle => 'Seaded';

  @override
  String get settingsLanguage => 'Keel / Language';

  @override
  String get settingsTheme => 'Kujundusrežiim';

  @override
  String get settingsThemeLight => 'Hele';

  @override
  String get settingsThemeDark => 'Tume';

  @override
  String get settingsThemeSystem => 'Süsteemi vaikeväärtus';

  @override
  String get settingsPreset => 'Valmisteema';

  @override
  String get settingsAccentColor => 'Aktsentvärv';

  @override
  String get settingsJobcenterMode => 'Töötukassa režiim';

  @override
  String get reportTitle => 'Tööotsingu aktiivsuse tõend';

  @override
  String get reportSavePdf => 'Salvesta PDF';

  @override
  String get reportDate => 'KANDIDEERIMISE KUUPÄEV';

  @override
  String get reportCompany => 'ETTEVÕTE';

  @override
  String get reportPosition => 'AMETIKOHT';

  @override
  String get reportStatus => 'STAATUS';

  @override
  String get reportRejectionReason => 'TAGASILÜKKAMISE PÕHJUS';

  @override
  String get settingsLanguageTitle => 'Keel';

  @override
  String get settingsAppLanguage => 'Rakenduse keel';

  @override
  String get settingsDesignTitle => 'Kujundus ja isikupärastamine';

  @override
  String get settingsDesignMode => 'Kujundusrežiim';

  @override
  String get settingsAccentColorTitle => 'Aktsentvärv';

  @override
  String get settingsPresetTheme => 'Valmisteema';

  @override
  String get settingsPresetDesc => 'Eelnevalt määratud kujunduskombinatsioonid';

  @override
  String get settingsJobcenterTitle => 'Töötukassa režiim';

  @override
  String get settingsJobcenterDesc => 'Kuvab vahekaarti \'Tõend\'';

  @override
  String get settingsFieldTitle => 'Sinu tegevusvaldkond ja kohandatud veerud';

  @override
  String get settingsFieldSelect => 'Vali tegevusvaldkond';

  @override
  String get settingsCustomCols => 'Lisaveerud (komaga eraldatud)';

  @override
  String get settingsPersonalData => 'Isikuandmed (PDF-i ekspordiks)';

  @override
  String get settingsYourName => 'Sinu nimi';

  @override
  String get settingsYourAddress => 'Sinu aadress';

  @override
  String get dashboardTabWeek => 'Praegune nädal';

  @override
  String get dashboardTabTotal => 'Üldülevaade';

  @override
  String get dashboardMsgStart => 'Iga teekond algab esimesest sammust!';

  @override
  String get dashboardMsgGood => 'Hea algus! Jätka samamoodi!';

  @override
  String get dashboardMsgStrong => 'Tugev esitus sel nädalal!';

  @override
  String get dashboardMsgFantastic => 'FANTASTILINE TÖÖ SEL NÄDALAL!';

  @override
  String get dashboardNewApps => 'UUDED KANDIDEERIMISED';

  @override
  String get dashboardActiveApps => 'AKTIIVSED KANDIDEERIMISED';

  @override
  String get dashboardGoal => 'Nädalaseesmärk: ';

  @override
  String get dashboardThisWeek => 'Sel nädalal ';

  @override
  String get dashboardFooter =>
      'Ära anna alla! Iga samm viib sind unistuste töökohale lähemale. 🚀';

  @override
  String get dashboardVsLastWeek => ' vs. eelmine nädal ';

  @override
  String get dashboardAppsLabel => ' kandideerimist';

  @override
  String get appSearch => 'Otsi';

  @override
  String get appSearchHint => 'Otsi ettevõtet, ametit, asukohta...';

  @override
  String get appFilterAll => 'Kõik';

  @override
  String get appCheckInbox => 'Kontrolli postkasti';

  @override
  String get appEmptyTitle => 'Aeg esimeseks sammuks!';

  @override
  String get appEmptyDesc =>
      'Lisa oma esimene kandideerimine ja korrasta oma tee unistuste töökohani.';

  @override
  String get calClickDetails =>
      'Üksikasjade nägemiseks klõpsa esiletõstetud päeval.';

  @override
  String get calOverdue => 'Tähtaja ületanud';

  @override
  String get calFollowUp => 'Järelpäring';

  @override
  String get reportGeneratedOn => 'Genereeritud: ';

  @override
  String get reportNoApps => 'Kandideerimisi pole.';

  @override
  String get navJobcenter => 'Töötukassa tõend';

  @override
  String get settingsImapTitle => 'E-posti sünkroonimine (IMAP)';

  @override
  String get settingsImapDesc =>
      'Võtab tagasilükkamised/kutsed automaatselt vastu';

  @override
  String get settingsImapExp => 'EKSPERIMENTAALNE';

  @override
  String get settingsImapWarning =>
      'See funktsioon on alles väljatöötamisel. Ettevõtete nimede ja kandideerimiste automaatne tuvastamine võib olla ebatäpne. Palun kontrollige imporditud kirjeid käsitsi.';

  @override
  String get settingsImapProvider => 'Teenusepakkuja';

  @override
  String get settingsImapManual => 'Käsitsi / Oma server';

  @override
  String get settingsImapServer => 'IMAP server';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'E-posti aadress';

  @override
  String get settingsImapPassword => 'Parool (rakenduse parool)';

  @override
  String get settingsImapSave => 'Salvesta andmed';

  @override
  String get settingsExportTitle => 'Andmete eksport';

  @override
  String get settingsExportPdf => 'Ekspordi töötukassa tõend (PDF)';

  @override
  String get settingsExportCsv => 'Eksport CSV-vormingus';

  @override
  String get settingsExportBackup => 'Ekspordi andmebaasi varukoopia (.sqlite)';

  @override
  String get settingsExportRestore => 'Taasta andmebaas varukoopiast';

  @override
  String get settingsExportRestart =>
      'Märkus: Pärast importimist on vajalik rakenduse taaskäivitamine.';

  @override
  String get settingsAppQuit => 'Sulge rakendus';

  @override
  String get appNotFoundTitle => 'Midagi ei leitud.';

  @override
  String get appNotFoundDesc =>
      'Valitud filtriseadetega kahjuks vasteid ei ole.';

  @override
  String get formTabBasic => 'Põhiandmed';

  @override
  String get formTabEmails => 'E-kirjad ja kontaktid';

  @override
  String get formTabDocs => 'Dokumendid';

  @override
  String get formTabNotes => 'Märkmed';

  @override
  String get formBasicContact => 'Kontakt ja aadress';

  @override
  String get formBasicSave => 'Salvesta';

  @override
  String get formBasicInterview => 'Intervjuu';

  @override
  String get formBasicSalary => 'Palgasoov (€/aastas)';

  @override
  String get formBasicOpen => 'Avatud';

  @override
  String get formBasicAccepted => 'Pakkumine';

  @override
  String get formBasicRejected => 'Tagasi lükatud';

  @override
  String get formBasicJobLink => 'Link tööpakkumisele';

  @override
  String get formBasicJobLinkHint =>
      'Andmete eraldamiseks kleepige töökuulutuse link või laadige üles PDF (nt Töötukassast).';

  @override
  String get formBasicAutofill => 'Automaattäide';

  @override
  String get formBasicCommute => 'Töösõidu aeg autoga (min)';

  @override
  String get formBasicRejectionReason => 'Tagasilükkamise põhjus';

  @override
  String get formBasicUploadPdf => 'Või laadi üles PDF';

  @override
  String get formBasicStatus => 'Staatus';

  @override
  String get formBasicCompanyWeb => 'Ettevõtte veebisait (nt https://)';

  @override
  String get formBasicMagic => 'Maagiline automaattäide';

  @override
  String get formBasicDelete => 'Kustuta';

  @override
  String get formBasicSent => 'Saadetud';

  @override
  String get reportGeneratedAt => 'Genereeritud:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Nädalaseesmärk:';

  @override
  String get weeklyGoalSuffix => ' / 5 kandideerimist';

  @override
  String get weeklyThisWeek => 'Sel nädalal ';

  @override
  String get weeklyVs => ' kandideerimist vs. eelmine nädal ';

  @override
  String get weeklyApplications => ' kandideerimist';

  @override
  String get weeklyMotivationalFooter =>
      'Ära anna alla! Iga samm viib sind unistuste töökohale lähemale. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Ära anna alla! Iga samm viib sind unistuste töökohale lähemale.';

  @override
  String get templatesTabMy => 'Minu mallid';

  @override
  String get templatesTabExamples => 'Näidised ja eeskujud';

  @override
  String get promptTitle => 'AI viipade generaator';

  @override
  String get promptDesc =>
      'Täida väljad ja loo professionaalne viip, mida saad kasutada ChatGPT-s, Claude\'is või mõnes muus valitud tehisintellektis.';

  @override
  String get promptPosition => 'Ametikoht / Ametikoha pealkiri';

  @override
  String get promptCompany => 'Ettevõte';

  @override
  String get promptSkills => 'Sinu peamised oskused ja kogemused';

  @override
  String get promptTone => 'Toon';

  @override
  String get promptToneDefault => 'professionaalne ja sõbralik';

  @override
  String get promptGenerate => 'Genereeri viip';

  @override
  String get tplInitiative => 'Initsiatiivikandideerimine';

  @override
  String get tplReply => 'Vastus tööpakkumisele';

  @override
  String get tplFollowUp => 'Meeldetuletus / Järelpäring';

  @override
  String get tplRejection => 'Viisakas vastus tagasilükkamisele';

  @override
  String get tplTypeCover => 'KAASKIRI';

  @override
  String get tplTypeSnippet => 'TEKSTIJUPP';

  @override
  String get noAppsFound => 'Kandideerimisi ei leitud.';

  @override
  String get templatesEmptyState => 'Malle pole veel loodud.';

  @override
  String get templatesEmptyStateSub =>
      'Loo oma esimene kaaskiri või tekstijupp!';

  @override
  String get promptSubtitle =>
      'Täida väljad ja genereeri professionaalne viip, mida saad kasutada ChatGPT-s, Claude\'is või mõnes muus valitud tehisintellektis.';
}
