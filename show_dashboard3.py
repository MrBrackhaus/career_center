with open('lib/presentation/screens/dashboard/dashboard_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for j in range(345, 380):
    if j < len(lines):
        print(f"{j+1}: {lines[j].strip()}")
