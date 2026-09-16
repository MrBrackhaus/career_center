// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Guarani (`gn`).
class AppLocalizationsGn extends AppLocalizations {
  AppLocalizationsGn([String locale = 'gn']) : super(locale);

  @override
  String get appName => 'Mba\'apo Róga';

  @override
  String get navDashboard => 'Mba\'apo Renda';

  @override
  String get navApplications => 'Mba\'apo Jejerure';

  @override
  String get navCalendar => 'Ararogue';

  @override
  String get navTemplates => 'Che Kuatiakuéra';

  @override
  String get navSettings => 'Mohendakuéra';

  @override
  String get applicationsTitle => 'Che Mba\'apo Jejerure';

  @override
  String get btnNewApplication => 'Mba\'apo Jejerure Pyahu';

  @override
  String get statusOpen => 'Ojepe\'áva';

  @override
  String get statusSent => 'Oñemondoma';

  @override
  String get statusInterview => 'Ñemongeta';

  @override
  String get statusAccepted => 'Ojehechakuaáva';

  @override
  String get statusRejected => 'Oñemboykéva';

  @override
  String get kanbanPreparation => '📝 Oñembosako\'íva';

  @override
  String get kanbanWaiting => '⏳ Oha\'arõva Mbohovái';

  @override
  String get kanbanInterview => '🗣️ Oñemongetáva';

  @override
  String get kanbanOffers => '🎉 Ojejapóva';

  @override
  String get kanbanArchive => '🗑️ Ñongatupy (Oñemboykéva)';

  @override
  String get searchPlaceholder => 'Jeheka mba\'apo apoha, tenda...';

  @override
  String get emptyApplicationsTitle => 'Ndaipíri mba\'apo jejerure gueteri';

  @override
  String get emptyApplicationsDesc =>
      'Ojehecha nderejapoite gueteri mba\'apo jejerure. Eikutu \'Mba\'apo Jejerure Pyahu\' eñepyrũ hag̃ua!';

  @override
  String get dashboardTitle => 'Mba\'apo Jejerure Papapy';

  @override
  String get dashboardOverview => 'ÑEMBOHECHA';

  @override
  String get dashboardApplications => 'MBA\'APO JEJERURE';

  @override
  String get dashboardOpen => 'OJEPE\'ÁVA';

  @override
  String get dashboardRejections => 'OÑEMBOYKÉVA';

  @override
  String get dashboardResponseRate => 'MBOHOVÁI PAPAPY';

  @override
  String get dashboardRejectionRate => 'BOYKE PAPAPY';

  @override
  String get dashboardInterviews => 'ÑEMONGETA';

  @override
  String get dashboardCommute => 'TAPERE ARAVO MBO\'Y';

  @override
  String get dashboardAppsPerMonth => 'MBA\'APO JEJERURE JASYRE';

  @override
  String get dashboardTopRejectionReasons => 'MBA\'ERE OÑEMBOYKE VAEGUASU';

  @override
  String get dashboardNoRejectionReasons =>
      'Ndaipíri mba\'ere oñemboyke ojeikuaáva gueteri.';

  @override
  String get calendarTitle => 'Mba\'apo Jejerure Ararogue';

  @override
  String get calendarNoEvents => 'Ndaipíri mba\'e ojehumáva ko árape.';

  @override
  String get templatesTitle => 'Kuatia Ñe\'ẽporã & Jehechaukaha';

  @override
  String get templatesNew => 'Kuatia Pyahu';

  @override
  String get templatesEmpty => 'Ndaipíri kuatia ñe\'ẽporã ojejapóva gueteri.';

  @override
  String get templatesCreateFirst =>
      'Ejapo ne ñepyrũha kuatia ñe\'ẽporã térã ñe\'ẽpehẽ!';

  @override
  String get settingsTitle => 'Mohendakuéra';

  @override
  String get settingsLanguage => 'Ñe\'ẽ / Language';

  @override
  String get settingsTheme => 'Mohenda Recha';

  @override
  String get settingsThemeLight => 'Hesakãva';

  @override
  String get settingsThemeDark => 'Pytũva';

  @override
  String get settingsThemeSystem => 'Mohendahára reko';

  @override
  String get settingsPreset => 'Mohenda Oñembosako\'ímava';

  @override
  String get settingsAccentColor => 'Sa\'y Tee';

  @override
  String get settingsJobcenterMode =>
      'Jobcenter / Mba\'apo\'ỹva Rekoha Mohenda';

  @override
  String get reportTitle => 'Mba\'apo Jeheka Mombe\'u';

  @override
  String get reportSavePdf => 'Ñongatu PDF';

  @override
  String get reportDate => 'MBA\'APO JEJERURE ÁRA';

  @override
  String get reportCompany => 'MBA\'APO APOHA';

  @override
  String get reportPosition => 'TEMBIAPO TENONDE';

  @override
  String get reportStatus => 'REKO';

  @override
  String get reportRejectionReason => 'MBA\'ERE OÑEMBOYKE';

  @override
  String get settingsLanguageTitle => 'Ñe\'ẽ';

  @override
  String get settingsAppLanguage => 'App Ñe\'ẽ';

