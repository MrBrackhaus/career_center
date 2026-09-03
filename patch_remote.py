import os

path = 'lib/presentation/screens/applications/applications_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re

# Find and replace the remotePercentage block
pattern = re.compile(r'if \(app\.remotePercentage != null && app\.remotePercentage! > 0\)[\s\S]*?\),')
replacement = """if (app.commuteCar != null && app.commuteCar! > 0)
                    _buildTag(
                      Icons.directions_car,
                      '${app.commuteCar} Min.',
                      Colors.teal,
                    ),"""

if pattern.search(text):
    text = pattern.sub(replacement, text)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)
    print("Replaced remotePercentage!")
else:
    print("Not found!")

