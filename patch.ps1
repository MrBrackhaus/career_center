$content = Get-Content "lib\core\router\app_router.dart" -Raw
$import = "import '../../presentation/widgets/responsive_shell.dart';"
$content = $content -replace "import '../../presentation/screens/settings/settings_screen.dart';", "import '../../presentation/screens/settings/settings_screen.dart';`n$import"

$newBuilder = @"
      builder: (context, state, child) {
        return ResponsiveShell(child: child);
      },
"@
$content = $content -replace "(?s)      builder: \(context, state, child\) \{\r?\n.*?body: child,\r?\n    \};", $newBuilder

Set-Content "lib\core\router\app_router.dart" -Value $content -Encoding UTF8
