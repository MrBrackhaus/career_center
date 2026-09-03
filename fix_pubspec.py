path = 'pubspec.yaml'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('version: 1.0.0+1', 'version: 0.6.0+1')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated pubspec.yaml")
