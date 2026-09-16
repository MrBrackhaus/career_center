// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Irish (`ga`).
class AppLocalizationsGa extends AppLocalizations {
  AppLocalizationsGa([String locale = 'ga']) : super(locale);

  @override
  String get appName => 'Lárionad Gairme';

  @override
  String get navDashboard => 'Painéal';

  @override
  String get navApplications => 'Iarratais';

  @override
  String get navCalendar => 'Féilire';

  @override
  String get navTemplates => 'Mo Doiciméid';

  @override
  String get navSettings => 'Socruithe';

  @override
  String get applicationsTitle => 'Mo Chuid Iarratas';

  @override
  String get btnNewApplication => 'Iarratas Nua';

  @override
  String get statusOpen => 'Oscailte';

  @override
  String get statusSent => 'Seolta';

  @override
  String get statusInterview => 'Agallamh';

  @override
  String get statusAccepted => 'Glactha';

  @override
  String get statusRejected => 'Diúltaithe';

  @override
  String get kanbanPreparation => '📝 San Ullmhúchán';

  @override
  String get kanbanWaiting => '⏳ Ag fanacht le freagra';

  @override
  String get kanbanInterview => '🗣️ Agallamh ar siúl';

  @override
  String get kanbanOffers => '🎉 Tairiscintí';

  @override
  String get kanbanArchive => '🗑️ Cartlann (Diúltaithe)';

  @override
  String get searchPlaceholder => 'Cuardaigh cuideachta, post...';

  @override
  String get emptyApplicationsTitle => 'Gan iarratais fós';

  @override
  String get emptyApplicationsDesc =>
      'Cosúil nach bhfuil aon iarratas curtha leis agat fós. Cliceáil ar \'Iarratas Nua\' chun tús a chur leis!';

  @override
  String get dashboardTitle => 'Staitisticí Iarratais';

  @override
  String get dashboardOverview => 'FORBREATHNÚ';

  @override
  String get dashboardApplications => 'IARRATAIS';

  @override
  String get dashboardOpen => 'OSCAILTE';

  @override
  String get dashboardRejections => 'DIÚLTAITHE';

  @override
  String get dashboardResponseRate => 'RÁTA FREAGRA';

  @override
  String get dashboardRejectionRate => 'RÁTA DIÚLTAITHE';

  @override
  String get dashboardInterviews => 'AGALLAMHACHTAÍ';

  @override
  String get dashboardCommute => 'MEÁN-TURAS OBAIR';

  @override
  String get dashboardAppsPerMonth => 'IARRATAIS SA MHÍ';

  @override
  String get dashboardTopRejectionReasons => 'PRÍOMH-CHÚISEANNA DIÚLTAITHE';

  @override
  String get dashboardNoRejectionReasons =>
      'Níl aon chúis diúltaithe taifeadta fós.';

  @override
  String get calendarTitle => 'Féilire Iarratais';

  @override
  String get calendarNoEvents => 'Gan imeachtaí ar an lá seo.';

  @override
  String get templatesTitle => 'Teimpléid & Litreacha Clúdaigh';

  @override
  String get templatesNew => 'Teimpléad Nua';

  @override
  String get templatesEmpty => 'Níl aon teimpléad cruthaithe fós.';

  @override
  String get templatesCreateFirst =>
      'Cruthaigh do chéad litir chlúdaigh nó sliocht téacs!';

  @override
  String get settingsTitle => 'Socruithe';

  @override
  String get settingsLanguage => 'Teanga / Language';

  @override
  String get settingsTheme => 'Mód Dearaidh';

  @override
  String get settingsThemeLight => 'Geal';

  @override
  String get settingsThemeDark => 'Dorcha';

  @override
  String get settingsThemeSystem => 'Réamhshocrú Córais';

  @override
  String get settingsPreset => 'Téama Réamhshocraithe';

  @override
  String get settingsAccentColor => 'Dath Aicentu';

  @override
  String get settingsJobcenterMode =>
      'Mód Ionad Fostaíochta / Gníomhaireacht Dífhostaíochta';

  @override
  String get reportTitle => 'Cruthúnas Iarrachtaí';

  @override
  String get reportSavePdf => 'Sábháil PDF';

  @override
  String get reportDate => 'DÁTA AN IARRATAIS';

  @override
  String get reportCompany => 'CUIDEACHTA';

  @override
  String get reportPosition => 'POST';

  @override
  String get reportStatus => 'STÁDAS';

  @override
  String get reportRejectionReason => 'CÚIS DIÚLTAITHE';

  @override
  String get settingsLanguageTitle => 'Teanga';

  @override
  String get settingsAppLanguage => 'Teanga an Aip';

  @override
  String get settingsDesignTitle => 'Dearadh & Pearsanú';