  @override
  String get settingsDesignTitle => 'Mohenda & Jeheguiete';

  @override
  String get settingsDesignMode => 'Mohenda Recha';

  @override
  String get settingsAccentColorTitle => 'Sa\'y Tee';

  @override
  String get settingsPresetTheme => 'Mohenda Oñembosako\'ímava';

  @override
  String get settingsPresetDesc => 'Mohenda ojejapomava';

  @override
  String get settingsJobcenterTitle => 'Jobcenter Mohenda';

  @override
  String get settingsJobcenterDesc =>
      'Ohechauka \'Mba\'apo Jeheka Mombe\'u\' tenda';

  @override
  String get settingsFieldTitle => 'Ne Mba\'apo & Kolumna Ñembosako\'ipy';

  @override
  String get settingsFieldSelect => 'Poravo ne mba\'apo';

  @override
  String get settingsCustomCols => 'Kolumna jehegua (kóma rupi oñemohendáva)';

  @override
  String get settingsPersonalData => 'Tee Tavaitéva (PDF Moguerojera hag̃ua)';

  @override
  String get settingsYourName => 'Ne Réra';

  @override
  String get settingsYourAddress => 'Ne Renda';

  @override
  String get dashboardTabWeek => 'Arapy Ko\'ág̃agua';

  @override
  String get dashboardTabTotal => 'Jehecha Mboatýva';

  @override
  String get dashboardMsgStart => 'Opavave tape oñepyrũ peteĩ py\'aty rupi!';

  @override
  String get dashboardMsgGood => 'Ñepyrũ porã! Eñongatu péicha!';

  @override
  String get dashboardMsgStrong => 'Mba\'apo mbarete ko arapýpe!';

  @override
  String get dashboardMsgFantastic => 'MBA\'APO PORÃITE KO ARAPÝPE!';

  @override
  String get dashboardNewApps => 'MBA\'APO JEJERURE PYAHU';

  @override
  String get dashboardActiveApps => 'MBA\'APO JEJERURE OGUATAREÓVA';

  @override
  String get dashboardGoal => 'Arapy rape: ';

  @override
  String get dashboardThisWeek => 'Ko arapýpe ';

  @override
  String get dashboardFooter =>
      'Eikove! Peteĩteĩ py\'aty ogueraha pe mba\'apo reipotaitéva peve. 🚀';

  @override
  String get dashboardVsLastWeek => ' ko arapýma rehegua ndive ';

  @override
  String get dashboardAppsLabel => ' mba\'apo jejerure';

  @override
  String get appSearch => 'Jeheka';

  @override
  String get appSearchHint => 'Jeheka mba\'apo apoha, tenda...';

  @override
  String get appFilterAll => 'Opavave';

  @override
  String get appCheckInbox => 'Ehecha Ne Ñanduti Kuatia';

  @override
  String get appEmptyTitle => '¡Aravo pe py\'aty peteĩha hag̃ua!';

  @override
  String get appEmptyDesc =>
      'Ejapo ne mba\'apo jejerure peteĩha ha embohecha ne tape reipotaitéva peve.';

  @override
  String get calClickDetails =>
      'Eikutu ára ojehechaukávare eikuaa porãve hag̃ua.';

  @override
  String get calOverdue => 'Ohasáma';

  @override
  String get calFollowUp => 'Ñangareko Jevy';

  @override
  String get reportGeneratedOn => 'Ojejapo ko árape: ';

  @override
  String get reportNoApps => 'Ndaipíri mba\'apo jejerure ojejuhúva.';

  @override
  String get navJobcenter => 'Jobcenter Mombe\'u';

  @override
  String get settingsImapTitle => 'Ñanduti Kuatia Jehecha Mbojoja (IMAP)';

  @override
  String get settingsImapDesc => 'Omoñepyrũ ojoguáva boyke/porandu';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Ko mba\'e ojejapoteĩ gueteri. Mba\'apo apoha ha jejerure rehegua ikatu ndoikói porãi. Ehecha porãke ne mba\'ere.';

  @override
  String get settingsImapProvider => 'Apoha';

  @override
  String get settingsImapManual => 'Tee / Servidor Tee';

  @override
  String get settingsImapServer => 'Servidor IMAP';

  @override
  String get settingsImapPort => 'Puerto';

  @override
  String get settingsImapEmail => 'Ñanduti Kuatia Ra\'ãnga';

  @override
  String get settingsImapPassword => 'Ñe\'ẽñemi (App Ñe\'ẽñemi)';

  @override
  String get settingsImapSave => 'Ñongatu Marandu';

  @override
  String get settingsExportTitle => 'Marandu Moguerojera';

  @override
  String get settingsExportPdf => 'Moguerojera Jobcenter Mombe\'u (PDF)';

  @override
  String get settingsExportCsv => 'Moguerojera CSVicha';

  @override
  String get settingsExportBackup =>
      'Moguerojera Base de Datos Pytyvõhára (.sqlite)';

  @override
  String get settingsExportRestore => 'Mbojuruhei Base de Datos Pytyvõhágui';

  @override
  String get settingsExportRestart =>
      'Marandu: Oikotevẽ oñepyrũ jey app jejogueru rire.';

