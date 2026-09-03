path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("loc.appTitle", "loc.applicationsTitle")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Fixed appTitle -> applicationsTitle!")
