// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get appName => 'Karyera Mərkəzi';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navApplications => 'Müraciətlər';

  @override
  String get navCalendar => 'Təqvim';

  @override
  String get navTemplates => 'Sənədlərim';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get applicationsTitle => 'Müraciətlərim';

  @override
  String get btnNewApplication => 'Yeni Müraciət';

  @override
  String get statusOpen => 'Açıq';

  @override
  String get statusSent => 'Göndərildi';

  @override
  String get statusInterview => 'Müsahibə';

  @override
  String get statusAccepted => 'Qəbul edildi';

  @override
  String get statusRejected => 'Rədd edildi';

  @override
  String get kanbanPreparation => '📝 Hazırlıq mərhələsində';

  @override
  String get kanbanWaiting => '⏳ Cavab gözlənilir';

  @override
  String get kanbanInterview => '🗣️ Müsahibələrdə';

  @override
  String get kanbanOffers => '🎉 Təkliflər';

  @override
  String get kanbanArchive => '🗑️ Arxiv (Rədd edilənlər)';

  @override
  String get searchPlaceholder => 'Şirkət, pozisiya axtar...';

  @override
  String get emptyApplicationsTitle => 'Hələ ki müraciət yoxdur';

  @override
  String get emptyApplicationsDesc =>
      'Görünür, hələ heç bir müraciət əlavə etməmisiniz. Başlamaq üçün \'Yeni Müraciət\' düyməsini basın!';

  @override
  String get dashboardTitle => 'Müraciət Statistikası';

  @override
  String get dashboardOverview => 'ÜMUMİ BAXIŞ';

  @override
  String get dashboardApplications => 'MÜRACİƏTLƏR';

  @override
  String get dashboardOpen => 'AÇIQ';

  @override
  String get dashboardRejections => 'RƏDD EDİLƏNLƏR';

  @override
  String get dashboardResponseRate => 'CAVAB FAİZİ';

  @override
  String get dashboardRejectionRate => 'RƏDD FAİZİ';

  @override
  String get dashboardInterviews => 'MÜSAHİBƏLƏR';

  @override
  String get dashboardCommute => 'ORT. YOL MÜDDƏTİ';

  @override
  String get dashboardAppsPerMonth => 'AYLIQ MÜRACİƏT SAYI';

  @override
  String get dashboardTopRejectionReasons => 'ƏN ÇOX RƏDD SƏBƏBLƏRİ';

  @override
  String get dashboardNoRejectionReasons =>
      'Hələ heç bir rədd səbəbi qeydə alınmayıb.';

  @override
  String get calendarTitle => 'Müraciət Təqvimi';

  @override
  String get calendarNoEvents => 'Bu gündə heç bir tədbir yoxdur.';

  @override
  String get templatesTitle => 'Şablonlar və Müşayiət Məktubları';

  @override
  String get templatesNew => 'Yeni Şablon';

  @override
  String get templatesEmpty => 'Hələ şablon yaradılmayıb.';

  @override
  String get templatesCreateFirst =>
      'İlk ön məktubunuzu və ya mətn parçanızı yaradın!';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsLanguage => 'Dil / Language';

  @override
  String get settingsTheme => 'Dizayn Rejimi';

  @override
  String get settingsThemeLight => 'İşıqlı';

  @override
  String get settingsThemeDark => 'Tünd';

  @override
  String get settingsThemeSystem => 'Sistem Standartı';

  @override
  String get settingsPreset => 'Hazır Tema';

  @override
  String get settingsAccentColor => 'Vurğu Rəngi';

  @override
  String get settingsJobcenterMode => 'Jobcenter / Məşğulluq Agentliyi Rejimi';

  @override
  String get reportTitle => 'İş Axtarışı Səylərinin Sübutu';

  @override
  String get reportSavePdf => 'PDF-i Saxla';

  @override
  String get reportDate => 'MÜRACİƏT TARİXİ';

  @override
  String get reportCompany => 'ŞİRKƏT';

  @override
  String get reportPosition => 'POZİSİYA';

  @override
  String get reportStatus => 'STATUS';

  @override
  String get reportRejectionReason => 'RƏDD SƏBƏBİ';

  @override
  String get settingsLanguageTitle => 'Dil';

  @override
  String get settingsAppLanguage => 'Tətbiq Dili';

  @override
  String get settingsDesignTitle => 'Dizayn və Fərdiləşdirmə';

  @override
  String get settingsDesignMode => 'Dizayn Rejimi';

  @override
  String get settingsAccentColorTitle => 'Vurğu Rəngi';

  @override
  String get settingsPresetTheme => 'Hazır Tema';

  @override
  String get settingsPresetDesc =>
      'Əvvəlcədən hazırlanmış dizayn kombinasiyaları';

  @override
  String get settingsJobcenterTitle => 'Jobcenter Rejimi';

  @override
  String get settingsJobcenterDesc =>
      '\'İş Axtarışı Səylərinin Sübutu\' tabını göstərir';

  @override
  String get settingsFieldTitle => 'Peşəniz və Xüsusi Sütunlar';

  @override
  String get settingsFieldSelect => 'Peşə seçin';

  @override
  String get settingsCustomCols => 'Xüsusi sütunlar (vergüllə ayrılmış)';

  @override
  String get settingsPersonalData => 'Şəxsi Məlumatlar (PDF İxracı üçün)';

  @override
  String get settingsYourName => 'Adınız';

  @override
  String get settingsYourAddress => 'Ünvanınız';

  @override
  String get dashboardTabWeek => 'Cari Həftə';

  @override
  String get dashboardTabTotal => 'Ümumi Baxış';

  @override
  String get dashboardMsgStart => 'Hər bir səyahət tək bir addımla başlayır!';

  @override
  String get dashboardMsgGood => 'Yaxşı başlanğıc! Belə davam edin!';

  @override
  String get dashboardMsgStrong => 'Bu həftə güclü performans!';

  @override
  String get dashboardMsgFantastic => 'BU HƏFTƏ MÖHTƏŞƏM İŞ ÇIXARDINIZ!';

  @override
  String get dashboardNewApps => 'YENİ MÜRACİƏTLƏR';

  @override
  String get dashboardActiveApps => 'AKTİV MÜRACİƏTLƏR';

  @override
  String get dashboardGoal => 'Həftəlik məqsəd: ';

  @override
  String get dashboardThisWeek => 'Bu həftə ';

  @override
  String get dashboardFooter =>
      'Davam edin! Hər addım sizi xəyal etdiyiniz işə daha da yaxınlaşdırır. 🚀';

  @override
  String get dashboardVsLastWeek => ' ötən həftə ilə müqayisədə ';

  @override
  String get dashboardAppsLabel => ' müraciət';

  @override
  String get appSearch => 'Axtarış';

  @override
  String get appSearchHint => 'Şirkət, pozisiya, məkan axtar...';

  @override
  String get appFilterAll => 'Hamısı';

  @override
  String get appCheckInbox => 'Gələn Qutusunu Yoxla';

  @override
  String get appEmptyTitle => 'İlk addımı atmaq vaxtıdır!';

  @override
  String get appEmptyDesc =>
      'İlk müraciətinizi yaradın və xəyal etdiyiniz işə gedən yolunuzu təşkil edin.';

  @override
  String get calClickDetails => 'Təfərrüatlar üçün vurğulanmış günə klikləyin.';

  @override
  String get calOverdue => 'Vaxtı keçmiş';

  @override
  String get calFollowUp => 'İzləmə';

  @override
  String get reportGeneratedOn => 'Yaradılma tarixi: ';

  @override
  String get reportNoApps => 'Heç bir müraciət tapılmadı.';

  @override
  String get navJobcenter => 'Jobcenter Hesabatı';

  @override
  String get settingsImapTitle => 'E-poçt Sinxronizasiyası (IMAP)';

  @override
  String get settingsImapDesc =>
      'Rədd cavablarını/dəvətləri avtomatik olaraq qəbul edir';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      'Bu xüsusiyyət hələ hazırlanır. Şirkət adlarının və müraciətlərin avtomatik aşkarlanması qeyri-dəqiq ola bilər. Lütfən, idxal edilmiş qeydləri əllə yoxlayın.';

  @override
  String get settingsImapProvider => 'Provayder';

  @override
  String get settingsImapManual => 'Əl ilə / Xüsusi Server';

  @override
  String get settingsImapServer => 'IMAP Serveri';

  @override
  String get settingsImapPort => 'Port';

  @override
  String get settingsImapEmail => 'E-poçt Ünvanı';

  @override
  String get settingsImapPassword => 'Şifrə (Tətbiq Şifrəsi)';

  @override
  String get settingsImapSave => 'Məlumatları Saxla';

  @override
  String get settingsExportTitle => 'Məlumat İxracı';

  @override
  String get settingsExportPdf => 'Jobcenter Hesabatını İxrac Et (PDF)';

  @override
  String get settingsExportCsv => 'CSV olaraq İxrac Et';

  @override
  String get settingsExportBackup =>
      'Verilənlər Bazasının Ehtiyat Nüsxəsini İxrac Et (.sqlite)';

  @override
  String get settingsExportRestore =>
      'Verilənlər Bazasını Ehtiyat Nüsxədən Bərpa Et';

  @override
  String get settingsExportRestart =>
      'Məlumat: İdxaldan sonra tətbiqin yenidən başladılması tələb olunur.';

  @override
  String get settingsAppQuit => 'Tətbiqdən Çıx';

  @override
  String get appNotFoundTitle => 'Heç nə tapılmadı.';

  @override
  String get appNotFoundDesc => 'Bu filtrləmə ayırlarına uyğun nəticə yoxdur.';

  @override
  String get formTabBasic => 'Əsas Məlumatlar';

  @override
  String get formTabEmails => 'E-poçtlar və Əlaqələr';

  @override
  String get formTabDocs => 'Sənədlər';

  @override
  String get formTabNotes => 'Qeydlər';

  @override
  String get formBasicContact => 'Əlaqə və Ünvan';

  @override
  String get formBasicSave => 'Saxla';

  @override
  String get formBasicInterview => 'Müsahibə';

  @override
  String get formBasicSalary => 'Maaş Gözləntisi (€/İl)';

  @override
  String get formBasicOpen => 'Açıq';

  @override
  String get formBasicAccepted => 'Təklif';

  @override
  String get formBasicRejected => 'Rədd edildi';

  @override
  String get formBasicJobLink => 'İş Elanına Keçid';

  @override
  String get formBasicJobLinkHint =>
      'Məlumat çıxarmaq üçün iş elanı linkini yapışdırın və ya PDF (məs., Jobcenter) yükləyin.';

  @override
  String get formBasicAutofill => 'Avtomatik Doldur';

  @override
  String get formBasicCommute => 'Yol Müddəti (Dəq.)';

  @override
  String get formBasicRejectionReason => 'Rədd Səbəbi';

  @override
  String get formBasicUploadPdf => 'Və ya PDF yükləyin';

  @override
  String get formBasicStatus => 'Status';

  @override
  String get formBasicCompanyWeb => 'Şirkət Veb-saytı (məs., https://)';

  @override
  String get formBasicMagic => 'Sehrli Avtomatik Doldurma';

  @override
  String get formBasicDelete => 'Sil';

  @override
  String get formBasicSent => 'Göndərildi';

  @override
  String get reportGeneratedAt => 'Yaradılma vaxtı:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => 'Həftəlik Məqsəd:';

  @override
  String get weeklyGoalSuffix => ' / 5 müraciət';

  @override
  String get weeklyThisWeek => 'Bu həftə ';

  @override
  String get weeklyVs => ' müraciət, ötən həftə ilə müqayisədə ';

  @override
  String get weeklyApplications => ' müraciət';

  @override
  String get weeklyMotivationalFooter =>
      'Belə davam edin! Hər addım sizi mükəmməl işə daha da yaxınlaşdırır. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      'Belə davam edin! Hər addım sizi mükəmməl işə daha da yaxınlaşdırır.';

  @override
  String get templatesTabMy => 'Şablonlarım';

  @override
  String get templatesTabExamples => 'Nümunələr və Taslaklar';

  @override
  String get promptTitle => 'Süni İntellekt Prompt Generatoru';

  @override
  String get promptDesc =>
      'ChatGPT, Claude və ya seçdiyiniz hər hansı digər süni intellektdə istifadə edə biləcəyiniz peşəkar prompt yaratmaq üçün sahələri doldurun.';

  @override
  String get promptPosition => 'Pozisiya / İş Başlığı';

  @override
  String get promptCompany => 'Şirkət';

  @override
  String get promptSkills => 'Əsas Bacarıqlarınız və Təcrübəniz';

  @override
  String get promptTone => 'Ton';

  @override
  String get promptToneDefault => 'peşəkar və dostyana';

  @override
  String get promptGenerate => 'Prompt Yarat';

  @override
  String get tplInitiative => 'Ümumi Müraciət';

  @override
  String get tplReply => 'İş Elanına Cavab';

  @override
  String get tplFollowUp => 'Xatırlatma / İzləmə';

  @override
  String get tplRejection => 'Nəzakətli Rədd Cavabı';

  @override
  String get tplTypeCover => 'ÖN MƏKTUB';

  @override
  String get tplTypeSnippet => 'MƏTN PARÇASI';

  @override
  String get noAppsFound => 'Heç bir müraciət tapılmadı.';

  @override
  String get templatesEmptyState => 'Hələ şablon yaradılmayıb.';

  @override
  String get templatesEmptyStateSub =>
      'İlk ön məktubunuzu və ya mətn parçanızı yaradın!';

  @override
  String get promptSubtitle =>
      'Sahələri doldurun və ChatGPT, Claude və ya istədiyiniz hər hansı digər süni intellektdə istifadə edə biləcəyiniz peşəkar prompt yaradın.';
}
