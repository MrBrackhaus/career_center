path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("final _promptToneController = TextEditingController(text: AppLocalizations.of(context)!.promptToneDefault);", "final _promptToneController = TextEditingController();\nbool _initializedTone = false;")

did_change = """
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTone) {
      _promptToneController.text = AppLocalizations.of(context)!.promptToneDefault;
      _initializedTone = true;
    }
  }
"""

text = text.replace("void initState() {\n    super.initState();", did_change + "\n  @override\n  void initState() {\n    super.initState();")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed templates_screen.dart")
