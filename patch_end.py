import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/templates/templates_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

if text.endswith('}\n}\n'):
    text = text[:-3] + '\n'
    with codecs.open(path, 'w', 'utf-8') as f:
        f.write(text)
    print("Fixed end brace")
