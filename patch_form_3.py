import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/application_form_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace("addressController: _addressController,", "addressController: _addressController,\n      jobDescriptionTextController: _jobDescriptionTextController,")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Form patched really correctly!")
