// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '커리어 센터';

  @override
  String get navDashboard => '대시보드';

  @override
  String get navApplications => '지원 현황';

  @override
  String get navCalendar => '캘린더';

  @override
  String get navTemplates => '내 문서';

  @override
  String get navSettings => '설정';

  @override
  String get applicationsTitle => '내 지원 현황';

  @override
  String get btnNewApplication => '새 지원 추가';

  @override
  String get statusOpen => '진행 중';

  @override
  String get statusSent => '제출 완료';

  @override
  String get statusInterview => '면접';

  @override
  String get statusAccepted => '합격';

  @override
  String get statusRejected => '불합격';

  @override
  String get kanbanPreparation => '📝 준비 중';

  @override
  String get kanbanWaiting => '⏳ 결과 대기 중';

  @override
  String get kanbanInterview => '🗣️ 면접 진행 중';

  @override
  String get kanbanOffers => '🎉 최종 합격';

  @override
  String get kanbanArchive => '🗑️ 보관함 (불합격)';

  @override
  String get searchPlaceholder => '회사명, 직무 검색...';

  @override
  String get emptyApplicationsTitle => '아직 지원 내역이 없습니다';

  @override
  String get emptyApplicationsDesc =>
      '아직 등록된 지원 내역이 없습니다. \'새 지원 추가\'를 클릭하여 시작해보세요!';

  @override
  String get dashboardTitle => '지원 통계';

  @override
  String get dashboardOverview => '개요';

  @override
  String get dashboardApplications => '총 지원 수';

  @override
  String get dashboardOpen => '진행 중';

  @override
  String get dashboardRejections => '불합격';

  @override
  String get dashboardResponseRate => '응답률';

  @override
  String get dashboardRejectionRate => '불합격률';

  @override
  String get dashboardInterviews => '면접';

  @override
  String get dashboardCommute => '평균 통근 시간';

  @override
  String get dashboardAppsPerMonth => '월별 지원 수';

  @override
  String get dashboardTopRejectionReasons => '주요 불합격 사유';

  @override
  String get dashboardNoRejectionReasons => '아직 기록된 불합격 사유가 없습니다.';

  @override
  String get calendarTitle => '지원 일정 캘린더';

  @override
  String get calendarNoEvents => '이 날에는 일정이 없습니다.';

  @override
  String get templatesTitle => '템플릿 및 자기소개서';

  @override
  String get templatesNew => '새 템플릿';

  @override
  String get templatesEmpty => '아직 생성된 템플릿이 없습니다.';

  @override
  String get templatesCreateFirst => '첫 번째 자기소개서나 텍스트 문구를 작성해보세요!';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsLanguage => '언어 / Language';

  @override
  String get settingsTheme => '테마 모드';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsThemeSystem => '시스템 기본값';

  @override
  String get settingsPreset => '프리셋 테마';

  @override
  String get settingsAccentColor => '강조 색상';

  @override
  String get settingsJobcenterMode => 'Jobcenter / 고용센터 모드';

  @override
  String get reportTitle => '구직 활동 증빙서';

  @override
  String get reportSavePdf => 'PDF 저장';

  @override
  String get reportDate => '지원 일자';

  @override
  String get reportCompany => '기업명';

  @override
  String get reportPosition => '직무';

  @override
  String get reportStatus => '상태';

  @override
  String get reportRejectionReason => '불합격 사유';

  @override
  String get settingsLanguageTitle => '언어';

  @override
  String get settingsAppLanguage => '앱 언어';

  @override
  String get settingsDesignTitle => '디자인 및 맞춤 설정';

  @override
  String get settingsDesignMode => '테마 모드';

  @override
  String get settingsAccentColorTitle => '강조 색상';

  @override
  String get settingsPresetTheme => '프리셋 테마';

  @override
  String get settingsPresetDesc => '사전 설정된 디자인 조합';

  @override
  String get settingsJobcenterTitle => 'Jobcenter 모드';

  @override
  String get settingsJobcenterDesc => '\'구직 활동 증빙서\' 탭 표시';

  @override
  String get settingsFieldTitle => '직종 및 사용자 지정 열';

  @override
  String get settingsFieldSelect => '직종 선택';

  @override
  String get settingsCustomCols => '사용자 지정 열 (쉼표로 구분)';

  @override
  String get settingsPersonalData => '개인 정보 (PDF 내보내기용)';

  @override
  String get settingsYourName => '이름';

  @override
  String get settingsYourAddress => '주소';

  @override
  String get dashboardTabWeek => '이번 주';

  @override
  String get dashboardTabTotal => '전체 개요';

  @override
  String get dashboardMsgStart => '모든 여정은 첫걸음에서 시작됩니다!';

  @override
  String get dashboardMsgGood => '좋은 출발입니다! 계속 힘내세요!';

  @override
  String get dashboardMsgStrong => '이번 주 활약이 대단하네요!';

  @override
  String get dashboardMsgFantastic => '이번 주 정말 멋진 성과입니다!';

  @override
  String get dashboardNewApps => '신규 지원';

  @override
  String get dashboardActiveApps => '진행 중인 지원';

  @override
  String get dashboardGoal => '주간 목표: ';

  @override
  String get dashboardThisWeek => '이번 주 ';

  @override
  String get dashboardFooter => '계속 나아가세요! 한 걸음마다 꿈의 직장에 더 가까워집니다. 🚀';

  @override
  String get dashboardVsLastWeek => ' vs. 지난주 ';

  @override
  String get dashboardAppsLabel => '건의 지원';

  @override
  String get appSearch => '검색';

  @override
  String get appSearchHint => '회사명, 직무, 근무지 검색...';

  @override
  String get appFilterAll => '전체';

  @override
  String get appCheckInbox => '받은편지함 확인';

  @override
  String get appEmptyTitle => '첫걸음을 내딛을 시간입니다!';

  @override
  String get appEmptyDesc => '첫 지원서를 작성하고 꿈의 직장을 향한 여정을 체계적으로 관리해보세요.';

  @override
  String get calClickDetails => '상세 일정을 보려면 강조 표시된 날짜를 클릭하세요.';

  @override
  String get calOverdue => '기한 지남';

  @override
  String get calFollowUp => '후속 연락';

  @override
  String get reportGeneratedOn => '생성 일시: ';

  @override
  String get reportNoApps => '등록된 지원 내역이 없습니다.';

  @override
  String get navJobcenter => 'Jobcenter 보고서';

  @override
  String get settingsImapTitle => '이메일 동기화 (IMAP)';

  @override
  String get settingsImapDesc => '불합격/면접 제안 메일을 자동으로 수신합니다';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      '이 기능은 아직 개발 중입니다. 회사명과 지원서의 자동 감지가 정확하지 않을 수 있으니 가져온 항목을 직접 확인해 주세요.';

  @override
  String get settingsImapProvider => '이메일 서비스 제공업체';

  @override
  String get settingsImapManual => '수동 설정 / 사용자 지정 서버';

  @override
  String get settingsImapServer => 'IMAP 서버';

  @override
  String get settingsImapPort => '포트';

  @override
  String get settingsImapEmail => '이메일 주소';

  @override
  String get settingsImapPassword => '비밀번호 (앱 비밀번호)';

  @override
  String get settingsImapSave => '정보 저장';

  @override
  String get settingsExportTitle => '데이터 내보내기';

  @override
  String get settingsExportPdf => 'Jobcenter 보고서 내보내기 (PDF)';

  @override
  String get settingsExportCsv => 'CSV 파일로 내보내기';

  @override
  String get settingsExportBackup => '데이터베이스 백업 내보내기 (.sqlite)';

  @override
  String get settingsExportRestore => '백업에서 데이터베이스 복원';

  @override
  String get settingsExportRestart => '안내: 가져오기 후 앱을 다시 시작해야 합니다.';

  @override
  String get settingsAppQuit => '앱 종료';

  @override
  String get appNotFoundTitle => '검색 결과가 없습니다.';

  @override
  String get appNotFoundDesc => '현재 필터 조건과 일치하는 항목이 없습니다.';

  @override
  String get formTabBasic => '기본 정보';

  @override
  String get formTabEmails => '이메일 및 연락처';

  @override
  String get formTabDocs => '문서';

  @override
  String get formTabNotes => '메모';

  @override
  String get formBasicContact => '연락처 및 주소';

  @override
  String get formBasicSave => '저장';

  @override
  String get formBasicInterview => '면접';

  @override
  String get formBasicSalary => '희망 연봉 (€/연)';

  @override
  String get formBasicOpen => '진행 중';

  @override
  String get formBasicAccepted => '합격';

  @override
  String get formBasicRejected => '불합격';

  @override
  String get formBasicJobLink => '채용 공고 링크';

  @override
  String get formBasicJobLinkHint =>
      '채용 공고 링크를 붙여넣거나 PDF(예: Jobcenter)를 업로드하여 데이터를 추출하세요.';

  @override
  String get formBasicAutofill => '자동 완성';

  @override
  String get formBasicCommute => '통근 시간 (분)';

  @override
  String get formBasicRejectionReason => '불합격 사유';

  @override
  String get formBasicUploadPdf => '또는 PDF 업로드';

  @override
  String get formBasicStatus => '상태';

  @override
  String get formBasicCompanyWeb => '회사 웹사이트 (예: https://)';

  @override
  String get formBasicMagic => '매직 자동 완성';

  @override
  String get formBasicDelete => '삭제';

  @override
  String get formBasicSent => '제출 완료';

  @override
  String get reportGeneratedAt => '생성 일시:';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => '주간 목표:';

  @override
  String get weeklyGoalSuffix => ' / 5건 지원';

  @override
  String get weeklyThisWeek => '이번 주 ';

  @override
  String get weeklyVs => '건 지원 vs. 지난주 ';

  @override
  String get weeklyApplications => '건 지원';

  @override
  String get weeklyMotivationalFooter => '계속 힘내세요! 한 걸음마다 꿈의 직장에 더 가까워집니다. 🚀';

  @override
  String get weeklyMotivationalFooterNoIcon =>
      '계속 힘내세요! 한 걸음마다 꿈의 직장에 더 가까워집니다.';

  @override
  String get templatesTabMy => '내 템플릿';

  @override
  String get templatesTabExamples => '서식 및 예시';

  @override
  String get promptTitle => 'AI 프롬프트 생성기';

  @override
  String get promptDesc =>
      '항목을 입력하여 ChatGPT, Claude 등 원하는 AI에서 바로 사용할 수 있는 전문적인 프롬프트를 생성하세요.';

  @override
  String get promptPosition => '직무 / 포지션';

  @override
  String get promptCompany => '회사명';

  @override
  String get promptSkills => '주요 보유 역량 및 경력';

  @override
  String get promptTone => '어조';

  @override
  String get promptToneDefault => '전문적이고 친근하게';

  @override
  String get promptGenerate => '프롬프트 생성';

  @override
  String get tplInitiative => '자유 지원';

  @override
  String get tplReply => '채용 공고 지원';

  @override
  String get tplFollowUp => '진행 상황 문의 / 후속 연락';

  @override
  String get tplRejection => '정중한 불합격 회신';

  @override
  String get tplTypeCover => '자기소개서';

  @override
  String get tplTypeSnippet => '텍스트 문구';

  @override
  String get noAppsFound => '등록된 지원 내역이 없습니다.';

  @override
  String get templatesEmptyState => '아직 생성된 템플릿이 없습니다.';

  @override
  String get templatesEmptyStateSub => '첫 번째 자기소개서나 텍스트 문구를 작성해보세요!';

  @override
  String get promptSubtitle =>
      '항목을 입력하여 ChatGPT, Claude 등 원하는 AI에서 바로 사용할 수 있는 전문적인 프롬프트를 생성하세요.';
}