  @override
  String get settingsAppQuit => 'Jeheja App';

  @override
  String get appNotFoundTitle => 'Ndaipíri mba\'eve ojejuhúva.';

  @override
  String get appNotFoundDesc =>
      'Ndaipíri mba\'eve ojognávape ko\'ã filtro mohenda.';

  @override
  String get formTabBasic => 'Marandu Mboyvegua';

  @override
  String get formTabEmails => 'Ñanduti Kuatia & Ñomongeta';

  @override
  String get formTabDocs => 'Kuatiakuéra';

  @override
  String get formTabNotes => 'Marandu\'i';

  @override
  String get formBasicContact => 'Ñomongeta & Renda';

  @override
  String get formBasicSave => 'Ñongatu';

  @override
  String get formBasicInterview => 'Ñemongeta';

  @override
  String get formBasicSalary => 'Péicha Pytyvõ Jepy\'apy (€/Ary)';

  @override
  String get formBasicOpen => 'Ojepe\'áva';

  @override
  String get formBasicAccepted => 'Ñemboajepa';

  @override
  String get formBasicRejected => 'Oñemboykéva';

  @override
  String get formBasicJobLink => 'Mba\'apo Ñepyru Ñanduti Joaju';

  @override
  String get formBasicJobLinkHint =>
      'Embotýke ñanduti joaju térã emondo peteĩ PDF (techapyrã Jobcenter) emoñepyrũ hag̃ua marandu.';

  @override
  String get formBasicAutofill => 'Jehai Jeheguigua';

  @override
  String get formBasicCommute => 'Tapere Aravore (Min.)';

  @override
  String get formBasicRejectionReason => 'Mba\'ere Oñemboyke';

  @override
  String get formBasicUploadPdf => 'Térã emondo PDF';

  @override
  String get formBasicStatus => 'Reko';

  @override
  String get formBasicCompanyWeb =>
      'Mba\'apo Apoha Ñanduti Renda (techapyrã https://)';

  @override
  String get formBasicMagic => 'Jehai Jeheguigua Marangatu';

  @override
  String get formBasicDelete => 'Mbogue';

  @override
  String get formBasicSent => 'Oñemondoma';

  @override
  String get reportGeneratedAt => 'Ojejapo ko aravo:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Arapy Rape:';

  @override
  String get weeklyGoalSuffix => ' 5 mba\'apo jejerúgui';

  @override
  String get weeklyThisWeek => 'Ko arapýpe ';

  @override
  String get weeklyVs => ' mba\'apo jejerure ko arapýma rehegua ndive ';

  @override
  String get weeklyApplications => ' mba\'apo jejerure';

  @override
  String get weeklyMotivationalFooter =>
      'Eikove! Peteĩteĩ py\'aty ogueraha pe mba\'apo porãite peve. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Eikove! Peteĩteĩ py\'aty ogueraha pe mba\'apo porãite peve.';

  @override
  String get templatesTabMy => 'Che Kuatia Ñe\'ẽporã';

  @override
  String get templatesTabExamples => 'Techapyrã & Poravorã';

  @override
  String get promptTitle => 'AI Ñe\'ẽpehẽ Apoha';

  @override
  String get promptDesc =>
      'Enyhenói umi tenda rejapo hag̃ua peteĩ ñe\'ẽpehẽ porã ikatuva rehupyty ChatGPT, Claude, térã ambue AI reipotávape.';

  @override
  String get promptPosition => 'Tembiapo / Mba\'apo Réra';

  @override
  String get promptCompany => 'Mba\'apo Apoha';

  @override
  String get promptSkills => 'Ne Mba\'eporã & Tembiasakue Tenondeguáva';

  @override
  String get promptTone => 'Ñe\'ẽ ryapu';

  @override
  String get promptToneDefault => 'mba\'apohára porã ha angapyhy';

  @override
  String get promptGenerate => 'Apoha Ñe\'ẽpehẽ';

  @override
  String get tplInitiative => 'Jejerure Jeheguiete';

  @override
  String get tplReply => 'Mbohovái Mba\'apo Ñemomarandúpe';

  @override
  String get tplFollowUp => 'Nemandu\'arã / Ñangareko Jevy';

  @override
  String get tplRejection => 'Boyke Mbohovái Porã';

  @override
  String get tplTypeCover => 'JEHECHAUKA KUATIA';

  @override
  String get tplTypeSnippet => 'ÑE\'ẼPEHẼ KUATIA';

  @override
  String get noAppsFound => 'Ndaipíri mba\'apo jejerure ojejuhúva.';

  @override
  String get templatesEmptyState =>
      'Ndaipíri kuatia ñe\'ẽporã ojejapóva gueteri.';

  @override
  String get templatesEmptyStateSub =>
      'Ejapo ne ñepyrũha kuatia jehechaukaha térã ñe\'ẽpehẽ!';

  @override
  String get promptSubtitle =>
      'Enyhenói umi tenda ha rejapo peteĩ ñe\'ẽpehẽ porã ikatuva rehupyty ChatGPT, Claude, térã ambue AI reipotávape.';
}
