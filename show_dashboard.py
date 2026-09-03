with open('lib/presentation/screens/dashboard/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if "Wochenziel" in line:
        for j in range(max(0, i-20), min(i+40, len(lines))):
            print(f"{j+1}: {lines[j].strip()}")
        break
