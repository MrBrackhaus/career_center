with open('lib/presentation/screens/applications/widgets/documents_widget.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if "Future<void> _uploadDoc" in line:
        for j in range(i, min(i+20, len(lines))):
            print(f"{j+1}: {lines[j].strip()}")
        break
