// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مركز التوظيف';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navApplications => 'الطلبات';

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navTemplates => 'مستنداتي';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get applicationsTitle => 'طلباتي';

  @override
  String get btnNewApplication => 'طلب جديد';

  @override
  String get statusOpen => 'مفتوح';

  @override
  String get statusSent => 'تم الإرسال';

  @override
  String get statusInterview => 'مقابلة';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get kanbanPreparation => '📝 قيد الإعداد';

  @override
  String get kanbanWaiting => '⏳ في انتظار الرد';

  @override
  String get kanbanInterview => '🗣️ مرحلة المقابلات';

  @override
  String get kanbanOffers => '🎉 العروض';

  @override
  String get kanbanArchive => '🗑️ الأرشيف (المرفوضة)';

  @override
  String get searchPlaceholder => 'ابحث عن شركة، مسمى وظيفي...';

  @override
  String get emptyApplicationsTitle => 'لا توجد طلبات بعد';

  @override
  String get emptyApplicationsDesc =>
      'يبدو أنك لم تقم بإضافة أي طلبات بعد. انقر على \"طلب جديد\" للبدء!';

  @override
  String get dashboardTitle => 'إحصائيات الطلبات';

  @override
  String get dashboardOverview => 'نظرة عامة';

  @override
  String get dashboardApplications => 'الطلبات';

  @override
  String get dashboardOpen => 'قيد المتابعة';

  @override
  String get dashboardRejections => 'المرفوضة';

  @override
  String get dashboardResponseRate => 'معدل الاستجابة';

  @override
  String get dashboardRejectionRate => 'معدل الرفض';

  @override
  String get dashboardInterviews => 'المقابلات';

  @override
  String get dashboardCommute => 'متوسط وقت التنقل';

  @override
  String get dashboardAppsPerMonth => 'الطلبات شهرياً';

  @override
  String get dashboardTopRejectionReasons => 'أهم أسباب الرفض';

  @override
  String get dashboardNoRejectionReasons =>
      'لم يتم تسجيل أي أسباب رفض حتى الآن.';

  @override
  String get calendarTitle => 'تقويم الطلبات';

  @override
  String get calendarNoEvents => 'لا توجد مواعيد في هذا اليوم.';

  @override
  String get templatesTitle => 'النماذج وخطابات التقديم';

  @override
  String get templatesNew => 'نموذج جديد';

  @override
  String get templatesEmpty => 'لم يتم إنشاء أي نماذج بعد.';

  @override
  String get templatesCreateFirst => 'أنشئ أول خطاب تقديم أو نص جاهز لك!';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة / Language';

  @override
  String get settingsTheme => 'وضع المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'افتراضي النظام';

  @override
  String get settingsPreset => 'السمة المحددة مسبقاً';

  @override
  String get settingsAccentColor => 'اللون المميز';

  @override
  String get settingsJobcenterMode => 'وضع Jobcenter / مكتب العمل';

  @override
  String get reportTitle => 'إثبات جهود البحث عن عمل';

  @override
  String get reportSavePdf => 'حفظ PDF';

  @override
  String get reportDate => 'تاريخ التقديم';

  @override
  String get reportCompany => 'الشركة';

  @override
  String get reportPosition => 'المسمى الوظيفي';

  @override
  String get reportStatus => 'الحالة';

  @override
  String get reportRejectionReason => 'سبب الرفض';

  @override
  String get settingsLanguageTitle => 'اللغة';

  @override
  String get settingsAppLanguage => 'لغة التطبيق';

  @override
  String get settingsDesignTitle => 'التصميم والتخصيص';

  @override
  String get settingsDesignMode => 'وضع المظهر';

  @override
  String get settingsAccentColorTitle => 'اللون المميز';

  @override
  String get settingsPresetTheme => 'السمة المحددة مسبقاً';

  @override
  String get settingsPresetDesc => 'توليفات تصميم جاهزة';

  @override
  String get settingsJobcenterTitle => 'وضع Jobcenter';

  @override
  String get settingsJobcenterDesc => 'يُظهر تبويب \"إثبات جهود البحث عن عمل\"';

  @override
  String get settingsFieldTitle => 'مجال عملك والأعمدة المخصصة';

  @override
  String get settingsFieldSelect => 'اختر المجال المهني';

  @override
  String get settingsCustomCols => 'أعمدة مخصصة (مفصولة بفواصل)';

  @override
  String get settingsPersonalData => 'البيانات الشخصية (لتصدير PDF)';

  @override
  String get settingsYourName => 'اسمك';

  @override
  String get settingsYourAddress => 'عنوانك';

  @override
  String get dashboardTabWeek => 'الأسبوع الحالي';

  @override
  String get dashboardTabTotal => 'نظرة عامة';

  @override
  String get dashboardMsgStart => 'كل رحلة تبدأ بخطوة واحدة!';

  @override
  String get dashboardMsgGood => 'بداية موفقة! واصل التقدم!';

  @override
  String get dashboardMsgStrong => 'أداء متميز هذا الأسبوع!';

  @override
  String get dashboardMsgFantastic => 'عمل رائع هذا الأسبوع!';

  @override
  String get dashboardNewApps => 'طلبات جديدة';

  @override
  String get dashboardActiveApps => 'طلبات نشطة';

  @override
  String get dashboardGoal => 'الهدف الأسبوعي: ';

  @override
  String get dashboardThisWeek => 'هذا الأسبوع ';

  @override
  String get dashboardFooter =>
      'واصل المحاولة! كل خطوة تقربك من وظيفة أحلامك. 🚀';

  @override
  String get dashboardVsLastWeek => ' مقارنة بالأسبوع الماضي ';

  @override
  String get dashboardAppsLabel => ' طلبات';

  @override
  String get appSearch => 'بحث';

  @override
  String get appSearchHint => 'ابحث عن الشركة، المنصب، الموقع...';

  @override
  String get appFilterAll => 'الكل';

  @override
  String get appCheckInbox => 'فحص صندوق الوارد';

  @override
  String get appEmptyTitle => 'حان وقت الخطوة الأولى!';

  @override
  String get appEmptyDesc => 'أنشئ طلبك الأول ونظّم مسارك نحو وظيفة أحلامك.';

  @override
  String get calClickDetails => 'انقر على اليوم المميز لعرض التفاصيل.';

  @override
  String get calOverdue => 'متأخر';

  @override
  String get calFollowUp => 'متابعة';

  @override
  String get reportGeneratedOn => 'تم الإنشاء في: ';

  @override
  String get reportNoApps => 'لم يتم العثور على أي طلبات.';

  @override
  String get navJobcenter => 'تقرير Jobcenter';

  @override
  String get settingsImapTitle => 'مزامنة البريد الإلكتروني (IMAP)';

  @override
  String get settingsImapDesc => 'استلام إشعارات الرفض والمقابلات تلقائياً';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'هذه الميزة لا تزال قيد التطوير. قد يكون التعرف التلقائي على أسماء الشركات والطلبات غير دقيق. يرجى مراجعة المدخلات المستوردة يدوياً.';

  @override
  String get settingsImapProvider => 'مزود الخدمة';

  @override
  String get settingsImapManual => 'يدوي / خادم مخصص';

  @override
  String get settingsImapServer => 'IMAP Server';

  @override
  String get settingsImapPort => 'المنفذ';

  @override
  String get settingsImapEmail => 'عنوان البريد الإلكتروني';

  @override
  String get settingsImapPassword => 'كلمة المرور (كلمة مرور التطبيق)';

  @override
  String get settingsImapSave => 'حفظ البيانات';

  @override
  String get settingsExportTitle => 'تصدير البيانات';

  @override
  String get settingsExportPdf => 'تصدير تقرير Jobcenter (PDF)';

  @override
  String get settingsExportCsv => 'تصدير كـ CSV';

  @override
  String get settingsExportBackup =>
      'تصدير نسخة احتياطية لقاعدة البيانات (.sqlite)';

  @override
  String get settingsExportRestore => 'استعادة قاعدة البيانات من نسخة احتياطية';

  @override
  String get settingsExportRestart =>
      'معلومة: يلزم إعادة تشغيل التطبيق بعد الاستيراد.';

  @override
  String get settingsAppQuit => 'إنهاء التطبيق';

  @override
  String get appNotFoundTitle => 'لم يتم العثور على شيء.';

  @override
  String get appNotFoundDesc => 'لا توجد نتائج مطابقة لإعدادات التصفية هذه.';

  @override
  String get formTabBasic => 'البيانات الأساسية';

  @override
  String get formTabEmails => 'رسائل البريد وجهات الاتصال';

  @override
  String get formTabDocs => 'المستندات';

  @override
  String get formTabNotes => 'الملاحظات';

  @override
  String get formBasicContact => 'جهة الاتصال والعنوان';

  @override
  String get formBasicSave => 'حفظ';

  @override
  String get formBasicInterview => 'مقابلة';

  @override
  String get formBasicSalary => 'الراتب المتوقع (€/سنوياً)';

  @override
  String get formBasicOpen => 'مفتوح';

  @override
  String get formBasicAccepted => 'عرض عمل';

  @override
  String get formBasicRejected => 'مرفوض';

  @override
  String get formBasicJobLink => 'رابط الإعلان الوظيفي';

  @override
  String get formBasicJobLinkHint =>
      'الصق رابط الوظيفة أو ارفع ملف PDF (مثل Jobcenter) لاستخراج البيانات.';

  @override
  String get formBasicAutofill => 'ملء تلقائي';

  @override
  String get formBasicCommute => 'وقت التنقل (بالدقائق)';

  @override
  String get formBasicRejectionReason => 'سبب الرفض';

  @override
  String get formBasicUploadPdf => 'أو ارفع ملف PDF';

  @override
  String get formBasicStatus => 'الحالة';

  @override
  String get formBasicCompanyWeb => 'موقع الشركة الإلكتروني (مثال: https://)';

  @override
  String get formBasicMagic => 'ملء تلقائي ذكي';

  @override
  String get formBasicDelete => 'حذف';

  @override
  String get formBasicSent => 'تم الإرسال';

  @override
  String get reportGeneratedAt => 'تم الإنشاء في:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'الهدف الأسبوعي:';

  @override
  String get weeklyGoalSuffix => ' من 5 طلبات';

  @override
  String get weeklyThisWeek => 'هذا الأسبوع ';

  @override
  String get weeklyVs => ' طلبات مقارنة بالأسبوع الماضي ';

  @override
  String get weeklyApplications => ' طلبات';

  @override
  String get weeklyMotivationalFooter =>
      'واصل التقدم! كل خطوة تقربك من الوظيفة المثالية. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'واصل التقدم! كل خطوة تقربك من الوظيفة المثالية.';

  @override
  String get templatesTabMy => 'نماذجي';

  @override
  String get templatesTabExamples => 'نماذج وأمثلة';

  @override
  String get promptTitle => 'مولّد أوامر الذكاء الاصطناعي';

  @override
  String get promptDesc =>
      'املأ الحقول لإنشاء أمر احترافي يمكنك استخدامه في ChatGPT أو Claude أو أي ذكاء اصطناعي آخر من اختيارك.';

  @override
  String get promptPosition => 'المنصب / المسمى الوظيفي';

  @override
  String get promptCompany => 'الشركة';

  @override
  String get promptSkills => 'أبرز مهاراتك وخبراتك';

  @override
  String get promptTone => 'النبرة';

  @override
  String get promptToneDefault => 'احترافي وودود';

  @override
  String get promptGenerate => 'توليد الأمر';

  @override
  String get tplInitiative => 'طلب توظيف استباقي';

  @override
  String get tplReply => 'رد على إعلان وظيفي';

  @override
  String get tplFollowUp => 'تذكير / متابعة';

  @override
  String get tplRejection => 'رد مهذب على الرفض';

  @override
  String get tplTypeCover => 'خطاب تقديم';

  @override
  String get tplTypeSnippet => 'نص جاهز';

  @override
  String get noAppsFound => 'لم يتم العثور على أي طلبات.';

  @override
  String get templatesEmptyState => 'لم يتم إنشاء أي نماذج بعد.';

  @override
  String get templatesEmptyStateSub => 'أنشئ أول خطاب تقديم أو نص جاهز لك!';

  @override
  String get promptSubtitle =>
      'املأ الحقول وأنشئ أمراً احترافياً يمكنك استخدامه في ChatGPT أو Claude أو أي ذكاء اصطناعي آخر من اختيارك.';
}
