// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Georgian (`ka`).
class AppLocalizationsKa extends AppLocalizations {
  AppLocalizationsKa([String locale = 'ka']) : super(locale);

  @override
  String get appName => 'კარიერული ცენტრი';

  @override
  String get navDashboard => 'დაფა';

  @override
  String get navApplications => 'განაცხადები';

  @override
  String get navCalendar => 'კალენდარი';

  @override
  String get navTemplates => 'ჩემი დოკუმენტები';

  @override
  String get navSettings => 'პარამეტრები';

  @override
  String get applicationsTitle => 'ჩემი განაცხადები';

  @override
  String get btnNewApplication => 'ახალი განაცხადი';

  @override
  String get statusOpen => 'ღია';

  @override
  String get statusSent => 'გაგზავნილი';

  @override
  String get statusInterview => 'გასაუბრება';

  @override
  String get statusAccepted => 'მიღებული';

  @override
  String get statusRejected => 'უარყოფილი';

  @override
  String get kanbanPreparation => '📝 მომზადებაში';

  @override
  String get kanbanWaiting => '⏳ პასუხის მოლოდინში';

  @override
  String get kanbanInterview => '🗣️ გასაუბრებაზე';

  @override
  String get kanbanOffers => '🎉 შემოთავაზებები';

  @override
  String get kanbanArchive => '🗑️ არქივი (უარყოფილი)';

  @override
  String get searchPlaceholder => 'ძებნა კომპანიის, პოზიციის...';

  @override
  String get emptyApplicationsTitle => 'განაცხადები ჯერ არ არის';

  @override
  String get emptyApplicationsDesc =>
      'როგორც ჩანს, ჯერ არ გიმოთხოვნიათ. დააჭირეთ „ახალი განაცხადი“-ს დასაწყებად!';

  @override
  String get dashboardTitle => 'განაცხადების სტატისტიკა';

  @override
  String get dashboardOverview => 'მიმოხილვა';

  @override
  String get dashboardApplications => 'განაცხადები';

  @override
  String get dashboardOpen => 'ღია';

  @override
  String get dashboardRejections => 'უარყოფილი';

  @override
  String get dashboardResponseRate => 'პასუხების მაჩვენებელი';

  @override
  String get dashboardRejectionRate => 'უარის მაჩვენებელი';

  @override
  String get dashboardInterviews => 'გასაუბრებები';

  @override
  String get dashboardCommute => 'საშ. მგზავრობის დრო';

  @override
  String get dashboardAppsPerMonth => 'განაცხადები თვეში';

  @override
  String get dashboardTopRejectionReasons => 'უარის ძირითადი მიზეზები';

  @override
  String get dashboardNoRejectionReasons =>
      'უარის მიზეზები ჯერ არ არის ჩაწერილი.';

  @override
  String get calendarTitle => 'განაცხადების კალენდარი';

  @override
  String get calendarNoEvents => 'ამ დღეს მოვლენები არ არის.';

  @override
  String get templatesTitle => 'შაბლონები და სამოტივაციო წერილები';

  @override
  String get templatesNew => 'ახალი შაბლონი';

  @override
  String get templatesEmpty => 'შაბლონები ჯერ არ არის შექმნილი.';

  @override
  String get templatesCreateFirst =>
      'შექმენით თქვენი პირველი სამოტივაციო წერილი ან ტექსტის ნაწყვეტი!';

  @override
  String get settingsTitle => 'პარამეტრები';

  @override
  String get settingsLanguage => 'ენა / Language';

  @override
  String get settingsTheme => 'დიზაინის რეჟიმი';

  @override
  String get settingsThemeLight => 'ნათელი';

  @override
  String get settingsThemeDark => 'მუქი';

  @override
  String get settingsThemeSystem => 'სისტემური';

  @override
  String get settingsPreset => 'წინასწარ განსაზღვრული თემა';

  @override
  String get settingsAccentColor => 'აქცენტის ფერი';

  @override
  String get settingsJobcenterMode =>
      'ჯობსცენტრის / უმუშევრობის სააგენტოს რეჟიმი';

  @override
  String get reportTitle => 'ძალისხმევის დადასტურება';

  @override
  String get reportSavePdf => 'PDF-ის შენახვა';

  @override
  String get reportDate => 'განაცხადის თარიღი';

  @override
  String get reportCompany => 'კომპანია';

  @override
  String get reportPosition => 'პოზიცია';

  @override
  String get reportStatus => 'სტატუსი';

  @override
  String get reportRejectionReason => 'უარის მიზეზი';

  @override
  String get settingsLanguageTitle => 'ენა';

  @override
  String get settingsAppLanguage => 'აპლიკაციის ენა';

  @override
  String get settingsDesignTitle => 'დიზაინი და პერსონალიზაცია';

  @override
  String get settingsDesignMode => 'დიზაინის რეჟიმი';

  @override
  String get settingsAccentColorTitle => 'აქცენტის ფერი';

  @override
  String get settingsPresetTheme => 'წინასწარ განსაზღვრული თემა';

