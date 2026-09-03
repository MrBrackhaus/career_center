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
Georg-
Glock-
Straße 4
40474 Düsseldorf
Nettetal, den 30.08.2026
Bewerbung als IT
-
Supporter (w/m/d)
Sehr geehrter Herr Kern,"""

lines = [l.strip() for l in text.split('\n') if l.strip()]

bestRecipientCityIndex = -1
plzCityRegex = re.compile(r'^\d{5}\s+[A-ZÄÖÜ]')

for i in range(len(lines)):
    if plzCityRegex.match(lines[i]):
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
    
    # We need to collect all lines that are part of the street.
    streetParts = []
    while companyIdx >= 0:
        lLow = lines[companyIdx].lower()
        # Does this line look like part of an address?
        if streetRegex.match(lines[companyIdx]) or "straße" in lLow or "str." in lLow or "postfach" in lLow or lines[companyIdx].endswith('-'):
            streetParts.insert(0, lines[companyIdx])
            companyIdx -= 1
        else:
            # Maybe it's a part of the street that doesn't have the keyword yet, but ends with '-'
            if companyIdx >= 0 and lines[companyIdx].endswith('-'):
                streetParts.insert(0, lines[companyIdx])
                companyIdx -= 1
            else:
                break
                
    if not streetParts:
        foundAddress = lines[bestRecipientCityIndex]
    else:
        foundAddress = " ".join(streetParts) + ", " + lines[bestRecipientCityIndex]
        # Clean up hyphens with spaces: "Georg- Glock- Straße 4" -> "Georg-Glock-Straße 4"
        foundAddress = foundAddress.replace("- ", "-")

    # Find company name
    while companyIdx > max(-1, bestRecipientCityIndex - 8):
        lLow = lines[companyIdx].lower()
        if "herr" in lLow or "frau" in lLow or "z.hd" in lLow or "abteilung" in lLow or "fachbereich" in lLow or "personal" in lLow or "human" in lLow or "resources" in lLow or len(lines[companyIdx]) <= 2:
            companyIdx -= 1
        else:
            break
            
    if companyIdx >= 0 and '@' not in lines[companyIdx]:
        foundCompany = lines[companyIdx]

print(f"Company: {foundCompany}")
print(f"Address: {foundAddress}")

titleParts = []
for i, l in enumerate(lines):
    lower = l.lower()
    if lower.startswith('bewerbung als') or lower.startswith('bewerbung auf'):
        titleParts.append(l)
        # Collect next few lines if they seem to belong to the title
        for j in range(i+1, min(i+4, len(lines))):
            if lines[j].startswith('Sehr geehrte') or plzCityRegex.match(lines[j]):
                break
            # Ignore empty-ish lines but maybe it's just '-'
            titleParts.append(lines[j])
        break

title = " ".join(titleParts).replace("- ", "-")
print(f"Title: {title}")
