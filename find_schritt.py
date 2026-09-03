with open('lib/presentation/screens/dashboard/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if "Schritt" in line or "perfekten" in line:
        print(f"{i+1}: {line.strip()}")
