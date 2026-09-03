with open('lib/presentation/screens/templates/templates_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if "KI Prompt Generator" in line or "Felder aus" in line:
        start = max(0, i - 2)
        end = min(len(lines), i + 4)
        print(f"Match found at line {i+1}:")
        for j in range(start, end):
            print(f"{j+1}: {lines[j].strip()}")
