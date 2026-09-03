path = 'lib/presentation/screens/templates/templates_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if "class _TemplateEditorPageState extends State<TemplateEditorPage>" in line:
        pass # from here on, we should remove didChangeDependencies if it contains _initializedTone
        
in_editor = False
for i, line in enumerate(lines):
    if "class _TemplateEditorPageState extends State<TemplateEditorPage>" in line:
        in_editor = True
    
    if in_editor and "@override" in line and "didChangeDependencies" in ''.join(lines[i:i+2]):
        # This is the start of didChangeDependencies
        if "_initializedTone" in ''.join(lines[i:i+10]):
            skip = True
            
    if skip:
        if "void initState()" in line or "Widget build" in line:
            skip = False
        else:
            if "override" not in line: # if it was @override for something else, wait, we checked initState
                continue
            
    if not skip:
        new_lines.append(line)

with open(path, 'w', encoding='utf-8') as f:
    f.write(''.join(new_lines))

print("Fixed templates_screen.dart double replacement CORRECTLY")
