$content = Get-Content "lib\core\router\app_router.dart" -Raw
$content = $content -replace "(?s)import '../../presentation/screens/reports/weekly_report_screen.dart';\r?\n", ""
$content = $content -replace "(?s)        GoRoute\(\r?\n          path: '/weekly',\r?\n          builder: \(context, state\) => const WeeklyReportScreen\(\),\r?\n        \),\r?\n", ""
Set-Content "lib\core\router\app_router.dart" -Value $content -Encoding UTF8
