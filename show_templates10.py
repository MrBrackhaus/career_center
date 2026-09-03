with open('lib/presentation/screens/templates/templates_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for j in range(240, 280):
    if j < len(lines):
        line = lines[j].replace('\U0001f916', '[ROBOT]')
        print(f"{j+1}: {line.strip()}")
