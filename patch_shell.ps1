$content = Get-Content "lib\presentation\widgets\responsive_shell.dart" -Raw
$content = $content -replace "(?s)\s*_NavItem\(\r?\n\s*label: 'Wochenbericht',.*?path: '/weekly',\r?\n\s*\),", ""
Set-Content "lib\presentation\widgets\responsive_shell.dart" -Value $content -Encoding UTF8