  @override
  String get settingsPresetDesc => 'წინასწარ შექმნილი დიზაინის კომბინაციები';

  @override
  String get settingsJobcenterTitle => 'ჯობსცენტრის რეჟიმი';

  @override
  String get settingsJobcenterDesc =>
      'აჩვენებს „ძალისხმევის დადასტურების“ ჩანართს';

  @override
  String get settingsFieldTitle => 'თქვენი პროფესია და მორგებული სვეტები';

  @override
  String get settingsFieldSelect => 'აირჩიეთ პროფესია';

  @override
  String get settingsCustomCols => 'მორგებული სვეტები (მძიმით გამოყოფილი)';

  @override
  String get settingsPersonalData => 'პირადი მონაცემები (PDF ექსპორტისთვის)';

  @override
  String get settingsYourName => 'თქვენი სახელი';

  @override
  String get settingsYourAddress => 'თქვენი მისამართი';

  @override
  String get dashboardTabWeek => 'მიმდინარე კვირა';

  @override
  String get dashboardTabTotal => 'მიმოხილვა';

  @override
  String get dashboardMsgStart => 'ყველა მოგზაურობა ერთი ნაბიჯით იწყება!';

  @override
  String get dashboardMsgGood => 'კარგი დასაწყისია! ასე გააგრძელეთ!';

  @override
  String get dashboardMsgStrong => 'ძლიერი შედეგი ამ კვირაში!';

  @override
  String get dashboardMsgFantastic => 'ფანტასტიკური შედეგი ამ კვირაში!';

  @override
  String get dashboardNewApps => 'ახალი განაცხადები';

  @override
  String get dashboardActiveApps => 'აქტიური განაცხადები';

  @override
  String get dashboardGoal => 'ყოველკვირეული მიზანი: ';

  @override
  String get dashboardThisWeek => 'ამ კვირაში ';

  @override
  String get dashboardFooter =>
      'განაგრძეთ! ყოველი ნაბიჯი გაახლოებთ თქვენს ოცნების სამუშაოსთან. 🚀';

  @override
  String get dashboardVsLastWeek => ' გასულ კვირასთან შედარებით ';

  @override
  String get dashboardAppsLabel => ' განაცხადი';

  @override
  String get appSearch => 'ძებნა';

  @override
  String get appSearchHint => 'მოძებნეთ კომპანია, პოზიცია, მდებარეობა...';

  @override
  String get appFilterAll => 'ყველა';

  @override
  String get appCheckInbox => 'შემოსულების შემოწმება';

  @override
  String get appEmptyTitle => 'პირველი ნაბიჯის დროა!';

  @override
  String get appEmptyDesc =>
      'შექმენით თქვენი პირველი განაცხადი და მოაწყეთ თქვენი გზა ოცნების სამუშაოსკენ.';

  @override
  String get calClickDetails => 'დეტალებისთვის დააჭირეთ მონიშნულ დღეს.';

  @override
  String get calOverdue => 'ვადაგასული';

  @override
  String get calFollowUp => 'მიყოლა';

  @override
  String get reportGeneratedOn => 'გენერირებულია: ';

  @override
  String get reportNoApps => 'განაცხადები ვერ მოიძებნა.';

  @override
  String get navJobcenter => 'ჯობსცენტრის ანგარიში';

  @override
  String get settingsImapTitle => 'ელფოსტის სინქრონიზაცია (IMAP)';

  @override
  String get settingsImapDesc => 'ავტომატურად იღებს უარს / მოწვევებს';

  @override
  String get settingsImapExp => 'ექსპერიმენტული';

  @override
  String get settingsImapWarning =>
      'ეს ფუნქცია ჯერ კიდევ დამუშავების პროცესშია. კომპანიის სახელებისა და განაცხადების ავტომატური ამოცნობა შესაძლოა არაზუსტი იყოს. გთხოვთ, ხელით შეამოწმოთ იმპორტირებული ჩანაწერები.';

  @override
  String get settingsImapProvider => 'პროვაიდერი';

  @override
  String get settingsImapManual => 'ხელით / მორგებული სერვერი';

  @override
  String get settingsImapServer => 'IMAP სერვერი';

  @override
  String get settingsImapPort => 'პორტი';

  @override
  String get settingsImapEmail => 'ელფოსტის მისამართი';

  @override
  String get settingsImapPassword => 'პაროლი (აპლიკაციის პაროლი)';

  @override
  String get settingsImapSave => 'მონაცემების შენახვა';

  @override
  String get settingsExportTitle => 'მონაცემების ექსპორტი';

  @override
  String get settingsExportPdf => 'ჯობსცენტრის ანგარიშის ექსპორტი (PDF)';

  @override
  String get settingsExportCsv => 'CSV-ს ექსპორტი';

  @override
  String get settingsExportBackup =>
      'მონაცემთა ბაზის სარეზერვო ასლის ექსპორტი (.sqlite)';

  @override
  String get settingsExportRestore =>
      'მონაცემთა ბაზის აღდგენა სარეზერვო ასლიდან';

