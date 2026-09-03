path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

# Replace drift.TemplatesCompanion with TemplatesCompanion
text = text.replace('drift.TemplatesCompanion', 'TemplatesCompanion')

# Replace QuillToolbar.simple(...) with QuillSimpleToolbar(controller: _controller)
text = text.replace('''quill.QuillToolbar.simple(
                                configurations: quill.QuillSimpleToolbarConfigurations(
                                  controller: _controller,
                                ),
                              )''', '''quill.QuillSimpleToolbar(
                                controller: _controller,
                              )''')

# Replace QuillEditor.basic(...) with QuillEditor.basic(controller: _controller)
text = text.replace('''quill.QuillEditor.basic(
                                    configurations: quill.QuillEditorConfigurations(
                                      controller: _controller,
                                    ),
                                  )''', '''quill.QuillEditor.basic(
                                    controller: _controller,
                                  )''')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed configurations and templatesCompanion!")
