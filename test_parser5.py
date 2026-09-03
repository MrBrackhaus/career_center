import re

text = """Michael Kurz
FACHINFORMATIKER FÜR SYSTEMINTEGRATION
PERSÖNLICHE DATEN
E-MAIL ANSCHRIFT TELEFON
bewerbung.kurz@gmail.com Breyeller Straße 114
41334 Nettetal
0157-37879672
HEUKING
Herr Stephan Kern - Human Resources
Georg-Glock-Straße 4
40474 Düsseldorf
Nettetal, den 30.08.2026
Bewerbung als IT-Supporter (w/m/d)"""

lines = [l.strip() for l in text.split('\n') if l.strip()]

bestRecipientCityIndex = -1
plzCityRegex = re.compile(r'^\d{5}\s+[A-ZÄÖÜ]')

for i in range(len(lines)):
    if plzCityRegex.match(lines[i]):
        # Just use j=2
        isSender = False
        for j in range(1, 3):
            if i - j >= 0:
                l_above = lines[i-j].lower()
                if '@' in l_above or re.search(r'(tel|mobil|01[5-7]|\+49)', l_above):
                    isSender = True
                    break
        if not isSender:
            bestRecipientCityIndex = i

foundCompany = None
foundAddress = None
if bestRecipientCityIndex != -1:
    streetRegex = re.compile(r'[A-ZÄÖÜ][a-zA-ZäöüÄÖÜß\.\-\s]+\d{1,4}[a-zA-Z]?')
    companyIdx = bestRecipientCityIndex - 1
    
    # Extract address
    if companyIdx >= 0:
        lLow = lines[companyIdx].lower()
        if streetRegex.match(lines[companyIdx]) or "straße" in lLow or "str." in lLow or "postfach" in lLow:
            foundAddress = f"{lines[companyIdx]}, {lines[bestRecipientCityIndex]}"
        else:
            foundAddress = lines[bestRecipientCityIndex]

    # Find company name
    while companyIdx > max(-1, bestRecipientCityIndex - 5):
        lLow = lines[companyIdx].lower()
        if streetRegex.match(lines[companyIdx]) or "straße" in lLow or "str." in lLow or "fachbereich" in lLow or "abteilung" in lLow or "z.hd" in lLow or "herr" in lLow or "frau" in lLow or "postfach" in lLow or "zentralbereich" in lLow or "personal" in lLow or "resources" in lLow:
            companyIdx -= 1
        else:
            break
            
    if companyIdx >= 0 and '@' not in lines[companyIdx]:
        foundCompany = lines[companyIdx]

print(f"Company: {foundCompany}")
print(f"Address: {foundAddress}")

urlRegex = re.compile(r'(https?://)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z]{2,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)')
foundUrl = None
for match in urlRegex.finditer(text):
    url = match.group(0)
    if url and '@' not in url:
        url = re.sub(r'[)\.]+$', '', url)
        foundUrl = url
        break
print(f"URL: {foundUrl}")

title = None
for l in lines:
    lower = l.lower()
    if lower.startswith('bewerbung als') or lower.startswith('bewerbung auf'):
        title = l
        break
print(f"Title: {title}")
