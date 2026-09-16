// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String get appName => 'Կარიերային կենտրոն';

  @override
  String get navDashboard => 'Վահանակ';

  @override
  String get navApplications => 'Դիմումներ';

  @override
  String get navCalendar => 'Օրացույց';

  @override
  String get navTemplates => 'Իմ փաստաթղթերը';

  @override
  String get navSettings => 'Կարգավորումներ';

  @override
  String get applicationsTitle => 'Իմ դիմումները';

  @override
  String get btnNewApplication => 'Նոր դիմում';

  @override
  String get statusOpen => 'Բաց';

  @override
  String get statusSent => 'Ուղարկված';

  @override
  String get statusInterview => 'Հարցազրույց';

  @override
  String get statusAccepted => 'Ընդունված';

  @override
  String get statusRejected => 'Մերժված';

  @override
  String get kanbanPreparation => '📝 Նախապատրաստման փուլում';

  @override
  String get kanbanWaiting => '⏳ Սպասում ենք պատասխանի';

  @override
  String get kanbanInterview => '🗣️ Հարցազրույցի փուլում';

  @override
  String get kanbanOffers => '🎉 Առաջարկներ';

  @override
  String get kanbanArchive => '🗑️ Արխիվ (Մերժված)';

  @override
  String get searchPlaceholder => 'Որոնել ընկերություն, հաստիք...';

  @override
  String get emptyApplicationsTitle => 'Դեռևս դիմումներ չկան';

  @override
  String get emptyApplicationsDesc =>
      'Կարծես թե դեռևս որևէ դիմում չեք ավելացրել: Սեղմեք «Նոր դիմում»՝ սկսելու համար:';

  @override
  String get dashboardTitle => 'Դիմումների վիճակագրություն';

  @override
  String get dashboardOverview => 'ԱԿՆԱՐԿ';

  @override
  String get dashboardApplications => 'ԴԻՄՈՒՄՆԵՐ';

  @override
  String get dashboardOpen => 'ԲԱՑ';

  @override
  String get dashboardRejections => 'ՄԵՐԺՎԱԾ';

  @override
  String get dashboardResponseRate => 'ՊԱՏԱՍԽԱՆԻ ՏՈԿՈՍԱՉԱՓ';

  @override
  String get dashboardRejectionRate => 'ՄԵՐԺՄԱՆ ՏՈԿՈՍԱՉԱՓ';

  @override
  String get dashboardInterviews => 'ՀԱՐՑԱԶՐՈՒՅՑՆԵՐ';

  @override
  String get dashboardCommute => 'ՄԻՋԻՆ ՃԱՆԱՊԱՐՀ';

  @override
  String get dashboardAppsPerMonth => 'ԴԻՄՈՒՄՆԵՐ ԱՄՍԱԿԱՆ ԿՏՐՎԱԾՔՈՎ';

  @override
  String get dashboardTopRejectionReasons => 'ՄԵՐԺՄԱՆ ՀԻՄՆԱԿԱՆ ՊԱՏՃԱՌՆԵՐ';

  @override
  String get dashboardNoRejectionReasons =>
      'Մերժման պատճառներ դեռևս չեն գրանցվել:';

  @override
  String get calendarTitle => 'Դիմումների օրացույց';

  @override
  String get calendarNoEvents => 'Այս օրը իրադարձություններ չկան:';

  @override
  String get templatesTitle => 'Ձևանմուշներ և ուղեկցող նամակներ';

  @override
  String get templatesNew => 'Նոր ձևանմուշ';

  @override
  String get templatesEmpty => 'Դեռևս ձևանմուշներ ստեղծված չեն:';

  @override
  String get templatesCreateFirst =>
      'Ստեղծեք ձեր առաջին ուղեկցող նամակը կամ տեքստային հատվածը:';

  @override
  String get settingsTitle => 'Կարգավորումներ';

  @override
  String get settingsLanguage => 'Լեզու / Language';

  @override
  String get settingsTheme => 'Ձևավորման ռեժիմ';

  @override
  String get settingsThemeLight => 'Բաց';

  @override
  String get settingsThemeDark => 'Մութ';

  @override
  String get settingsThemeSystem => 'Համակարգային լռելյայն';

  @override
  String get settingsPreset => 'Պատրաստի թեմա';

  @override
  String get settingsAccentColor => 'Շեշտադրման գույն';

  @override
  String get settingsJobcenterMode =>
      'Զբաղվածության կենտրոնի / Գործազրկության գործակալության ռեժիմ';

  @override
  String get reportTitle => 'Աշխատանք փնտրելու ջանքերի ապացույց';

  @override
  String get reportSavePdf => 'Պահպանել PDF';

  @override
  String get reportDate => 'ԴԻՄՈՒՄԻ ԱՄՍԱԹԻՎ';

  @override
  String get reportCompany => 'ԸՆԿԵՐՈՒԹՅՈՒՆ';

  @override
  String get reportPosition => 'ՀԱՍՏԻՔ';

  @override
  String get reportStatus => 'ԿԱՐԳԱՎԻՃԱԿ';

  @override
  String get reportRejectionReason => 'ՄԵՐԺՄԱՆ ՊԱՏՃԱՌ';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsAppLanguage => 'Հավելվածի լեզու';

  @override
  String get settingsDesignTitle => 'Ձևավորում և անհատականացում';

  @override
  String get settingsDesignMode => 'Ձևավորման ռեժիմ';

  @override
  String get settingsAccentColorTitle => 'Շեշտադրման գույն';

  @override
  String get settingsPresetTheme => 'Պատրաստի թեմա';

  @override
  String get settingsPresetDesc =>
      'Նախապես պատրաստված ձևավորման համադրություններ';

  @override
  String get settingsJobcenterTitle => 'Զբաղվածության կենտրոնի ռեժիմ';

  @override
  String get settingsJobcenterDesc => 'Ցուցադրում է «Ապացույց» ներդիրը';

  @override
  String get settingsFieldTitle =>
      'Ձեր մասնագիտությունը և հարմարեցված սյունակները';

  @override
  String get settingsFieldSelect => 'Ընտրել մասնագիտությունը';

  @override
  String get settingsCustomCols =>
      'Հարմարեցված սյունակներ (բաժանված ստորակետերով)';

  @override
  String get settingsPersonalData => 'Անձնական տվյալներ (PDF արտահանման համար)';

  @override
  String get settingsYourName => 'Ձեր անունը';

  @override
  String get settingsYourAddress => 'Ձեր հասցեն';

  @override
  String get dashboardTabWeek => 'Ընթացիկ շաբաթ';

  @override
  String get dashboardTabTotal => 'Ընդհանուր';

  @override
  String get dashboardMsgStart =>
      'Յուրաքանչյուր ճանապարհորդություն սկսվում է առաջին քայլից:';

  @override
  String get dashboardMsgGood => 'Լավ սկիզբ է: Շարունակեք այդպես:';

  @override
  String get dashboardMsgStrong => 'Հիանալի արդյունք այս շաբաթ:';

  @override
  String get dashboardMsgFantastic => 'ՀՐԱՇԱԼԻ ԱՇԽԱՏԱՆՔ ԱՅՍ ՇԱԲԱԹ:';

  @override
  String get dashboardNewApps => 'ՆՈՐ ԴԻՄՈՒՄՆԵՐ';

  @override
  String get dashboardActiveApps => 'ԱԿՏԻՎ ԴԻՄՈՒՄՆԵՐ';

  @override
  String get dashboardGoal => 'Շաբաթական նպատակ՝ ';

  @override
  String get dashboardThisWeek => 'Այս շաբաթ ';

  @override
  String get dashboardFooter =>
      'Շարունակեք առաջ: Յուրաքանչյուր քայլ ձեզ մոտեցնում է ձեր երազանքի աշխատանքին: 🚀';

  @override
  String get dashboardVsLastWeek => ' անցյալ շաբաթվա համեմատ ';

  @override
  String get dashboardAppsLabel => ' դիմում';

  @override
  String get appSearch => 'Որոնել';

  @override
  String get appSearchHint => 'Որոնել ընկերություն, հաստիք, վայր...';

  @override
  String get appFilterAll => 'Բոլորը';

  @override
  String get appCheckInbox => 'Ստուգել մուտքային նամակները';

  @override
  String get appEmptyTitle => 'Առաջին քայլի ժամանակն է:';

  @override
  String get appEmptyDesc =>
      'Ստեղծեք ձեր առաջին դիմումը և կազմակերպեք ձեր ուղին դեպի երազանքի աշխատանքը:';

  @override
  String get calClickDetails => 'Մանրամասների համար սեղմեք ընդգծված օրվա վրա:';

  @override
  String get calOverdue => 'Ժամկետանց';

  @override
  String get calFollowUp => 'Հետևողականություն';

  @override
  String get reportGeneratedOn => 'Գեներացված է՝ ';

  @override
  String get reportNoApps => 'Դիմումներ չեն գտնվել:';

  @override
  String get navJobcenter => 'Զբաղվածության կենտրոնի հաշվետվություն';

  @override
  String get settingsImapTitle => 'Էլ. փոստի համաժամացում (IMAP)';

  @override
  String get settingsImapDesc =>
      'Ավտոմատ կերպով ստանում է մերժումները և հրավերները';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Այս գործառույթը դեռևս մշակման փուլում է: Ընկերությունների անվանումների և դիմումների ավտոմատ հայտնաբերումը կարող է անճշտ լինել: Խնդրում ենք ներմուծված գրառումները ստուգել ձեռքով:';

  @override
  String get settingsImapProvider => 'Մատակարար';

  @override
  String get settingsImapManual => 'Ձեռքով / Անհատական սերվեր';

  @override
  String get settingsImapServer => 'IMAP սերվեր';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'Էլ. փոստի հասցե';

  @override
  String get settingsImapPassword => 'Գաղտնաբառ (Հավելվածի գաղտնաբառ)';

  @override
  String get settingsImapSave => 'Պահպանել տվյալները';

  @override
  String get settingsExportTitle => 'Տվյալների արտահանում';

  @override
  String get settingsExportPdf =>
      'Արտահանել զբաղվածության կենտրոնի հաշվետվությունը (PDF)';

  @override
  String get settingsExportCsv => 'Արտահանել որպես CSV';

  @override
  String get settingsExportBackup =>
      'Արտահանել տվյալների բազայի կրկնօրինակը (.sqlite)';

  @override
  String get settingsExportRestore =>
      'Վերականգնել տվյալների բազան կրկնօրինակից';

  @override
  String get settingsExportRestart =>
      'Տեղեկություն. Ներմուծումից հետո հավելվածը պահանջում է վերագործարկում:';

  @override
  String get settingsAppQuit => 'Փակել հավելվածը';

  @override
  String get appNotFoundTitle => 'Ոչինչ չի գտնվել:';

  @override
  String get appNotFoundDesc =>
      'Այս զտիչի կարգավորումներին համապատասխանող արդյունքներ չկան:';

  @override
  String get formTabBasic => 'Հիմնական տվյալներ';

  @override
  String get formTabEmails => 'Էլ. փոստեր և կոնտակտներ';

  @override
  String get formTabDocs => 'Փաստաթղթեր';

  @override
  String get formTabNotes => 'Նշումներ';

  @override
  String get formBasicContact => 'Կոնտակտ և հասցե';

  @override
  String get formBasicSave => 'Պահպանել';

  @override
  String get formBasicInterview => 'Հարցազրույց';

  @override
  String get formBasicSalary => 'Ակնկալվող աշխատավարձ (€/տարի)';

  @override
  String get formBasicOpen => 'Բաց';

  @override
  String get formBasicAccepted => 'Առաջարկ';

  @override
  String get formBasicRejected => 'Մերժված';

  @override
  String get formBasicJobLink => 'Հղում աշխատանքի հայտարարությանը';

  @override
  String get formBasicJobLinkHint =>
      'Տեղադրեք աշխատանքի հղումը կամ վերբեռնեք PDF (օր.՝ Զբաղվածության կենտրոնից) տվյալները դուրս բերելու համար:';

  @override
  String get formBasicAutofill => 'Ավտոլրացում';

  @override
  String get formBasicCommute => 'Ճանապարհի տևողությունը (րոպե)';

  @override
  String get formBasicRejectionReason => 'Մերժման պատճառ';

  @override
  String get formBasicUploadPdf => 'Կամ վերբեռնել PDF';

  @override
  String get formBasicStatus => 'Կարգավիճակ';

  @override
  String get formBasicCompanyWeb => 'Ընկերության կայք (օր.՝ https://)';

  @override
  String get formBasicMagic => 'Magic Auto-Fill';

  @override
  String get formBasicDelete => 'Ջնջել';

  @override
  String get formBasicSent => 'Ուղարկված';

  @override
  String get reportGeneratedAt => 'Գեներացված է՝';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Շաբաթական նպատակ՝';

  @override
  String get weeklyGoalSuffix => ' 5 դիմումից';

  @override
  String get weeklyThisWeek => 'Այս շաբաթ ';

  @override
  String get weeklyVs => ' դիմում անցյալ շաբաթվա համեմատ ';

  @override
  String get weeklyApplications => ' դիմում';

  @override
  String get weeklyMotivationalFooter =>
      'Շարունակեք այդպես: Յուրաքանչյուր քայլ ձեզ մոտեցնում է կատարյալ աշխատանքին: 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Շարունակեք այդպես: Յուրաքանչյուր քայլ ձեզ մոտեցնում է կատարյալ աշխատանքին:';

  @override
  String get templatesTabMy => 'Իմ ձևանմուշները';

  @override
  String get templatesTabExamples => 'Օրինակներ և նմուշներ';

  @override
  String get promptTitle => 'AI հարցումների գեներատոր';

  @override
  String get promptDesc =>
      'Լրացրեք դաշտերը՝ ստեղծելու պրոֆեսիոնալ հարցում, որը կարող եք օգտագործել ChatGPT-ում, Claude-ում կամ ձեր նախընտրած ցանկացած այլ ԱԲ-ում:';

  @override
  String get promptPosition => 'Հաստիք / Աշխատանքի անվանում';

  @override
  String get promptCompany => 'Ընկերություն';

  @override
  String get promptSkills => 'Ձեր լավագույն հմտություններն ու փորձը';

  @override
  String get promptTone => 'Տոնայնություն';

  @override
  String get promptToneDefault => 'պրոֆեսիոնալ և բարեհամբույր';

  @override
  String get promptGenerate => 'Գեներացնել հարցումը';

  @override
  String get tplInitiative => 'Նախաձեռնողական դիմում';

  @override
  String get tplReply => 'Արձագանք աշխատանքի հայտարարությանը';

  @override
  String get tplFollowUp => 'Հիշեցում / Հետադարձ կապ';

  @override
  String get tplRejection => 'Մերժման քաղաքավարի պատասխան';

  @override
  String get tplTypeCover => 'ՈՒՂԵԿՑՈՂ ՆԱՄԱԿ';

  @override
  String get tplTypeSnippet => 'ՏԵՔՍՏԱՅԻՆ ՀԱՏՎԱԾ';

  @override
  String get noAppsFound => 'Դիմումներ չեն գտնվել:';

  @override
  String get templatesEmptyState => 'Դեռևս ձևանմուշներ ստեղծված չեն:';

  @override
  String get templatesEmptyStateSub =>
      'Ստեղծեք ձեր առաջին ուղեկցող նամակը կամ տեքստային հատվածը:';

  @override
  String get promptSubtitle =>
      'Լրացրեք դաշտերը և ստեղծեք պրոֆեսիոնալ հարցում, որը կարող եք օգտագործել ChatGPT-ում, Claude-ում կամ ձեր նախընտրած ցանկացած այլ ԱԲ-ում:';
}