  @override
  String get settingsExportRestart =>
      'ინფორმაცია: იმპორტის შემდეგ აპლიკაციის გადატვირთვაა საჭირო.';

  @override
  String get settingsAppQuit => 'აპლიკაციის დახურვა';

  @override
  String get appNotFoundTitle => 'არაფერი მოიძებნა.';

  @override
  String get appNotFoundDesc => 'ფილტრის ამ პარამეტრებით დამთხვევები არ არის.';

  @override
  String get formTabBasic => 'ძირითადი მონაცემები';

  @override
  String get formTabEmails => 'ელფოსტა და კონტაქტები';

  @override
  String get formTabDocs => 'დოკუმენტები';

  @override
  String get formTabNotes => 'შენიშვნები';

  @override
  String get formBasicContact => 'კონტაქტი და მისამართი';

  @override
  String get formBasicSave => 'შენახვა';

  @override
  String get formBasicInterview => 'გასაუბრება';

  @override
  String get formBasicSalary => 'სასურველი ხელფასი (€/წელიწადში)';

  @override
  String get formBasicOpen => 'ღია';

  @override
  String get formBasicAccepted => 'შემოთავაზება';

  @override
  String get formBasicRejected => 'უარყოფილი';

  @override
  String get formBasicJobLink => 'ვაკანსიის ბმული';

  @override
  String get formBasicJobLinkHint =>
      'ჩასვით ვაკანსიის ბმული ან ატვირთეთ PDF (მაგ., ჯობსცენტრიდან) მონაცემების ამოსაღებად.';

  @override
  String get formBasicAutofill => 'ავტომატური შევსება';

  @override
  String get formBasicCommute => 'მგზავრობის დრო (წთ.)';

  @override
  String get formBasicRejectionReason => 'უარის მიზეზი';

  @override
  String get formBasicUploadPdf => 'ან ატვირთეთ PDF';

  @override
  String get formBasicStatus => 'სტატუსი';

  @override
  String get formBasicCompanyWeb => 'კომპანიის ვებსაიტი (მაგ., https://)';

  @override
  String get formBasicMagic => 'ჯადოსნური ავტომატური შევსება';

  @override
  String get formBasicDelete => 'წაშლა';

  @override
  String get formBasicSent => 'გაგზავნილი';

  @override
  String get reportGeneratedAt => 'გენერირებულია:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'ყოველკვირეული მიზანი:';

  @override
  String get weeklyGoalSuffix => ' 5 განაცხადიდან';

  @override
  String get weeklyThisWeek => 'ამ კვირაში ';

  @override
  String get weeklyVs => ' განაცხადი გასულ კვირასთან შედარებით ';

  @override
  String get weeklyApplications => ' განაცხადი';

  @override
  String get weeklyMotivationalFooter =>
      'განაგრძეთ! ყოველი ნაბიჯი უფრო გაახლოებთ სრულყოფილ სამუშაოსთან. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'განაგრძეთ! ყოველი ნაბიჯი უფრო გაახლოებთ სრულყოფილ სამუშაოსთან.';

  @override
  String get templatesTabMy => 'ჩემი შაბლონები';

  @override
  String get templatesTabExamples => 'ნიმუშები და მაგალითები';

  @override
  String get promptTitle => 'AI პრომპტის გენერატორი';

  @override
  String get promptDesc =>
      'შეავსეთ ველები პროფესიონალური პრომპტის გენერაციისთვის, რომლის გამოყენებაც შეგიძლიათ ChatGPT-ში, Claude-ში ან თქვენთვის სასურველ სხვა AI-ში.';

  @override
  String get promptPosition => 'პოზიცია / ვაკანსიის დასახელება';

  @override
  String get promptCompany => 'კომპანია';

  @override
  String get promptSkills => 'თქვენი ძირითადი უნარები და გამოცდილება';

  @override
  String get promptTone => 'ტონი';

  @override
  String get promptToneDefault => 'პროფესიონალური და მეგობრული';

  @override
  String get promptGenerate => 'პრომპტის გენერაცია';

  @override
  String get tplInitiative => 'ინიციატივითი განაცხადი';

  @override
  String get tplReply => 'პასუხი ვაკანსიაზე';

  @override
  String get tplFollowUp => 'შეხსენება / მიყოლა';

  @override
  String get tplRejection => 'თავაზიანი პასუხი უარზე';

  @override
  String get tplTypeCover => 'სამოტივაციო წერილი';

  @override
  String get tplTypeSnippet => 'ტექსტის ნაწყვეტი';

  @override
  String get noAppsFound => 'განაცხადები ვერ მოიძებნა.';

  @override
  String get templatesEmptyState => 'შაბლონები ჯერ არ არის შექმნილი.';

  @override
  String get templatesEmptyStateSub =>
      'შექმენით თქვენი პირველი სამოტივაციო წერილი ან ტექსტის ნაწყვეტი!';

  @override
  String get promptSubtitle =>
      'შეავსეთ ველები და შექმენით პროფესიონალური პრომპტი, რომლის გამოყენებაც შეგიძლიათ ChatGPT-ში, Claude-ში ან სხვა სასურველ AI-ში.';
}
