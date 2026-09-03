path = 'mcp-server/index.js'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

import re

# Fix `text: Error: `
text = re.sub(r'text:\s*Error:\s*\}\]', 'text: `Error: ${err.message}` }]', text)

# Fix Notiz / Anschreiben erfolgreich...
text = re.sub(r'text:\s*Notiz / Anschreiben erfolgreich bei Bewerbung\s*hinterlegt\.\s*\}\]', 'text: "Notiz erfolgreich hinterlegt" }]', text)

# Fix Bewerbung bei inkl. ...
text = re.sub(r'text:\s*Bewerbung bei\s*inkl\. Jobbeschreibung hinzugef[^\s]+ \(ID:\s*\)\s*\}\]', 'text: `Bewerbung bei ${args.company} hinzugefügt` }]', text)

# Fix Bewerbung bei hinzugefügt...
text = re.sub(r'text:\s*Bewerbung bei\s*hinzugef[^\s]+\s*\(ID:\s*\)\s*\}\]', 'text: `Bewerbung hinzugefügt` }]', text)

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
