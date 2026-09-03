# -*- coding: utf-8 -*-
import os
import re

directory = 'lib/presentation/screens'
out_lines = []
for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
                matches = re.findall(r"(Text|TextSpan|Tooltip|label|hintText|title|content|SnackBar|showDialog)\s*[:(].*?['\"](.*?)['\"]", content)
                matches_const = re.findall(r"const\s+Text\s*\(\s*['\"]([^'\"]*?)['\"]", content)
                
                # Combine and filter
                all_matches = [m[1] for m in matches if m[1].strip() != ""] + [m for m in matches_const if m.strip() != ""]
                all_matches = list(set([m for m in all_matches if len(m) > 1 and not m.isdigit() and not m.isspace()]))
                
                if all_matches:
                    out_lines.append(f"--- {file} ---")
                    for m in all_matches:
                        out_lines.append("  " + m)

with open('strings.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(out_lines))
