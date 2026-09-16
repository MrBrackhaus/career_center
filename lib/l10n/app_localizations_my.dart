// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appName => 'Career Center';

  @override
  String get navDashboard => 'ဒက်ရှ်ဘုတ်';

  @override
  String get navApplications => 'အလုပ်လျှောက်လွှာများ';

  @override
  String get navCalendar => 'ပြက္ခဒိန်';

  @override
  String get navTemplates => 'ကျွန်ုပ်၏ စာရွက်စာတမ်းများ';

  @override
  String get navSettings => 'ဆက်တင်များ';

  @override
  String get applicationsTitle => 'ကျွန်ုပ်၏ လျှောက်လွှာများ';

  @override
  String get btnNewApplication => 'လျှောက်လွှာအသစ်';

  @override
  String get statusOpen => 'ဖွင့်ထားဆဲ';

  @override
  String get statusSent => 'ပေးပို့ပြီး';

  @override
  String get statusInterview => 'အင်တာဗျူး';

  @override
  String get statusAccepted => 'လက်ခံရရှိသည်';

  @override
  String get statusRejected => 'ငြင်းပယ်ခံရသည်';

  @override
  String get kanbanPreparation => '📝 ပြင်ဆင်နေဆဲ';

  @override
  String get kanbanWaiting => '⏳ အကြောင်းပြန်ချက် စောင့်ဆိုင်းနေဆဲ';

  @override
  String get kanbanInterview => '🗣️ အင်တာဗျူး ဖြေဆိုနေဆဲ';

  @override
  String get kanbanOffers => '🎉 ကမ်းလှမ်းချက်များ';

  @override
  String get kanbanArchive => '🗑️ မော်ကွန်း (ငြင်းပယ်ခံရသည်များ)';

  @override
  String get searchPlaceholder => 'ကုမ္ပဏီ၊ ရာထူး ရှာဖွေရန်...';

  @override
  String get emptyApplicationsTitle => 'လျှောက်လွှာများ မရှိသေးပါ';

  @override
  String get emptyApplicationsDesc =>
      'သင်သည် လျှောက်လွှာတစ်ခုမျှ မထည့်သွင်းရသေးပါ။ စတင်ရန် \'လျှောက်လွှာအသစ်\' ကို နှိပ်ပါ!';

  @override
  String get dashboardTitle => 'လျှောက်လွှာဆိုင်ရာ စာရင်းအင်းများ';

  @override
  String get dashboardOverview => 'ခြုံငုံသုံးသပ်ချက်';

  @override
  String get dashboardApplications => 'လျှောက်လွှာများ';

  @override
  String get dashboardOpen => 'ဖွင့်ထားဆဲ';

  @override
  String get dashboardRejections => 'ငြင်းပယ်ခံရမှုများ';

  @override
  String get dashboardResponseRate => 'အကြောင်းပြန်မှု နှုန်း';

  @override
  String get dashboardRejectionRate => 'ငြင်းပယ်ခံရမှု နှုန်း';

  @override
  String get dashboardInterviews => 'အင်တာဗျူးများ';

  @override
  String get dashboardCommute => 'ပျမ်းမျှ ခရီးသွားချိန်';

  @override
  String get dashboardAppsPerMonth => 'တစ်လလျှင် လျှောက်လွှာ အရေအတွက်';

  @override
  String get dashboardTopRejectionReasons =>
      'ထိပ်တန်း ငြင်းပယ်ခံရသည့် အကြောင်းရင်းများ';

  @override
  String get dashboardNoRejectionReasons =>
      'ငြင်းပယ်ခံရသည့် အကြောင်းရင်းများ မှတ်တမ်းတင်ထားခြင်း မရှိသေးပါ။';

  @override
  String get calendarTitle => 'လျှောက်လွှာ ပြက္ခဒိန်';

  @override
  String get calendarNoEvents => 'ဤနေ့တွင် အစီအစဉ် မရှိပါ။';

  @override
  String get templatesTitle => 'ပုံစံခွက်များနှင့် လျှောက်လွှာမိတ်ဆက်စာများ';

  @override
  String get templatesNew => 'ပုံစံခွက်အသစ်';

  @override
  String get templatesEmpty => 'ပုံစံခွက်များ မဖန်တီးရသေးပါ။';

  @override
  String get templatesCreateFirst =>
      'သင်၏ ပထမဆုံး မိတ်ဆက်စာ သို့မဟုတ် စာသားအတိုအထွာကို ဖန်တီးပါ!';

  @override
  String get settingsTitle => 'ဆက်တင်များ';

  @override
  String get settingsLanguage => 'ဘာသာစကား / Language';

  @override
  String get settingsTheme => 'ဒီဇိုင်း မုဒ်';

  @override
  String get settingsThemeLight => 'အလင်း';

  @override
  String get settingsThemeDark => 'အမှောင်';

  @override
  String get settingsThemeSystem => 'စနစ် မူရင်းအတိုင်း';

  @override
  String get settingsPreset => 'ကြိုတင်သတ်မှတ်ထားသော အပြင်အဆင်';

  @override
  String get settingsAccentColor => 'အထူးပြု အရောင်';

  @override
  String get settingsJobcenterMode =>
      'Jobcenter / အလုပ်အကိုင် ရှာဖွေရေးဌာန မုဒ်';

  @override
  String get reportTitle => 'အလုပ်ရှာဖွေကြိုးပမ်းမှု အထောက်အထား';

  @override
  String get reportSavePdf => 'PDF သိမ်းဆည်းရန်';

  @override
  String get reportDate => 'လျှောက်ထားသည့် ရက်စွဲ';

  @override
  String get reportCompany => 'ကုမ္ပဏီ';

  @override
  String get reportPosition => 'ရာထူး';

  @override
  String get reportStatus => 'အခြေအနေ';

  @override
  String get reportRejectionReason => 'ငြင်းပယ်ခံရသည့် အကြောင်းရင်း';

  @override
  String get settingsLanguageTitle => 'ဘာသာစကား';

  @override
  String get settingsAppLanguage => 'အက်ပ် ဘာသာစကား';

  @override
  String get settingsDesignTitle => 'ဒီဇိုင်းနှင့် စိတ်ကြိုက်ပြင်ဆင်မှု';

  @override
  String get settingsDesignMode => 'ဒီဇိုင်း မုဒ်';

  @override
  String get settingsAccentColorTitle => 'အထူးပြု အရောင်';

  @override
  String get settingsPresetTheme => 'ကြိုတင်သတ်မှတ်ထားသော အပြင်အဆင်';

  @override
  String get settingsPresetDesc => 'ကြိုတင်ဖန်တီးထားသော ဒီဇိုင်းအတွဲများ';

  @override
  String get settingsJobcenterTitle => 'Jobcenter မုဒ်';

  @override
  String get settingsJobcenterDesc =>
      '\'အလုပ်ရှာဖွေကြိုးပမ်းမှု အထောက်အထား\' တက်ဘ်ကို ပြသသည်';

  @override
  String get settingsFieldTitle =>
      'သင်၏ အသက်မွေးဝမ်းကျောင်းနှင့် စိတ်ကြိုက်ကော်လံများ';

  @override
  String get settingsFieldSelect => 'အသက်မွေးဝမ်းကျောင်း ရွေးချယ်ပါ';

  @override
  String get settingsCustomCols => 'စိတ်ကြိုက်ကော်လံများ (ကော်မာဖြင့် ခြားပါ)';

  @override
  String get settingsPersonalData => 'ကိုယ်ရေးအချက်အလက် (PDF ထုတ်ယူရန်အတွက်)';

  @override
  String get settingsYourName => 'သင့်အမည်';

  @override
  String get settingsYourAddress => 'သင့်လိပ်စာ';

  @override
  String get dashboardTabWeek => 'ယခုအပတ်';

  @override
  String get dashboardTabTotal => 'ခြုံငုံသုံးသပ်ချက်';

  @override
  String get dashboardMsgStart => 'ခရီးတိုင်းသည် ခြေတစ်လှမ်းဖြင့် စတင်ပါသည်!';

  @override
  String get dashboardMsgGood => 'အစကောင်းပါပြီ။ ဆက်လက်ကြိုးစားပါ!';

  @override
  String get dashboardMsgStrong =>
      'ဒီတစ်ပတ်မှာ အလွန်ကောင်းမွန်တဲ့ စွမ်းဆောင်ရည်ပါ!';

  @override
  String get dashboardMsgFantastic =>
      'ဒီတစ်ပတ်မှာ အံ့သြဖွယ်ကောင်းလောက်အောင် ကြိုးစားထားပါတယ်!';

  @override
  String get dashboardNewApps => 'လျှောက်လွှာအသစ်များ';

  @override
  String get dashboardActiveApps => 'ဆောင်ရွက်ဆဲ လျှောက်လွှာများ';

  @override
  String get dashboardGoal => 'အပတ်စဉ် ရည်မှန်းချက်- ';

  @override
  String get dashboardThisWeek => 'ယခုအပတ် ';

  @override
  String get dashboardFooter =>
      'ဆက်လက်ကြိုးစားပါ! ခြေလှမ်းတိုင်းက သင့်ကို အိပ်မက်အလုပ်ဆီ ပိုနီးကပ်စေပါသည်။ 🚀';

  @override
  String get dashboardVsLastWeek => ' ပြီးခဲ့သည့်အပတ်နှင့် နှိုင်းယှဉ်ချက် ';

  @override
  String get dashboardAppsLabel => ' လျှောက်လွှာများ';

  @override
  String get appSearch => 'ရှာဖွေရန်';

  @override
  String get appSearchHint => 'ကုမ္ပဏီ၊ ရာထူး၊ နေရာ ရှာဖွေရန်...';

  @override
  String get appFilterAll => 'အားလုံး';

  @override
  String get appCheckInbox => 'ဝင်စာပုံးကို စစ်ဆေးပါ';

  @override
  String get appEmptyTitle => 'ပထမခြေလှမ်း စတင်ရန် အချိန်ကျရောက်ပါပြီ!';

  @override
  String get appEmptyDesc =>
      'သင်၏ ပထမဆုံး လျှောက်လွှာကို ဖန်တီးပြီး သင့်အိပ်မက်အလုပ်ဆီသို့ လျှောက်လှမ်းမည့် လမ်းကြောင်းကို စီစဉ်ပါ။';

  @override
  String get calClickDetails =>
      'အသေးစိတ်သိရှိရန် အသားပေးဖော်ပြထားသော နေ့တစ်နေ့ကို နှိပ်ပါ။';

  @override
  String get calOverdue => 'ရက်လွန်နေသည်';

  @override
  String get calFollowUp => 'နောက်ဆက်တွဲ အခြေအနေမေးမြန်းရန်';

  @override
  String get reportGeneratedOn => 'ထုတ်ယူသည့် ရက်စွဲ- ';

  @override
  String get reportNoApps => 'လျှောက်လွှာများ မတွေ့ရှိပါ။';

  @override
  String get navJobcenter => 'Jobcenter အစီရင်ခံစာ';

  @override
  String get settingsImapTitle => 'အီးမေးလ် ထပ်တူပြုခြင်း (IMAP)';

  @override
  String get settingsImapDesc =>
      'ငြင်းပယ်ချက်များ/ဖိတ်ခေါ်ချက်များကို အလိုအလျောက် ရယူသည်';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'ဤလုပ်ဆောင်ချက်ကို တီထွင်ဖန်တီးဆဲ ဖြစ်ပါသည်။ ကုမ္ပဏီအမည်များနှင့် လျှောက်လွှာများကို အလိုအလျောက် ရှာဖွေဖော်ထုတ်ရာတွင် မတိကျမှုများ ရှိနိုင်ပါသည်။ ထည့်သွင်းထားသော အချက်အလက်များကို ကိုယ်တိုင် ပြန်လည်စစ်ဆေးပါ။';

  @override
  String get settingsImapProvider => 'ဝန်ဆောင်မှုပေးသူ';

  @override
  String get settingsImapManual => 'ကိုယ်တိုင်သတ်မှတ်ရန် / စိတ်ကြိုက် ဆာဗာ';

  @override
  String get settingsImapServer => 'IMAP ဆာဗာ';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'အီးမေးလ် လိပ်စာ';

  @override
  String get settingsImapPassword => 'စကားဝှက် (အက်ပ် စကားဝှက်)';

  @override
  String get settingsImapSave => 'ဒေတာ သိမ်းဆည်းရန်';

  @override
  String get settingsExportTitle => 'ဒေတာ ထုတ်ယူခြင်း';

  @override
  String get settingsExportPdf => 'Jobcenter အစီရင်ခံစာ ထုတ်ယူရန် (PDF)';

  @override
  String get settingsExportCsv => 'CSV အဖြစ် ထုတ်ယူရန်';

  @override
  String get settingsExportBackup => 'ဒေတာဘေ့စ် အရန်ဖိုင် ထုတ်ယူရန် (.sqlite)';

  @override
  String get settingsExportRestore => 'အရန်ဖိုင်မှ ဒေတာဘေ့စ်ကို ပြန်လည်ရယူရန်';

  @override
  String get settingsExportRestart =>
      'အချက်အလက်- ဖိုင်ထည့်သွင်းပြီးနောက် အက်ပ်ကို ပြန်လည်ဖွင့်ရန် လိုအပ်ပါသည်။';

  @override
  String get settingsAppQuit => 'အက်ပ်မှ ထွက်ရန်';

  @override
  String get appNotFoundTitle => 'မည်သည့်အရာမျှ မတွေ့ပါ။';

  @override
  String get appNotFoundDesc =>
      'ဤစစ်ထုတ်မှု ဆက်တင်များနှင့် ကိုက်ညီသော အချက်အလက် မရှိပါ။';

  @override
  String get formTabBasic => 'အခြေခံ အချက်အလက်';

  @override
  String get formTabEmails => 'အီးမေးလ်များနှင့် ဆက်သွယ်ရန်များ';

  @override
  String get formTabDocs => 'စာရွက်စာတမ်းများ';

  @override
  String get formTabNotes => 'မှတ်စုများ';

  @override
  String get formBasicContact => 'ဆက်သွယ်ရန်နှင့် လိပ်စာ';

  @override
  String get formBasicSave => 'သိမ်းဆည်းရန်';

  @override
  String get formBasicInterview => 'အင်တာဗျူး';

  @override
  String get formBasicSalary => 'မျှော်မှန်းလစာ (€/တစ်နှစ်)';

  @override
  String get formBasicOpen => 'ဖွင့်ထားဆဲ';

  @override
  String get formBasicAccepted => 'ကမ်းလှမ်းချက်';

  @override
  String get formBasicRejected => 'ငြင်းပယ်ခံရသည်';

  @override
  String get formBasicJobLink => 'အလုပ်ကြော်ငြာ လင့်ခ်';

  @override
  String get formBasicJobLinkHint =>
      'အချက်အလက်များ ရယူရန် အလုပ်ကြော်ငြာ လင့်ခ်ကို ကူးထည့်ပါ သို့မဟုတ် PDF (ဥပမာ- Jobcenter) ကို တင်ပါ။';

  @override
  String get formBasicAutofill => 'အလိုအလျောက် ဖြည့်ရန်';

  @override
  String get formBasicCommute => 'ခရီးသွားချိန် (မိနစ်)';

  @override
  String get formBasicRejectionReason => 'ငြင်းပယ်ခံရသည့် အကြောင်းရင်း';

  @override
  String get formBasicUploadPdf => 'သို့မဟုတ် PDF တင်ရန်';

  @override
  String get formBasicStatus => 'အခြေအနေ';

  @override
  String get formBasicCompanyWeb => 'ကုမ္ပဏီ ဝဘ်ဆိုက် (ဥပမာ- https://)';

  @override
  String get formBasicMagic => 'Magic Auto-Fill';

  @override
  String get formBasicDelete => 'ဖျက်ရန်';

  @override
  String get formBasicSent => 'ပေးပို့ပြီး';

  @override
  String get reportGeneratedAt => 'ထုတ်ယူသည့် အချိန်-';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'အပတ်စဉ် ရည်မှန်းချက်-';

  @override
  String get weeklyGoalSuffix => ' လျှောက်လွှာ ၅ ခုအနက်';

  @override
  String get weeklyThisWeek => 'ယခုအပတ် ';

  @override
  String get weeklyVs => ' လျှောက်လွှာ ပြီးခဲ့သည့်အပတ်နှင့် နှိုင်းယှဉ်ချက် ';

  @override
  String get weeklyApplications => ' လျှောက်လွှာများ';

  @override
  String get weeklyMotivationalFooter =>
      'ဆက်လက်ကြိုးစားပါ! ခြေလှမ်းတိုင်းက သင့်ကို အသင့်တော်ဆုံး အလုပ်ဆီ ပိုနီးကပ်စေပါသည်။ 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'ဆက်လက်ကြိုးစားပါ! ခြေလှမ်းတိုင်းက သင့်ကို အသင့်တော်ဆုံး အလုပ်ဆီ ပိုနီးကပ်စေပါသည်။';

  @override
  String get templatesTabMy => 'ကျွန်ုပ်၏ ပုံစံခွက်များ';

  @override
  String get templatesTabExamples => 'နမူနာပုံစံများနှင့် ဥပမာများ';

  @override
  String get promptTitle => 'AI Prompt ထုတ်လုပ်ပေးသည့် ကိရိယာ';

  @override
  String get promptDesc =>
      'ChatGPT၊ Claude သို့မဟုတ် သင်စိတ်ကြိုက် အခြား AI တစ်ခုခုတွင် အသုံးပြုနိုင်သည့် ပရော်ဖက်ရှင်နယ် prompt တစ်ခု ဖန်တီးရန် အကွက်များကို ဖြည့်စွက်ပါ။';

  @override
  String get promptPosition => 'ရာထူး / အလုပ်အကိုင် အမည်';

  @override
  String get promptCompany => 'ကုမ္ပဏီ';

  @override
  String get promptSkills => 'သင်၏ အဓိကကျွမ်းကျင်မှုများနှင့် အတွေ့အကြုံ';

  @override
  String get promptTone => 'လေသံ / အရေးအသားပုံစံ';

  @override
  String get promptToneDefault => 'ကျွမ်းကျင်မှုရှိပြီး ဖော်ရွေသော';

  @override
  String get promptGenerate => 'Prompt ထုတ်ယူရန်';

  @override
  String get tplInitiative => 'တိုက်ရိုက် အလုပ်လျှောက်ထားခြင်း';

  @override
  String get tplReply => 'အလုပ်ခေါ်ယူမှု ကြော်ငြာကို တုံ့ပြန်ခြင်း';

  @override
  String get tplFollowUp => 'သတိပေးချက် / နောက်ဆက်တွဲ စုံစမ်းခြင်း';

  @override
  String get tplRejection => 'ယဉ်ကျေးစွာ ငြင်းပယ်တုံ့ပြန်ချက်';

  @override
  String get tplTypeCover => 'လျှောက်လွှာမိတ်ဆက်စာ';

  @override
  String get tplTypeSnippet => 'စာသားအတိုအထွာ';

  @override
  String get noAppsFound => 'လျှောက်လွှာများ မတွေ့ရှိပါ။';

  @override
  String get templatesEmptyState => 'ပုံစံခွက်များ မဖန်တီးရသေးပါ။';

  @override
  String get templatesEmptyStateSub =>
      'သင်၏ ပထမဆုံး မိတ်ဆက်စာ သို့မဟုတ် စာသားအတိုအထွာကို ဖန်တီးပါ!';

  @override
  String get promptSubtitle =>
      'ChatGPT၊ Claude သို့မဟုတ် သင်စိတ်ကြိုက် အခြား AI တစ်ခုခုတွင် အသုံးပြုနိုင်သည့် ပရော်ဖက်ရှင်နယ် prompt တစ်ခု ဖန်တီးရန် အကွက်များကို ဖြည့်စွက်ပါ။';
}