  @override
  String get settingsDesignMode => 'Mód Dearaidh';

  @override
  String get settingsAccentColorTitle => 'Dath Aicentu';

  @override
  String get settingsPresetTheme => 'Téama Réamhshocraithe';

  @override
  String get settingsPresetDesc => 'Cumaisc dearaidh réamhdhéanta';

  @override
  String get settingsJobcenterTitle => 'Mód an Ionaid Fostaíochta';

  @override
  String get settingsJobcenterDesc =>
      'Taispeánann sé an cluaisín \'Cruthúnas Iarrachtaí\'';

  @override
  String get settingsFieldTitle => 'Do Ghairm & Colúin Shaincheaptha';

  @override
  String get settingsFieldSelect => 'Roghnaigh gairm';

  @override
  String get settingsCustomCols => 'Colúin saincheaptha (scartha le camóg)';

  @override
  String get settingsPersonalData => 'Sonraí Pearsanta (don Easpórtáil PDF)';

  @override
  String get settingsYourName => 'Do Ainm';

  @override
  String get settingsYourAddress => 'Do Sheoladh';

  @override
  String get dashboardTabWeek => 'An tSeachtain Reatha';

  @override
  String get dashboardTabTotal => 'Forbhreathnú';

  @override
  String get dashboardMsgStart => 'Tosaíonn gach turas le haon chéim amháin!';

  @override
  String get dashboardMsgGood => 'Tús maith! Coinnigh ort!';

  @override
  String get dashboardMsgStrong => 'Feidhmíocht láidir an tseachtain seo!';

  @override
  String get dashboardMsgFantastic => 'OBAIR FANTAISIEACH AN TSEACHTAIN SEO!';

  @override
  String get dashboardNewApps => 'IARRATAIS NUA';

  @override
  String get dashboardActiveApps => 'IARRATAIS GHNÍOMHACH';

  @override
  String get dashboardGoal => 'Sprioc seachtainiúil: ';

  @override
  String get dashboardThisWeek => 'An tseachtain seo ';

  @override
  String get dashboardFooter =>
      'Coinnigh ort! Tugann gach céim níos gaire duit do phost aisling. 🚀';

  @override
  String get dashboardVsLastWeek =>
      ' i gcomparáid leis an tseachtain seo caite ';

  @override
  String get dashboardAppsLabel => ' iarratas';

  @override
  String get appSearch => 'Cuardaigh';

  @override
  String get appSearchHint => 'Cuardaigh cuideachta, post, áit...';

  @override
  String get appFilterAll => 'Gach uile';

  @override
  String get appCheckInbox => 'Seiceáil an Bosca Isteach';

  @override
  String get appEmptyTitle => 'Am don chéad chéim!';

  @override
  String get appEmptyDesc =>
      'Cruthaigh do chéad iarratas agus eagraigh do bhealach chuig do phost aisling.';

  @override
  String get calClickDetails => 'Cliceáil ar lá aibhsithe le haghaidh sonraí.';

  @override
  String get calOverdue => 'Sáraithe';

  @override
  String get calFollowUp => 'Leanúint suas';

  @override
  String get reportGeneratedOn => 'Ginte ar: ';

  @override
  String get reportNoApps => 'Níor aimsíodh aon iarratas.';

  @override
  String get navJobcenter => 'Tuairisc Ionad Fostaíochta';

  @override
  String get settingsImapTitle => 'Sioncronú Ríomhphoist (IMAP)';

  @override
  String get settingsImapDesc =>
      'Faigheann diúltuithe/cuireadh go huathoibríoch';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Tá an ghné seo fós i gcéim fhorbartha. D\'fhéadfadh sé nach mbeadh bhrath uathoibríoch ar ainmneacha cuideachtaí agus iarratais cruinn. Seiceáil na hiontrálacha allmhairithe de láimh le do thoil.';

  @override
  String get settingsImapProvider => 'Soláthraí';

  @override
  String get settingsImapManual => 'Láimhe / Freastalaí Saincheaptha';

  @override
  String get settingsImapServer => 'Freastalaí IMAP';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'Seoladh Ríomhphoist';

  @override
  String get settingsImapPassword => 'Pasfhocal (Pasfhocal Aip)';

  @override
  String get settingsImapSave => 'Sábháil Sonraí';

  @override
  String get settingsExportTitle => 'Easpórtáil Sonraí';

  @override
  String get settingsExportPdf => 'Easpórtáil Tuairisc Ionad Fostaíochta (PDF)';

  @override
  String get settingsExportCsv => 'Easpórtáil mar CSV';

  @override
  String get settingsExportBackup =>
      'Easpórtáil Cúltaca Bunachar Sonraí (.sqlite)';

  @override
  String get settingsExportRestore => 'Athchóirigh Bunachar Sonraí ó Chúltaca';

