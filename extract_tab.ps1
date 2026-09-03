$lines = Get-Content -Path "lib\presentation\screens\applications\application_form_screen.dart"

$startIdx = -1
$endIdx = -1

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "Widget _buildSplitView") { $startIdx = $i }
    if ($lines[$i] -match "=== E-MAILS ===") { $endIdx = $i }
}

Write-Host "Start: $startIdx, End: $endIdx"
