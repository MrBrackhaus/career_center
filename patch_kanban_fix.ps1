$content = Get-Content "lib\presentation\screens\applications\applications_screen.dart" -Raw
$content = $content -replace "app\.location", "app.address"
$content = $content -replace "if \(app\.remotePercentage \!\= null \&\& app\.remotePercentage\! \> 0\)\r?\n\s*_buildTag\(\r?\n\s*Icons\.home_work,\r?\n\s*'\`\$\{app\.remotePercentage\}\% Remote',\r?\n\s*Colors\.teal,\r?\n\s*\),", "if (app.commuteCar != null && app.commuteCar! > 0)`n                    _buildTag(`n                      Icons.directions_car,`n                      '`${app.commuteCar} Min.',`n                      Colors.teal,`n                    ),"
Set-Content "lib\presentation\screens\applications\applications_screen.dart" -Value $content -Encoding UTF8
