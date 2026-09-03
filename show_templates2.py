with open('lib/presentation/screens/templates/templates_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i in range(570, min(610, len(lines))):
    print(f"{i+1}: {lines[i].strip()}")
