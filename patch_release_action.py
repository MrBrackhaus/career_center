import codecs

with codecs.open('s:/Projekte/career_center/.github/workflows/release.yml', 'r', 'utf-8') as f:
    text = f.read()

target = """      - name: Compress Release
        run: |
          Copy-Item -Path browser_extension -Destination build\windows\x64\runner\Release\browser_extension -Recurse
          Compress-Archive -Path build\windows\x64\runner\Release\* -DestinationPath CareerCenter-Release-Windows.zip"""

replacement = """      - name: Compress Release
        run: |
          Copy-Item -Path browser_extension -Destination build\windows\x64\runner\Release\browser_extension -Recurse
          if (Test-Path mcp-server) { Copy-Item -Path mcp-server -Destination build\windows\x64\runner\Release\mcp-server -Recurse }
          Compress-Archive -Path build\windows\x64\runner\Release\* -DestinationPath CareerCenter-Release-Windows.zip"""

text = text.replace(target, replacement)

with codecs.open('s:/Projekte/career_center/.github/workflows/release.yml', 'w', 'utf-8') as f:
    f.write(text)

print("Release action patched to include mcp-server")
