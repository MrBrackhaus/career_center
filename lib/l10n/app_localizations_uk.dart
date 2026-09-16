// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appName => 'Центр Кар\'єри';

  @override
  String get navDashboard => 'Дашборд';

  @override
  String get navApplications => 'Заявки';

  @override
  String get navCalendar => 'Календар';

  @override
  String get navTemplates => 'Мої документи';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get applicationsTitle => 'Мої заявки';

  @override
  String get btnNewApplication => 'Нова заявка';

  @override
  String get statusOpen => 'Відкрито';

  @override
  String get statusSent => 'Надіслано';

  @override
  String get statusInterview => 'Співбесіда';

  @override
  String get statusAccepted => 'Прийнято';

  @override
  String get statusRejected => 'Відхилено';

  @override
  String get kanbanPreparation => '📝 В підготовці';

  @override
  String get kanbanWaiting => '⏳ Очікування відповіді';

  @override
  String get kanbanInterview => '🗣️ На співбесіді';

  @override
  String get kanbanOffers => '🎉 Пропозиції';

  @override
  String get kanbanArchive => '🗑️ Архів (відмови)';

  @override
  String get searchPlaceholder => 'Пошук компанії, посади...';

  @override
  String get emptyApplicationsTitle => 'Ще немає заявок';

  @override
  String get emptyApplicationsDesc =>
      'Схоже, ви ще не додали жодної заявки. Натисніть «Нова заявка», щоб розпочати!';

  @override
  String get dashboardTitle => 'Статистика заявок';

  @override
  String get dashboardOverview => 'ОГЛЯД';

  @override
  String get dashboardApplications => 'ЗАЯВКИ';

  @override
  String get dashboardOpen => 'ВІДКРИТІ';

  @override
  String get dashboardRejections => 'ВІДМОВИ';

  @override
  String get dashboardResponseRate => 'ВІДСОТОК ВІДПОВІДЕЙ';

  @override
  String get dashboardRejectionRate => 'ВІДСОТОК ВІДМОВ';

  @override
  String get dashboardInterviews => 'СПІВБЕСІДИ';

  @override
  String get dashboardCommute => 'СЕРЕДНІЙ ЧАС У ДОРОЗІ';

  @override
  String get dashboardAppsPerMonth => 'ЗАЯВОК НА МІСЯЦЬ';

  @override
  String get dashboardTopRejectionReasons => 'ОСНОВНІ ПРИЧИНИ ВІДМОВ';

  @override
  String get dashboardNoRejectionReasons =>
      'Причин відмов поки не зафіксовано.';

  @override
  String get calendarTitle => 'Календар заявок';

  @override
  String get calendarNoEvents => 'Немає подій на цей день.';

  @override
  String get templatesTitle => 'Шаблони та супровідні листи';

  @override
  String get templatesNew => 'Новий шаблон';

  @override
  String get templatesEmpty => 'Шаблонів ще не створено.';

  @override
  String get templatesCreateFirst =>
      'Створіть свій перший супровідний лист або текстовий фрагмент!';

  @override
  String get settingsTitle => 'Налаштування';

  @override
  String get settingsLanguage => 'Мова / Language';

  @override
  String get settingsTheme => 'Тема оформлення';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsThemeSystem => 'Системна';

  @override
  String get settingsPreset => 'Готова тема';

  @override
  String get settingsAccentColor => 'Акцентний колір';

  @override
  String get settingsJobcenterMode => 'Режим Jobcenter / Центру зайнятості';

  @override
  String get reportTitle => 'Підтвердження пошуку роботи';

  @override
  String get reportSavePdf => 'Зберегти PDF';

  @override
  String get reportDate => 'ДАТА ПОДАННЯ';

  @override
  String get reportCompany => 'КОМПАНІЯ';

  @override
  String get reportPosition => 'ПОСАДА';

  @override
  String get reportStatus => 'СТАТУС';

  @override
  String get reportRejectionReason => 'ПРИЧИНА ВІДМОВИ';

  @override
  String get settingsLanguageTitle => 'Мова';

  @override
  String get settingsAppLanguage => 'Мова додатка';

  @override
  String get settingsDesignTitle => 'Дизайн та персоналізація';

  @override
  String get settingsDesignMode => 'Тема оформлення';

  @override
  String get settingsAccentColorTitle => 'Акцентний колір';

  @override
  String get settingsPresetTheme => 'Готова тема';

  @override
  String get settingsPresetDesc => 'Готові комбінації оформлення';

  @override
  String get settingsJobcenterTitle => 'Режим Jobcenter';

  @override
  String get settingsJobcenterDesc =>
      'Відображає вкладку «Підтвердження пошуку роботи»';

  @override
  String get settingsFieldTitle => 'Ваша професія та власні стовпці';

  @override
  String get settingsFieldSelect => 'Виберіть професію';

  @override
  String get settingsCustomCols => 'Власні стовпці (через кому)';

  @override
  String get settingsPersonalData => 'Особисті дані (для експорту в PDF)';

  @override
  String get settingsYourName => 'Ваше ім\'я';

  @override
  String get settingsYourAddress => 'Ваша адреса';

  @override
  String get dashboardTabWeek => 'Поточний тиждень';

  @override
  String get dashboardTabTotal => 'Огляд';

  @override
  String get dashboardMsgStart => 'Кожна подорож починається з першого кроку!';

  @override
  String get dashboardMsgGood => 'Гарний початок! Так тримати!';

  @override
  String get dashboardMsgStrong => 'Чудові результати цього тижня!';

  @override
  String get dashboardMsgFantastic => 'ФАНТАСТИЧНА РОБОТА ЦЬОГО ТИЖНЯ!';

  @override
  String get dashboardNewApps => 'НОВІ ЗАЯВКИ';

  @override
  String get dashboardActiveApps => 'АКТИВНІ ЗАЯВКИ';

  @override
  String get dashboardGoal => 'Ціль на тиждень: ';

  @override
  String get dashboardThisWeek => 'Цього тижня ';

  @override
  String get dashboardFooter =>
      'Продовжуйте в тому ж дусі! Кожен крок наближає вас до роботи мрії. 🚀';

  @override
  String get dashboardVsLastWeek => ' порівняно з минулим тижнем ';

  @override
  String get dashboardAppsLabel => ' заявок';

  @override
  String get appSearch => 'Пошук';

  @override
  String get appSearchHint => 'Пошук компанії, посади, локації...';

  @override
  String get appFilterAll => 'Усі';

  @override
  String get appCheckInbox => 'Перевірити пошту';

  @override
  String get appEmptyTitle => 'Час для першого кроку!';

  @override
  String get appEmptyDesc =>
      'Створіть свою першу заявку та організуйте шлях до роботи вашої мрії.';

  @override
  String get calClickDetails => 'Натисніть на виділений день для деталей.';

  @override
  String get calOverdue => 'Прострочено';

  @override
  String get calFollowUp => 'Повторний контакт';

  @override
  String get reportGeneratedOn => 'Згенеровано: ';

  @override
  String get reportNoApps => 'Заявок не знайдено.';

  @override
  String get navJobcenter => 'Звіт для Jobcenter';

  @override
  String get settingsImapTitle => 'Синхронізація пошти (IMAP)';

  @override
  String get settingsImapDesc => 'Автоматично отримує відмови та запрошення';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Ця функція все ще перебуває в розробці. Автоматичне розпізнавання назв компаній і заявок може бути неточним. Будь ласка, перевіряйте імпортовані записи вручну.';

  @override
  String get settingsImapProvider => 'Провайдер';

  @override
  String get settingsImapManual => 'Вручну / Власний сервер';

  @override
  String get settingsImapServer => 'IMAP-сервер';

  @override
  String get settingsImapPort => 'Порт';

  @override
  String get settingsImapEmail => 'Електронна адреса';

  @override
  String get settingsImapPassword => 'Пароль (пароль додатка)';

  @override
  String get settingsImapSave => 'Зберегти дані';

  @override
  String get settingsExportTitle => 'Експорт даних';

  @override
  String get settingsExportPdf => 'Експортувати звіт для Jobcenter (PDF)';

  @override
  String get settingsExportCsv => 'Експортувати як CSV';

  @override
  String get settingsExportBackup =>
      'Експортувати резервну копію бази даних (.sqlite)';

  @override
  String get settingsExportRestore => 'Відновити базу даних із резервної копії';

  @override
  String get settingsExportRestart =>
      'Інфо: після імпорту потрібен перезапуск додатка.';

  @override
  String get settingsAppQuit => 'Вийти з додатка';

  @override
  String get appNotFoundTitle => 'Нічого не знайдено.';

  @override
  String get appNotFoundDesc => 'За цими налаштуваннями фільтра збігів немає.';

  @override
  String get formTabBasic => 'Основні дані';

  @override
  String get formTabEmails => 'Листи та контакти';

  @override
  String get formTabDocs => 'Документи';

  @override
  String get formTabNotes => 'Нотатки';

  @override
  String get formBasicContact => 'Контакт і адреса';

  @override
  String get formBasicSave => 'Зберегти';

  @override
  String get formBasicInterview => 'Співбесіда';

  @override
  String get formBasicSalary => 'Очікувана зарплата (€/рік)';

  @override
  String get formBasicOpen => 'Відкрито';

  @override
  String get formBasicAccepted => 'Пропозиція';

  @override
  String get formBasicRejected => 'Відхилено';

  @override
  String get formBasicJobLink => 'Посилання на вакансію';

  @override
  String get formBasicJobLinkHint =>
      'Вставте посилання на вакансію або завантажте PDF (наприклад, від Jobcenter) для вилучення даних.';

  @override
  String get formBasicAutofill => 'Автозаповнення';

  @override
  String get formBasicCommute => 'Час у дорозі (хв)';

  @override
  String get formBasicRejectionReason => 'Причина відмови';

  @override
  String get formBasicUploadPdf => 'Або завантажте PDF';

  @override
  String get formBasicStatus => 'Статус';

  @override
  String get formBasicCompanyWeb => 'Вебсайт компанії (наприклад, https://)';

  @override
  String get formBasicMagic => 'Magic Auto-Fill';

  @override
  String get formBasicDelete => 'Видалити';

  @override
  String get formBasicSent => 'Надіслано';

  @override
  String get reportGeneratedAt => 'Згенеровано о:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Ціль на тиждень:';

  @override
  String get weeklyGoalSuffix => ' з 5 заявок';

  @override
  String get weeklyThisWeek => 'Цього тижня ';

  @override
  String get weeklyVs => ' заявок порівняно з минулим тижнем ';

  @override
  String get weeklyApplications => ' заявок';

  @override
  String get weeklyMotivationalFooter =>
      'Так тримати! Кожен крок наближає вас до ідеальної роботи. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Так тримати! Кожен крок наближає вас до ідеальної роботи.';

  @override
  String get templatesTabMy => 'Мої шаблони';

  @override
  String get templatesTabExamples => 'Зразки та приклади';

  @override
  String get promptTitle => 'Генератор промптів для ШІ';

  @override
  String get promptDesc =>
      'Заповніть поля, щоб створити професійний промпт для використання в ChatGPT, Claude або будь-якому іншому ШІ на ваш вибір.';

  @override
  String get promptPosition => 'Посада / Назва вакансії';

  @override
  String get promptCompany => 'Компанія';

  @override
  String get promptSkills => 'Ваші ключові навички та досвід';

  @override
  String get promptTone => 'Тон';

  @override
  String get promptToneDefault => 'професійний та дружній';

  @override
  String get promptGenerate => 'Створити промпт';

  @override
  String get tplInitiative => 'Ініціативна заявка';

  @override
  String get tplReply => 'Відповідь на оголошення про вакансію';

  @override
  String get tplFollowUp => 'Нагадування / Follow-up';

  @override
  String get tplRejection => 'Ввічлива відповідь на відмову';

  @override
  String get tplTypeCover => 'СУПРОВІДНИЙ ЛИСТ';

  @override
  String get tplTypeSnippet => 'ТЕКСТОВИЙ ФРАГМЕНТ';

  @override
  String get noAppsFound => 'Заявок не знайдено.';

  @override
  String get templatesEmptyState => 'Шаблонів ще не створено.';

  @override
  String get templatesEmptyStateSub =>
      'Створіть свій перший супровідний лист або текстовий фрагмент!';

  @override
  String get promptSubtitle =>
      'Заповніть поля та створіть професійний промпт для використання в ChatGPT, Claude або будь-якому іншому ШІ на ваш вибір.';
}
