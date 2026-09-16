// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Центр Карьеры';

  @override
  String get navDashboard => 'Панель управления';

  @override
  String get navApplications => 'Отклики';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navTemplates => 'Мои документы';

  @override
  String get navSettings => 'Настройки';

  @override
  String get applicationsTitle => 'Мои отклики';

  @override
  String get btnNewApplication => 'Новый отклик';

  @override
  String get statusOpen => 'Открыто';

  @override
  String get statusSent => 'Отправлено';

  @override
  String get statusInterview => 'Собеседование';

  @override
  String get statusAccepted => 'Принято';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get kanbanPreparation => '📝 Подготовка';

  @override
  String get kanbanWaiting => '⏳ Ожидание ответа';

  @override
  String get kanbanInterview => '🗣️ Собеседования';

  @override
  String get kanbanOffers => '🎉 Предложения';

  @override
  String get kanbanArchive => '🗑️ Архив (отказы)';

  @override
  String get searchPlaceholder => 'Поиск по компании, должности...';

  @override
  String get emptyApplicationsTitle => 'Пока нет откликов';

  @override
  String get emptyApplicationsDesc =>
      'Похоже, вы еще не добавили ни одного отклика. Нажмите \'Новый отклик\', чтобы начать!';

  @override
  String get dashboardTitle => 'Статистика откликов';

  @override
  String get dashboardOverview => 'ОБЗОР';

  @override
  String get dashboardApplications => 'ОТКЛИКИ';

  @override
  String get dashboardOpen => 'ОТКРЫТЫЕ';

  @override
  String get dashboardRejections => 'ОТКАЗЫ';

  @override
  String get dashboardResponseRate => 'ДОЛЯ ОТВЕТОВ';

  @override
  String get dashboardRejectionRate => 'ДОЛЯ ОТКАЗОВ';

  @override
  String get dashboardInterviews => 'СОБЕСЕДОВАНИЯ';

  @override
  String get dashboardCommute => 'СР. ВРЕМЯ В ПУТИ';

  @override
  String get dashboardAppsPerMonth => 'ОТКЛИКОВ В МЕСЯЦ';

  @override
  String get dashboardTopRejectionReasons => 'ТОП ПРИЧИН ОТКАЗОВ';

  @override
  String get dashboardNoRejectionReasons => 'Причины отказов пока не указаны.';

  @override
  String get calendarTitle => 'Календарь откликов';

  @override
  String get calendarNoEvents => 'В этот день нет событий.';

  @override
  String get templatesTitle => 'Шаблоны и сопроводительные письма';

  @override
  String get templatesNew => 'Новый шаблон';

  @override
  String get templatesEmpty => 'Шаблоны еще не созданы.';

  @override
  String get templatesCreateFirst =>
      'Создайте свое первое сопроводительное письмо или текстовый фрагмент!';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsLanguage => 'Язык / Language';

  @override
  String get settingsTheme => 'Тема оформления';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Темная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsPreset => 'Готовая тема';

  @override
  String get settingsAccentColor => 'Акцентный цвет';

  @override
  String get settingsJobcenterMode => 'Режим Jobcenter / Агентства занятости';

  @override
  String get reportTitle => 'Подтверждение активности поиска';

  @override
  String get reportSavePdf => 'Сохранить PDF';

  @override
  String get reportDate => 'ДАТА ОТКЛИКА';

  @override
  String get reportCompany => 'КОМПАНИЯ';

  @override
  String get reportPosition => 'ДОЛЖНОСТЬ';

  @override
  String get reportStatus => 'СТАТУС';

  @override
  String get reportRejectionReason => 'ПРИЧИНА ОТКАЗА';

  @override
  String get settingsLanguageTitle => 'Язык';

  @override
  String get settingsAppLanguage => 'Язык приложения';

  @override
  String get settingsDesignTitle => 'Оформление и персонализация';

  @override
  String get settingsDesignMode => 'Тема оформления';

  @override
  String get settingsAccentColorTitle => 'Акцентный цвет';

  @override
  String get settingsPresetTheme => 'Готовая тема';

  @override
  String get settingsPresetDesc => 'Готовые цветовые сочетания';

  @override
  String get settingsJobcenterTitle => 'Режим Jobcenter';

  @override
  String get settingsJobcenterDesc =>
      'Показывает вкладку «Подтверждение поиска»';

  @override
  String get settingsFieldTitle => 'Ваша профессия и свои столбцы';

  @override
  String get settingsFieldSelect => 'Выберите профессию';

  @override
  String get settingsCustomCols => 'Дополнительные столбцы (через запятую)';

  @override
  String get settingsPersonalData => 'Личные данные (для экспорта в PDF)';

  @override
  String get settingsYourName => 'Ваше имя';

  @override
  String get settingsYourAddress => 'Ваш адрес';

  @override
  String get dashboardTabWeek => 'Текущая неделя';

  @override
  String get dashboardTabTotal => 'Общий обзор';

  @override
  String get dashboardMsgStart => 'Каждый путь начинается с первого шага!';

  @override
  String get dashboardMsgGood => 'Хорошее начало! Так держать!';

  @override
  String get dashboardMsgStrong => 'Отличные результаты на этой неделе!';

  @override
  String get dashboardMsgFantastic => 'ПОТРЯСАЮЩАЯ РАБОТА НА ЭТОЙ НЕДЕЛЕ!';

  @override
  String get dashboardNewApps => 'НОВЫЕ ОТКЛИКИ';

  @override
  String get dashboardActiveApps => 'АКТИВНЫЕ ОТКЛИКИ';

  @override
  String get dashboardGoal => 'Цель на неделю: ';

  @override
  String get dashboardThisWeek => 'На этой неделе ';

  @override
  String get dashboardFooter =>
      'Продолжайте в том же духе! Каждый шаг приближает вас к работе мечты. 🚀';

  @override
  String get dashboardVsLastWeek => ' по сравнению с прошлой неделей ';

  @override
  String get dashboardAppsLabel => ' откликов';

  @override
  String get appSearch => 'Поиск';

  @override
  String get appSearchHint => 'Поиск по компании, должности, городу...';

  @override
  String get appFilterAll => 'Все';

  @override
  String get appCheckInbox => 'Проверить почту';

  @override
  String get appEmptyTitle => 'Время сделать первый шаг!';

  @override
  String get appEmptyDesc =>
      'Создайте свой первый отклик и организуйте путь к работе мечты.';

  @override
  String get calClickDetails => 'Нажмите на выделенный день для подробностей.';

  @override
  String get calOverdue => 'Просрочено';

  @override
  String get calFollowUp => 'Напоминание';

  @override
  String get reportGeneratedOn => 'Сформировано: ';

  @override
  String get reportNoApps => 'Отклики не найдены.';

  @override
  String get navJobcenter => 'Отчет для Jobcenter';

  @override
  String get settingsImapTitle => 'Синхронизация почты (IMAP)';

  @override
  String get settingsImapDesc => 'Автоматически получает отказы и приглашения';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Эта функция находится в разработке. Автоматическое распознавание названий компаний и откликов может быть неточным. Пожалуйста, проверяйте импортированные записи вручную.';

  @override
  String get settingsImapProvider => 'Провайдер';

  @override
  String get settingsImapManual => 'Вручную / Пользовательский сервер';

  @override
  String get settingsImapServer => 'IMAP-сервер';

  @override
  String get settingsImapPort => 'Порт';

  @override
  String get settingsImapEmail => 'Email-адрес';

  @override
  String get settingsImapPassword => 'Пароль (пароль приложения)';

  @override
  String get settingsImapSave => 'Сохранить данные';

  @override
  String get settingsExportTitle => 'Экспорт данных';

  @override
  String get settingsExportPdf => 'Экспорт отчета для Jobcenter (PDF)';

  @override
  String get settingsExportCsv => 'Экспорт в CSV';

  @override
  String get settingsExportBackup =>
      'Экспорт резервной копии базы данных (.sqlite)';

  @override
  String get settingsExportRestore =>
      'Восстановить базу данных из резервной копии';

  @override
  String get settingsExportRestart =>
      'Информация: после импорта требуется перезапуск приложения.';

  @override
  String get settingsAppQuit => 'Выйти из приложения';

  @override
  String get appNotFoundTitle => 'Ничего не найдено.';

  @override
  String get appNotFoundDesc => 'По этим параметрам фильтра ничего не найдено.';

  @override
  String get formTabBasic => 'Основные данные';

  @override
  String get formTabEmails => 'Письма и контакты';

  @override
  String get formTabDocs => 'Документы';

  @override
  String get formTabNotes => 'Заметки';

  @override
  String get formBasicContact => 'Контакт и адрес';

  @override
  String get formBasicSave => 'Сохранить';

  @override
  String get formBasicInterview => 'Собеседование';

  @override
  String get formBasicSalary => 'Ожидаемая зарплата (€/год)';

  @override
  String get formBasicOpen => 'Открыто';

  @override
  String get formBasicAccepted => 'Предложение';

  @override
  String get formBasicRejected => 'Отказ';

  @override
  String get formBasicJobLink => 'Ссылка на вакансию';

  @override
  String get formBasicJobLinkHint =>
      'Вставьте ссылку на вакансию или загрузите PDF (например, из Jobcenter) для извлечения данных.';

  @override
  String get formBasicAutofill => 'Автозаполнение';

  @override
  String get formBasicCommute => 'Время в пути (мин.)';

  @override
  String get formBasicRejectionReason => 'Причина отказа';

  @override
  String get formBasicUploadPdf => 'Или загрузите PDF';

  @override
  String get formBasicStatus => 'Статус';

  @override
  String get formBasicCompanyWeb => 'Сайт компании (например, https://)';

  @override
  String get formBasicMagic => 'Magic Auto-Fill';

  @override
  String get formBasicDelete => 'Удалить';

  @override
  String get formBasicSent => 'Отправлено';

  @override
  String get reportGeneratedAt => 'Сформировано:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Цель на неделю:';

  @override
  String get weeklyGoalSuffix => ' из 5 откликов';

  @override
  String get weeklyThisWeek => 'На этой неделе ';

  @override
  String get weeklyVs => ' откликов по сравнению с прошлой неделей: ';

  @override
  String get weeklyApplications => ' откликов';

  @override
  String get weeklyMotivationalFooter =>
      'Так держать! Каждый шаг приближает вас к идеальной работе. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Так держать! Каждый шаг приближает вас к идеальной работе.';

  @override
  String get templatesTabMy => 'Мои шаблоны';

  @override
  String get templatesTabExamples => 'Шаблоны и примеры';

  @override
  String get promptTitle => 'Генератор AI-промптов';

  @override
  String get promptDesc =>
      'Заполните поля, чтобы создать профессиональный промпт для использования в ChatGPT, Claude или любом другом ИИ на ваш выбор.';

  @override
  String get promptPosition => 'Должность / Название вакансии';

  @override
  String get promptCompany => 'Компания';

  @override
  String get promptSkills => 'Ключевые навыки и опыт';

  @override
  String get promptTone => 'Тон';

  @override
  String get promptToneDefault => 'профессиональный и дружелюбный';

  @override
  String get promptGenerate => 'Сгенерировать промпт';

  @override
  String get tplInitiative => 'Инициативный отклик';

  @override
  String get tplReply => 'Отклик на вакансию';

  @override
  String get tplFollowUp => 'Напоминание / Follow-up';

  @override
  String get tplRejection => 'Вежливый ответ на отказ';

  @override
  String get tplTypeCover => 'СОПРОВОДИТЕЛЬНОЕ ПИСЬМО';

  @override
  String get tplTypeSnippet => 'ТЕКСТОВЫЙ ФРАГМЕНТ';

  @override
  String get noAppsFound => 'Отклики не найдены.';

  @override
  String get templatesEmptyState => 'Шаблоны еще не созданы.';

  @override
  String get templatesEmptyStateSub =>
      'Создайте свое первое сопроводительное письмо или текстовый фрагмент!';

  @override
  String get promptSubtitle =>
      'Заполните поля и создайте профессиональный промпт для использования в ChatGPT, Claude или любом другом ИИ на ваш выбор.';
}
