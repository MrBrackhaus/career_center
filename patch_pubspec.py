with open("pubspec.yaml", "r", encoding="utf-8") as f:
    text = f.read()

# Remove the bad assets appended at the end
import re
text = re.sub(r"\n\s*assets:\n\s*- assets/images/", "", text)

# Insert correctly under flutter:
text = text.replace("uses-material-design: true", "uses-material-design: true\n  assets:\n    - assets/images/")

with open("pubspec.yaml", "w", encoding="utf-8") as f:
    f.write(text)
