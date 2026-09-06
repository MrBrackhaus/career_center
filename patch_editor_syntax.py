import codecs
import re

path = 's:/Projekte/career_center/lib/presentation/screens/editor/application_editor_screen.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Fix the broken variable declaration
text = text.replace("bool ref.watch(aiCorrectionProvider).isCorrecting = false;", "")

# In the build method, we need to read the state
# It used to say:
# if (_isCorrecting) CircularProgressIndicator()
# My replace made it:
# if (ref.watch(aiCorrectionProvider).isCorrecting) CircularProgressIndicator()
# This is valid inside `build()` because `ref` is available in ConsumerState!
# So we only need to remove the broken variable declaration.

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)

print("Syntax fixed")
