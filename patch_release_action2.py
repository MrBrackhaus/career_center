import codecs

with codecs.open('s:/Projekte/career_center/.github/workflows/release.yml', 'r', 'utf-8') as f:
    text = f.read()

target = """          if (Test-Path mcp-server) { Copy-Item -Path mcp-server -Destination build\windows\x64\runner\Release\mcp-server -Recurse }"""

replacement = """          if (Test-Path mcp-server) { 
            Copy-Item -Path mcp-server -Destination build\windows\x64\runner\Release\mcp-server -Recurse 
            if (Test-Path build\windows\x64\runner\Release\mcp-server\node_modules) { Remove-Item -Path build\windows\x64\runner\Release\mcp-server\node_modules -Recurse -Force }
          }"""

text = text.replace(target, replacement)

with codecs.open('s:/Projekte/career_center/.github/workflows/release.yml', 'w', 'utf-8') as f:
    f.write(text)

print("Release action patched to exclude node_modules")
