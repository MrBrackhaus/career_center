$content = Get-Content "lib\presentation\screens\dashboard\dashboard_screen.dart" -Raw
$content = $content -replace "ÃœBERBLICK", "ÜBERBLICK"
$content = $content -replace "ABSAGEGRÃœNDE", "ABSAGEGRÜNDE"
Set-Content "lib\presentation\screens\dashboard\dashboard_screen.dart" -Value $content -Encoding UTF8
