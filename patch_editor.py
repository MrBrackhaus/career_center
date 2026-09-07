import codecs

path = 's:/Projekte/career_center/lib/presentation/screens/editor/template_editor_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

text = text.replace("final Template? template;\n  \n  const TemplateEditorScreen({super.key, this.template});", 
'''final Template? template;
  final String initialType;
  
  const TemplateEditorScreen({super.key, this.template, this.initialType = 'anschreiben'});''')

text = text.replace("type: widget.template?.type ?? 'anschreiben',", "type: widget.template?.type ?? widget.initialType,")

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