  @override
  String get settingsExportRestart =>
      'Eolas: Tá gá le hathtosú aipe tar éis allmhairiú.';

  @override
  String get settingsAppQuit => 'Scor an Aip';

  @override
  String get appNotFoundTitle => 'Níor aimsíodh aon rud.';

  @override
  String get appNotFoundDesc =>
      'Níl aon mheaitseáil ann do na socruithe scagaire seo.';

  @override
  String get formTabBasic => 'Bunsonraí';

  @override
  String get formTabEmails => 'Ríomhphoist & Teagmhálacha';

  @override
  String get formTabDocs => 'Doiciméid';

  @override
  String get formTabNotes => 'Nótaí';

  @override
  String get formBasicContact => 'Teagmháil & Seoladh';

  @override
  String get formBasicSave => 'Sábháil';

  @override
  String get formBasicInterview => 'Agallamh';

  @override
  String get formBasicSalary => 'Ionchas Tuarastail (€/Blian)';

  @override
  String get formBasicOpen => 'Oscailte';

  @override
  String get formBasicAccepted => 'Tairiscint';

  @override
  String get formBasicRejected => 'Diúltaithe';

  @override
  String get formBasicJobLink => 'Nasc chuig Fógra Poist';

  @override
  String get formBasicJobLinkHint =>
      'Greamaigh nasc poist nó uaslódáil PDF (m.sh., Ionad Fostaíochta) chun sonraí a bhaint as.';

  @override
  String get formBasicAutofill => 'Líonadh Uathoibríoch';

  @override
  String get formBasicCommute => 'Am Taistil (Min.)';

  @override
  String get formBasicRejectionReason => 'Cúis Diúltaithe';

  @override
  String get formBasicUploadPdf => 'Nó uaslódáil PDF';

  @override
  String get formBasicStatus => 'Stádas';

  @override
  String get formBasicCompanyWeb =>
      'Suíomh Gréasáin Cuideachta (m.sh., https://)';

  @override
  String get formBasicMagic => 'Líonadh Uathoibríoch Draíochta';

  @override
  String get formBasicDelete => 'Scrios';

  @override
  String get formBasicSent => 'Seolta';

  @override
  String get reportGeneratedAt => 'Ginte ag:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Sprioc Seachtainiúil:';

  @override
  String get weeklyGoalSuffix => ' as 5 iarratas';

  @override
  String get weeklyThisWeek => 'An tseachtain seo ';

  @override
  String get weeklyVs => ' iarratas i gcomparáid leis an tseachtain seo caite ';

  @override
  String get weeklyApplications => ' iarratas';

  @override
  String get weeklyMotivationalFooter =>
      'Coinnigh ort! Tugann gach céim níos gaire duit don phost foirfe. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Coinnigh ort! Tugann gach céim níos gaire duit don phost foirfe.';

  @override
  String get templatesTabMy => 'Mo Theimpléid';

  @override
  String get templatesTabExamples => 'Patrúin & Samplaí';

  @override
  String get promptTitle => 'Gineadóir Pras AI';

  @override
  String get promptDesc =>
      'Líon isteach na réimsí chun pras gairmiúil a ghiniúint a fhéadfaidh tú a úsáid in ChatGPT, Claude, nó aon AI eile de do rogha féin.';

  @override
  String get promptPosition => 'Post / Teideal Poist';

  @override
  String get promptCompany => 'Cuideachta';

  @override
  String get promptSkills => 'Do Scileanna & Taithí is Fearr';

  @override
  String get promptTone => 'Ton';

  @override
  String get promptToneDefault => 'gairmiúil agus cairdiúil';

  @override
  String get promptGenerate => 'Gin Pras';

  @override
  String get tplInitiative => 'Iarratas Spontáineach';

  @override
  String get tplReply => 'Freagra ar Fhógra Poist';

  @override
  String get tplFollowUp => 'Meabhrúchán / Leanúint suas';

  @override
  String get tplRejection => 'Freagra Diúltaithe Cineálta';

  @override
  String get tplTypeCover => 'LITIR CHLÚDAIGH';

  @override
  String get tplTypeSnippet => 'SLIOCHT TÉACS';

  @override
  String get noAppsFound => 'Níor aimsíodh aon iarratas.';

  @override
  String get templatesEmptyState => 'Níl aon teimpléad cruthaithe fós.';

  @override
  String get templatesEmptyStateSub =>
      'Cruthaigh do chéad litir chlúdaigh nó sliocht téacs!';

  @override
  String get promptSubtitle =>
      'Líon isteach na réimsí agus gin pras gairmiúil a fhéadfaidh tú a úsáid in ChatGPT, Claude, nó aon AI eile de do rogha féin.';
}
