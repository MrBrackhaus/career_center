path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

bad = """  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedTone) {
      _promptToneController.text = AppLocalizations.of(context)!.promptToneDefault;
      _initializedTone = true;
    }
  }"""

# Find the LAST occurrence of `bad` and remove it
idx = text.rfind(bad)
if idx != -1:
    text = text[:idx] + text[idx + len(bad):]

# Also remove stray empty @overrides
text = text.replace("@override\n\n  @override\n", "  @override\n")

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
print("Removed LAST occurrence of bad code!")
