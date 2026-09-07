import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/application_form_state_bundle.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Add jobDescriptionTextController
if "final TextEditingController jobDescriptionTextController;" not in text:
    text = text.replace("final TextEditingController addressController;", "final TextEditingController addressController;\n  final TextEditingController jobDescriptionTextController;")
    text = text.replace("required this.addressController,", "required this.addressController,\n    required this.jobDescriptionTextController,")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Bundle patched successfully!")
