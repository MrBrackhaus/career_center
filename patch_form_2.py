import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/application_form_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = """addressController: _addressController,
      customFieldControllers: _customFieldControllers,"""
replacement = """addressController: _addressController,
      jobDescriptionTextController: _jobDescriptionTextController,
      customFieldControllers: _customFieldControllers,"""

if target in text:
    text = text.replace(target, replacement)
else:
    print("TARGET NOT FOUND IN FORM!")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Form patched correctly!")
