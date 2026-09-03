$lines = Get-Content -Path "lib\presentation\screens\dashboard\dashboard_screen.dart"
$insertIdx = -1

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i] -match "BEWERBUNGEN PRO MONAT") {
        $insertIdx = $i
        break
    }
}

$funnelCode = @"
              Text('BEWERBUNGS-TRICHTER (FUNNEL)', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: FunnelChartWidget(
                    stages: [
                      FunnelStage('Versendet', total - open, Colors.blue),
                      FunnelStage('Interviews', interviews, Colors.purple),
                      FunnelStage('Zusagen', rejected > 0 ? (total - open - rejected - interviews) : 0, Colors.green), // Quick approximation. Wait, better count exactly from applications!
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
"@

# wait, I should compute the exact values for the funnel from the applications list!
