import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/application_form_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Add to bundle instantiation
target = '''addressController: _addressController,
      customFieldControllers: _customFieldControllers,'''
replacement = '''addressController: _addressController,
      jobDescriptionTextController: _jobDescriptionTextController,
      customFieldControllers: _customFieldControllers,'''

text = text.replace(target, replacement)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Form patched!")
