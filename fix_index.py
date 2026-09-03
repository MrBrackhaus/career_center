path = 'mcp-server/index.js'
with open(path, 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('name: "update_status",{', '')
text = text.replace('if (name === "update_status") {    if (name === "update_status") {', 'if (name === "update_status") {')

with open(path, 'w', encoding='utf-8') as f:
    f.write(text)
