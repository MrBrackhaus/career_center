$content = Get-Content "pubspec.yaml" -Raw
$content = $content + "`n  assets:`n    - assets/images/"
Set-Content "pubspec.yaml" -Value $content -Encoding UTF8
