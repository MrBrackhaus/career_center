path = r'lib\presentation\screens\applications\widgets\application_card.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("import '../../../../core/theme/app_colors.dart';", "")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Fixed application_card.dart!")
