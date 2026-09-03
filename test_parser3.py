import re

text = """Michael Kurz
bewerbung.kurz@gmail.com
Breyeller Straße 114
41334 Nettetal
Nettetal, den 16.08.2026
Bewerbung als Systemadministrator (m/w/d) für Windows
Information und Technik Nordrhein-Westfalen (IT.NRW)
Zentralbereich 14 – Personal
Mauerstraße 51
40476 Düsseldorf
"""

lines = [l.strip() for l in text.split('\n') if l.strip()]

isCoverLetter = True

bestRecipientCityIndex = -1
plzCityRegex = re.compile(r'^\d{5}\s+[A-ZÄÖÜ]')

for i in range(len(lines)):
    if plzCityRegex.match(lines[i]):
        isSender = False
        for j in range(1, 6):
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
    if companyIdx >= 0 and (streetRegex.match(lines[companyIdx]) or "straße" in lines[companyIdx].lower() or "str." in lines[companyIdx].lower() or "postfach" in lines[companyIdx].lower()):
        foundAddress = f"{lines[companyIdx]}, {lines[bestRecipientCityIndex]}"
    else:
        foundAddress = lines[bestRecipientCityIndex]

    # Find company name
    while companyIdx > max(-1, bestRecipientCityIndex - 5):
        lLow = lines[companyIdx].lower()
        if streetRegex.match(lines[companyIdx]) or "straße" in lLow or "str." in lLow or "fachbereich" in lLow or "abteilung" in lLow or "z.hd" in lLow or "herr" in lLow or "frau" in lLow or "postfach" in lLow or "zentralbereich" in lLow or "personal" in lLow:
            companyIdx -= 1
        else:
            break
            
    if companyIdx >= 0 and '@' not in lines[companyIdx]:
        foundCompany = lines[companyIdx]

print(f"Company: {foundCompany}")
print(f"Address: {foundAddress}")
