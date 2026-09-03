path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Let's clean up _TemplateEditorPageState's didChangeDependencies
# Find class _TemplateEditorPageState extends State<TemplateEditorPage>
# and remove didChangeDependencies inside it.
import re
pattern = r"class _TemplateEditorPageState extends State<TemplateEditorPage>.*?(@override\s*void didChangeDependencies\(\)\s*\{[^\}]+\}[^\}]+\}[^\}]+\})"

def remove_bad_did_change(m):
    return m.group(0).replace(m.group(1), "")

# Let's just do a manual substring replacement
start_idx = text.find("class _TemplateEditorPageState extends State<TemplateEditorPage>")
if start_idx != -1:
    bad_did_change_str = """  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTone) {
      _promptToneController.text = AppLocalizations.of(context)!.promptToneDefault;
      _initializedTone = true;
    }
  }
"""
    first_part = text[:start_idx]
    second_part = text[start_idx:].replace(bad_did_change_str, "")
    text = first_part + second_part

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed templates_screen.dart double replacement")
