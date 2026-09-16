// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '求职中心';

  @override
  String get navDashboard => '仪表盘';

  @override
  String get navApplications => '求职申请';

  @override
  String get navCalendar => '日历';

  @override
  String get navTemplates => '我的文档';

  @override
  String get navSettings => '设置';

  @override
  String get applicationsTitle => '我的申请';

  @override
  String get btnNewApplication => '新建申请';

  @override
  String get statusOpen => '待处理';

  @override
  String get statusSent => '已发送';

  @override
  String get statusInterview => '面试';

  @override
  String get statusAccepted => '录用';

  @override
  String get statusRejected => '已拒绝';

  @override
  String get kanbanPreparation => '📝 准备中';

  @override
  String get kanbanWaiting => '⏳ 等待回复';

  @override
  String get kanbanInterview => '🗣️ 面试中';

  @override
  String get kanbanOffers => '🎉 收到录用';

  @override
  String get kanbanArchive => '🗑️ 归档（已拒绝）';

  @override
  String get searchPlaceholder => '搜索公司、职位...';

  @override
  String get emptyApplicationsTitle => '暂无申请';

  @override
  String get emptyApplicationsDesc => '您似乎还没有添加任何申请。点击“新建申请”开始吧！';

  @override
  String get dashboardTitle => '求职申请统计';

  @override
  String get dashboardOverview => '总览';

  @override
  String get dashboardApplications => '申请总数';

  @override
  String get dashboardOpen => '待处理';

  @override
  String get dashboardRejections => '已拒绝';

  @override
  String get dashboardResponseRate => '回复率';

  @override
  String get dashboardRejectionRate => '拒绝率';

  @override
  String get dashboardInterviews => '面试';

  @override
  String get dashboardCommute => '平均通勤时间';

  @override
  String get dashboardAppsPerMonth => '每月申请数';

  @override
  String get dashboardTopRejectionReasons => '主要拒绝原因';

  @override
  String get dashboardNoRejectionReasons => '暂无记录的拒绝原因。';

  @override
  String get calendarTitle => '求职日历';

  @override
  String get calendarNoEvents => '当天暂无日程安排。';

  @override
  String get templatesTitle => '模板与求职信';

  @override
  String get templatesNew => '新建模板';

  @override
  String get templatesEmpty => '暂未创建任何模板。';

  @override
  String get templatesCreateFirst => '创建您的第一份求职信或常用文本片段！';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsLanguage => '语言 / Language';

  @override
  String get settingsTheme => '外观模式';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsPreset => '预设主题';

  @override
  String get settingsAccentColor => '强调色';

  @override
  String get settingsJobcenterMode => 'Jobcenter / 就业局模式';

  @override
  String get reportTitle => '求职努力证明';

  @override
  String get reportSavePdf => '保存为 PDF';

  @override
  String get reportDate => '申请日期';

  @override
  String get reportCompany => '公司';

  @override
  String get reportPosition => '职位';

  @override
  String get reportStatus => '状态';

  @override
  String get reportRejectionReason => '拒绝原因';

  @override
  String get settingsLanguageTitle => '语言';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsDesignTitle => '外观与个性化';

  @override
  String get settingsDesignMode => '外观模式';

  @override
  String get settingsAccentColorTitle => '强调色';

  @override
  String get settingsPresetTheme => '预设主题';

  @override
  String get settingsPresetDesc => '预设的设计搭配';

  @override
  String get settingsJobcenterTitle => 'Jobcenter 模式';

  @override
  String get settingsJobcenterDesc => '显示“求职努力证明”标签页';

  @override
  String get settingsFieldTitle => '您的职业与自定义列';

  @override
  String get settingsFieldSelect => '选择职业';

  @override
  String get settingsCustomCols => '自定义列（逗号分隔）';

  @override
  String get settingsPersonalData => '个人信息（用于 PDF 导出）';

  @override
  String get settingsYourName => '您的姓名';

  @override
  String get settingsYourAddress => '您的地址';

  @override
  String get dashboardTabWeek => '本周';

  @override
  String get dashboardTabTotal => '总览';

  @override
  String get dashboardMsgStart => '千里之行，始于足下！';

  @override
  String get dashboardMsgGood => '良好的开端！继续加油！';

  @override
  String get dashboardMsgStrong => '本周表现很棒！';

  @override
  String get dashboardMsgFantastic => '本周表现极为出色！';

  @override
  String get dashboardNewApps => '新增申请';

  @override
  String get dashboardActiveApps => '进行中申请';

  @override
  String get dashboardGoal => '本周目标： ';

  @override
  String get dashboardThisWeek => '本周 ';

  @override
  String get dashboardFooter => '坚持不懈！每一步都让你更接近理想工作。🚀';

  @override
  String get dashboardVsLastWeek => ' 对比上周 ';

  @override
  String get dashboardAppsLabel => ' 份申请';

  @override
  String get appSearch => '搜索';

  @override
  String get appSearchHint => '搜索公司、职位、地点...';

  @override
  String get appFilterAll => '全部';

  @override
  String get appCheckInbox => '检查收件箱';

  @override
  String get appEmptyTitle => '迈出第一步的时候到了！';

  @override
  String get appEmptyDesc => '创建您的第一份申请，开启通往理想职业的旅程。';

  @override
  String get calClickDetails => '点击有标记的日期查看详情。';

  @override
  String get calOverdue => '逾期';

  @override
  String get calFollowUp => '跟进';

  @override
  String get reportGeneratedOn => '生成于： ';

  @override
  String get reportNoApps => '未找到申请记录。';

  @override
  String get navJobcenter => 'Jobcenter 报告';

  @override
  String get settingsImapTitle => '电子邮件同步 (IMAP)';

  @override
  String get settingsImapDesc => '自动接收拒绝/面试邀请';

  @override
  String get settingsImapExp => 'EXPERIMENTAL';

  @override
  String get settingsImapWarning =>
      '此功能仍在开发中。对公司名称和求职申请的自动识别可能不够准确。请手动核对导入的记录。';

  @override
  String get settingsImapProvider => '服务商';

  @override
  String get settingsImapManual => '手动 / 自定义服务器';

  @override
  String get settingsImapServer => 'IMAP 服务器';

  @override
  String get settingsImapPort => '端口';

  @override
  String get settingsImapEmail => '电子邮箱地址';

  @override
  String get settingsImapPassword => '密码（应用密码）';

  @override
  String get settingsImapSave => '保存数据';

  @override
  String get settingsExportTitle => '数据导出';

  @override
  String get settingsExportPdf => '导出 Jobcenter 证明报告 (PDF)';

  @override
  String get settingsExportCsv => '导出为 CSV';

  @override
  String get settingsExportBackup => '导出数据库备份 (.sqlite)';

  @override
  String get settingsExportRestore => '从备份恢复数据库';

  @override
  String get settingsExportRestart => '提示：导入后需要重启应用。';

  @override
  String get settingsAppQuit => '退出应用';

  @override
  String get appNotFoundTitle => '未找到相关内容。';

  @override
  String get appNotFoundDesc => '没有符合此筛选条件的匹配项。';

  @override
  String get formTabBasic => '基本信息';

  @override
  String get formTabEmails => '邮件与联系人';

  @override
  String get formTabDocs => '文档';

  @override
  String get formTabNotes => '备注';

  @override
  String get formBasicContact => '联系方式与地址';

  @override
  String get formBasicSave => '保存';

  @override
  String get formBasicInterview => '面试';

  @override
  String get formBasicSalary => '期望薪资 (€/年)';

  @override
  String get formBasicOpen => '待处理';

  @override
  String get formBasicAccepted => '录用';

  @override
  String get formBasicRejected => '已拒绝';

  @override
  String get formBasicJobLink => '招聘链接';

  @override
  String get formBasicJobLinkHint => '粘贴招聘链接或上传 PDF（例如来自 Jobcenter）以提取数据。';

  @override
  String get formBasicAutofill => '自动填写';

  @override
  String get formBasicCommute => '通勤时间（分钟）';

  @override
  String get formBasicRejectionReason => '拒绝原因';

  @override
  String get formBasicUploadPdf => '或上传 PDF';

  @override
  String get formBasicStatus => '状态';

  @override
  String get formBasicCompanyWeb => '公司网站（例如 https://）';

  @override
  String get formBasicMagic => '智能自动填充';

  @override
  String get formBasicDelete => '删除';

  @override
  String get formBasicSent => '已发送';

  @override
  String get reportGeneratedAt => '生成时间：';

  @override
  String get reportTimeSuffix => '';

  @override
  String get weeklyGoal => '本周目标：';

  @override
  String get weeklyGoalSuffix => ' / 5 份申请';

  @override
  String get weeklyThisWeek => '本周 ';

  @override
  String get weeklyVs => ' 份申请，对比上周 ';

  @override
  String get weeklyApplications => ' 份申请';

  @override
  String get weeklyMotivationalFooter => '继续加油！每一步都让你更接近理想工作。🚀';

  @override
  String get weeklyMotivationalFooterNoIcon => '继续加油！每一步都让你更接近理想工作。';

  @override
  String get templatesTabMy => '我的模板';

  @override
  String get templatesTabExamples => '范本与示例';

  @override
  String get promptTitle => 'AI 提示词生成器';

  @override
  String get promptDesc => '填写以下字段，即可生成专业的提示词，供您在 ChatGPT、Claude 或其他自选 AI 中使用。';

  @override
  String get promptPosition => '职位 / 岗位名称';

  @override
  String get promptCompany => '公司';

  @override
  String get promptSkills => '核心技能与经验';

  @override
  String get promptTone => '语气风格';

  @override
  String get promptToneDefault => '专业且亲切';

  @override
  String get promptGenerate => '生成提示词';

  @override
  String get tplInitiative => '自荐申请';

  @override
  String get tplReply => '应聘回复';

  @override
  String get tplFollowUp => '跟进催询';

  @override
  String get tplRejection => '礼貌回复拒绝信';

  @override
  String get tplTypeCover => '求职信';

  @override
  String get tplTypeSnippet => '常用文本片段';

  @override
  String get noAppsFound => '未找到申请记录。';

  @override
  String get templatesEmptyState => '暂未创建任何模板。';

  @override
  String get templatesEmptyStateSub => '创建您的第一份求职信或常用文本片段！';

  @override
  String get promptSubtitle =>
      '填写以下字段，即可生成专业的提示词，供您在 ChatGPT、Claude 或其他自选 AI 中使用。';
}
