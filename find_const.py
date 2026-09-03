with open('lib/presentation/screens/applications/widgets/documents_widget.dart', 'r', encoding='utf-8') as f:
    for i, line in enumerate(f):
        if "const " in line:
            print(f"{i+1}: {line.strip()}")
