import re
import json

with open("strings.txt", "r", encoding="utf-8") as f:
    lines = [line.strip() for line in f if line.strip() and not line.startswith("---")]

unique_strings = set(lines)

# Remove ones that look like variables or already translated (if any)
filtered = []
for s in unique_strings:
    if "$" in s or "{" in s or "AppLocalizations" in s or "loc." in s:
        continue
    filtered.append(s)

out = {}
for i, s in enumerate(filtered):
    out[f"autoKey{i}"] = s

with open("to_translate.json", "w", encoding="utf-8") as f:
    json.dump(out, f, ensure_ascii=False, indent=2)
