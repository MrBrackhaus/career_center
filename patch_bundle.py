import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/applications/application_form_state_bundle.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Add to class properties
text = text.replace('final TextEditingController addressController;\n  final Map<String, TextEditingController> customFieldControllers;', 
'final TextEditingController addressController;\n  final TextEditingController jobDescriptionTextController;\n  final Map<String, TextEditingController> customFieldControllers;')

# Add to constructor
text = text.replace('required this.addressController,\n    required this.customFieldControllers,',
'required this.addressController,\n    required this.jobDescriptionTextController,\n    required this.customFieldControllers,')

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Bundle patched!")
