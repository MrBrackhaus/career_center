with open('lib/presentation/screens/applications/application_form_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i in range(675, 690):
    if i < len(lines):
        print(f"{i+1}: {lines[i].strip()}")
