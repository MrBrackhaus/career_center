import urllib.request
import os

url = "https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2016/de/de_50k.txt"
path = "assets/dictionaries/de.txt"

print(f"Downloading {url}...")
req = urllib.request.urlopen(url)
content = req.read().decode('utf-8')

# The format is "word frequency" per line. We just need the word.
words = []
for line in content.split('\n'):
    if line.strip():
        parts = line.strip().split()
        if len(parts) >= 1:
            words.append(parts[0])

with open(path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(words))

print(f"Downloaded and extracted {len(words)} German words!")
