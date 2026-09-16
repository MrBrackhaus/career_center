// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appName => 'مرکز شغلی';

  @override
  String get navDashboard => 'داشبورد';

  @override
  String get navApplications => 'درخواست‌ها';

  @override
  String get navCalendar => 'تقویم';

  @override
  String get navTemplates => 'اسناد من';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get applicationsTitle => 'درخواست‌های من';

  @override
  String get btnNewApplication => 'درخواست جدید';

  @override
  String get statusOpen => 'باز';

  @override
  String get statusSent => 'ارسال‌شده';

  @override
  String get statusInterview => 'مصاحبه';

  @override
  String get statusAccepted => 'پذیرفته‌شده';

  @override
  String get statusRejected => 'ردشده';

  @override
  String get kanbanPreparation => '📝 در حال آماده‌سازی';

  @override
  String get kanbanWaiting => '⏳ در انتظار پاسخ';

  @override
  String get kanbanInterview => '🗣️ در حال مصاحبه';

  @override
  String get kanbanOffers => '🎉 پیشنهادهای کاری';

  @override
  String get kanbanArchive => '🗑️ بایگانی (ردشده)';

  @override
  String get searchPlaceholder => 'جستجو برای شرکت، موقعیت شغلی...';

  @override
  String get emptyApplicationsTitle => 'هنوز درخواستی ثبت نشده است';

  @override
  String get emptyApplicationsDesc =>
      'به نظر می‌رسد هنوز هیچ درخواستی اضافه نکرده‌اید. برای شروع روی «درخواست جدید» کلیک کنید!';

  @override
  String get dashboardTitle => 'آمار درخواست‌ها';

  @override
  String get dashboardOverview => 'نمای کلی';

  @override
  String get dashboardApplications => 'درخواست‌ها';

  @override
  String get dashboardOpen => 'در جریان';

  @override
  String get dashboardRejections => 'ردشده';

  @override
  String get dashboardResponseRate => 'نرخ پاسخ‌دهی';

  @override
  String get dashboardRejectionRate => 'نرخ رد درخواست';

  @override
  String get dashboardInterviews => 'مصاحبه‌ها';

  @override
  String get dashboardCommute => 'میانگین زمان رفت‌وآمد';

  @override
  String get dashboardAppsPerMonth => 'درخواست‌ها در ماه';

  @override
  String get dashboardTopRejectionReasons => 'اصلی‌ترین دلایل رد درخواست';

  @override
  String get dashboardNoRejectionReasons =>
      'هنوز دلیلی برای رد درخواست ثبت نشده است.';

  @override
  String get calendarTitle => 'تقویم درخواست‌ها';

  @override
  String get calendarNoEvents => 'هیچ رویدادی در این روز وجود ندارد.';

  @override
  String get templatesTitle => 'قالب‌ها و انگیزه‌نامه‌ها';

  @override
  String get templatesNew => 'قالب جدید';

  @override
  String get templatesEmpty => 'هنوز قالبی ایجاد نشده است.';

  @override
  String get templatesCreateFirst =>
      'اولین انگیزه‌نامه یا قطعه‌متن خود را ایجاد کنید!';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsLanguage => 'زبان / Language';

  @override
  String get settingsTheme => 'حالت پوسته';

  @override
  String get settingsThemeLight => 'روشن';

  @override
  String get settingsThemeDark => 'تاریک';

  @override
  String get settingsThemeSystem => 'پیش‌فرض سیستم';

  @override
  String get settingsPreset => 'تم پیش‌تنظیم';

  @override
  String get settingsAccentColor => 'رنگ تأکیدی';

  @override
  String get settingsJobcenterMode => 'حالت Jobcenter / اداره کار';

  @override
  String get reportTitle => 'مدرک تلاش‌های کاریابی';

  @override
  String get reportSavePdf => 'ذخیره PDF';

  @override
  String get reportDate => 'تاریخ درخواست';

  @override
  String get reportCompany => 'شرکت';

  @override
  String get reportPosition => 'موقعیت شغلی';

  @override
  String get reportStatus => 'وضعیت';

  @override
  String get reportRejectionReason => 'دلیل رد درخواست';

  @override
  String get settingsLanguageTitle => 'زبان';

  @override
  String get settingsAppLanguage => 'زبان برنامه';

  @override
  String get settingsDesignTitle => 'طراحی و شخصی‌سازی';

  @override
  String get settingsDesignMode => 'حالت پوسته';

  @override
  String get settingsAccentColorTitle => 'رنگ تأکیدی';

  @override
  String get settingsPresetTheme => 'تم پیش‌تنظیم';

  @override
  String get settingsPresetDesc => 'ترکیب‌های طراحی از پیش‌آماده';

  @override
  String get settingsJobcenterTitle => 'حالت Jobcenter';

  @override
  String get settingsJobcenterDesc =>
      'برگه «مدرک تلاش‌های کاریابی» را نمایش می‌دهد';

  @override
  String get settingsFieldTitle => 'حوزه شغلی شما و ستون‌های سفارشی';

  @override
  String get settingsFieldSelect => 'انتخاب حوزه شغلی';

  @override
  String get settingsCustomCols => 'ستون‌های سفارشی (جداشده با ویرگول)';

  @override
  String get settingsPersonalData => 'اطلاعات شخصی (برای خروجی PDF)';

  @override
  String get settingsYourName => 'نام شما';

  @override
  String get settingsYourAddress => 'آدرس شما';

  @override
  String get dashboardTabWeek => 'هفته جاری';

  @override
  String get dashboardTabTotal => 'نمای کلی';

  @override
  String get dashboardMsgStart => 'هر سفری با یک قدم آغاز می‌شود!';

  @override
  String get dashboardMsgGood => 'شروع خوبی است! همین‌طور ادامه دهید!';

  @override
  String get dashboardMsgStrong => 'عملکرد عالی در این هفته!';

  @override
  String get dashboardMsgFantastic => 'کار فوق‌العاده در این هفته!';

  @override
  String get dashboardNewApps => 'درخواست‌های جدید';

  @override
  String get dashboardActiveApps => 'درخواست‌های فعال';

  @override
  String get dashboardGoal => 'هدف هفتگی: ';

  @override
  String get dashboardThisWeek => 'این هفته ';

  @override
  String get dashboardFooter =>
      'ادامه دهید! هر قدم شما را به شغل رؤیایی‌تان نزدیک‌تر می‌کند. 🚀';

  @override
  String get dashboardVsLastWeek => ' در مقایسه با هفته گذشته ';

  @override
  String get dashboardAppsLabel => ' درخواست';

  @override
  String get appSearch => 'جستجو';

  @override
  String get appSearchHint => 'جستجوی شرکت، موقعیت شغلی، مکان...';

  @override
  String get appFilterAll => 'همه';

  @override
  String get appCheckInbox => 'بررسی صندوق ورودی';

  @override
  String get appEmptyTitle => 'زمان برداشتن اولین قدم است!';

  @override
  String get appEmptyDesc =>
      'اولین درخواست خود را ایجاد کنید و مسیر رسیدن به شغل رؤیایی‌تان را سازماندهی نمایید.';

  @override
  String get calClickDetails =>
      'برای مشاهده جزئیات روی یک روز مشخص‌شده کلیک کنید.';

  @override
  String get calOverdue => 'سررسید گذشته';

  @override
  String get calFollowUp => 'پیگیری';

  @override
  String get reportGeneratedOn => 'تاریخ ایجاد: ';

  @override
  String get reportNoApps => 'هیچ درخواستی یافت نشد.';

  @override
  String get navJobcenter => 'گزارش Jobcenter';

  @override
  String get settingsImapTitle => 'همگام‌سازی ایمیل (IMAP)';

  @override
  String get settingsImapDesc => 'دریافت خودکار پیام‌های رد یا دعوت به مصاحبه';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'این ویژگی هنوز در حال توسعه است. تشخیص خودکار نام شرکت‌ها و درخواست‌ها ممکن است دقیق نباشد. لطفاً موارد واردشده را به صورت دستی بررسی کنید.';

  @override
  String get settingsImapProvider => 'ارائه‌دهنده';

  @override
  String get settingsImapManual => 'دستی / سرور سفارشی';

  @override
  String get settingsImapServer => 'IMAP Server';

  @override
  String get settingsImapPort => 'پورت';

  @override
  String get settingsImapEmail => 'آدرس ایمیل';

  @override
  String get settingsImapPassword => 'رمز عبور (رمز برنامه)';

  @override
  String get settingsImapSave => 'ذخیره اطلاعات';

  @override
  String get settingsExportTitle => 'خروجی داده‌ها';

  @override
  String get settingsExportPdf => 'خروجی گزارش Jobcenter (PDF)';

  @override
  String get settingsExportCsv => 'خروجی به صورت CSV';

  @override
  String get settingsExportBackup => 'خروجی نسخه پشتیبان پایگاه داده (.sqlite)';

  @override
  String get settingsExportRestore => 'بازیابی پایگاه داده از نسخه پشتیبان';

  @override
  String get settingsExportRestart =>
      'توجه: پس از درون‌ریزی، راه‌اندازی مجدد برنامه الزامی است.';

  @override
  String get settingsAppQuit => 'خروج از برنامه';

  @override
  String get appNotFoundTitle => 'چیزی یافت نشد.';

  @override
  String get appNotFoundDesc =>
      'هیچ موردی مطابق با این تنظیمات فیلتر یافت نشد.';

  @override
  String get formTabBasic => 'اطلاعات پایه';

  @override
  String get formTabEmails => 'ایمیل‌ها و مخاطبین';

  @override
  String get formTabDocs => 'اسناد';

  @override
  String get formTabNotes => 'یادداشت‌ها';

  @override
  String get formBasicContact => 'اطلاعات تماس و آدرس';

  @override
  String get formBasicSave => 'ذخیره';

  @override
  String get formBasicInterview => 'مصاحبه';

  @override
  String get formBasicSalary => 'حقوق درخواستی (€/سالانه)';

  @override
  String get formBasicOpen => 'باز';

  @override
  String get formBasicAccepted => 'پیشنهاد کاری';

  @override
  String get formBasicRejected => 'ردشده';

  @override
  String get formBasicJobLink => 'لینک آگهی استخدام';

  @override
  String get formBasicJobLinkHint =>
      'برای استخراج اطلاعات، یک لینک آگهی استخدام جای‌گذاری کنید یا یک فایل PDF (مانند Jobcenter) بارگذاری نمایید.';

  @override
  String get formBasicAutofill => 'تکمیل خودکار';

  @override
  String get formBasicCommute => 'زمان رفت‌وآمد (دقیقه)';

  @override
  String get formBasicRejectionReason => 'دلیل رد درخواست';

  @override
  String get formBasicUploadPdf => 'یا بارگذاری PDF';

  @override
  String get formBasicStatus => 'وضعیت';

  @override
  String get formBasicCompanyWeb => 'وب‌سایت شرکت (مثلاً https://)';

  @override
  String get formBasicMagic => 'تکمیل خودکار جادویی';

  @override
  String get formBasicDelete => 'حذف';

  @override
  String get formBasicSent => 'ارسال‌شده';

  @override
  String get reportGeneratedAt => 'ایجادشده در:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'هدف هفتگی:';

  @override
  String get weeklyGoalSuffix => ' از 5 درخواست';

  @override
  String get weeklyThisWeek => 'این هفته ';

  @override
  String get weeklyVs => ' درخواست در مقایسه با هفته گذشته ';

  @override
  String get weeklyApplications => ' درخواست';

  @override
  String get weeklyMotivationalFooter =>
      'ادامه دهید! هر قدم شما را به شغل ایده‌آل‌تان نزدیک‌تر می‌کند. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'ادامه دهید! هر قدم شما را به شغل ایده‌آل‌تان نزدیک‌تر می‌کند.';

  @override
  String get templatesTabMy => 'قالب‌های من';

  @override
  String get templatesTabExamples => 'نمونه‌ها و الگوها';

  @override
  String get promptTitle => 'مولد پرامپت هوش مصنوعی';

  @override
  String get promptDesc =>
      'فیلدها را پر کنید تا یک پرامپت حرفه‌ای ایجاد شود که بتوانید از آن در ChatGPT، Claude یا هر هوش مصنوعی دلخواه دیگری استفاده نمایید.';

  @override
  String get promptPosition => 'موقعیت / عنوان شغلی';

  @override
  String get promptCompany => 'شرکت';

  @override
  String get promptSkills => 'برجسته‌ترین مهارت‌ها و تجربیات شما';

  @override
  String get promptTone => 'لحن';

  @override
  String get promptToneDefault => 'حرفه‌ای و دوستانه';

  @override
  String get promptGenerate => 'تولید پرامپت';

  @override
  String get tplInitiative => 'درخواست کار پیش‌دستانه';

  @override
  String get tplReply => 'پاسخ به آگهی استخدام';

  @override
  String get tplFollowUp => 'یادآوری / پیگیری';

  @override
  String get tplRejection => 'پاسخ مؤدبانه به رد درخواست';

  @override
  String get tplTypeCover => 'انگیزه‌نامه';

  @override
  String get tplTypeSnippet => 'قطعه‌متن';

  @override
  String get noAppsFound => 'هیچ درخواستی یافت نشد.';

  @override
  String get templatesEmptyState => 'هنوز قالبی ایجاد نشده است.';

  @override
  String get templatesEmptyStateSub =>
      'اولین انگیزه‌نامه یا قطعه‌متن خود را ایجاد کنید!';

  @override
  String get promptSubtitle =>
      'فیلدها را پر کنید و یک پرامپت حرفه‌ای ایجاد نمایید که بتوانید از آن در ChatGPT، Claude یا هر هوش مصنوعی دلخواه دیگری استفاده کنید.';
}
