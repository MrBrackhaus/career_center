import re

text = """Michael Kurz
FACHINFORMATIKER FÜR SYSTEMINTEGRATION
bewerbung.kurz@gmail.com
Breyeller Straße 114
41334 Nettetal
0157-37879672
Information und Technik Nordrhein-Westfalen (IT.NRW)
Zentralbereich 14 – Personal
Mauerstraße 51
40476 Düsseldorf
Nettetal, den 30.08.2026
Bewerbung als Systemadministrator (m/w/d) für Windows
Sehr geehrte Damen und Herren,
"""

lines = [l.strip() for l in text.split('\n') if l.strip()]

foundTitle = None
foundCompany = None
foundDate = None
foundUrl = None
foundAddress = None
foundPhone = None
foundEmail = None

dateMatch = re.search(r'(\d{1,2})\.(\d{1,2})\.(\d{4})', text)
if dateMatch:
    foundDate = f"{dateMatch.group(3)}-{dateMatch.group(2)}-{dateMatch.group(1)}"

isCoverLetter = False
subjectIndex = -1
for i, l in enumerate(lines):
    lower = l.lower()
    if lower.startswith("bewerbung als") or lower.startswith("bewerbung auf") or lower.startswith("bewerbung um") or lower.startswith("bewerbung für") or lower.startswith("bewerbung:") or lower.startswith("bewerbung -") or lower == "bewerbung":
        foundTitle = l
        subjectIndex = i
        isCoverLetter = True
        break
    if "sehr geehrte" in lower:
        isCoverLetter = True

if isCoverLetter:
    plzCityRegex = re.compile(r'^\d{5}\s+[A-ZÄÖÜ]')
    
    recipientCityIndex = -1
    searchEnd = subjectIndex if subjectIndex != -1 else len(lines)
    for i in range(searchEnd - 1, -1, -1):
        if plzCityRegex.match(lines[i]):
            recipientCityIndex = i
            break
            
    if recipientCityIndex != -1:
        streetRegex = re.compile(r'[A-ZÄÖÜ][a-zA-ZäöüÄÖÜß\.\-\s]+\d{1,4}[a-zA-Z]?')
        idx = recipientCityIndex - 1
        
        companyLine = idx
        while companyLine > max(-1, recipientCityIndex - 4):
            l_low = lines[companyLine].lower()
            if streetRegex.match(lines[companyLine]) or "straße" in l_low or "str." in l_low or "fachbereich" in l_low or "abteilung" in l_low or "z.hd" in l_low or "herr" in l_low or "frau" in l_low or "postfach" in l_low or "zentralbereich" in l_low or "personal" in l_low:
                companyLine -= 1
            else:
                break
                
        if companyLine >= 0:
             foundCompany = lines[companyLine]
             
else:
    foundTitle = lines[0] if len(lines) > 0 else None
    foundCompany = lines[1] if len(lines) > 1 else None

emailMatch = re.search(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', text)
if emailMatch: foundEmail = emailMatch.group(0)

phoneMatch = re.search(r'(\+49|0)[0-9\s/.-]{7,20}', text)
if phoneMatch: foundPhone = phoneMatch.group(0).strip()

urlRegex = re.compile(r'(https?://)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{2,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)')
for match in urlRegex.finditer(text):
    url = match.group(0)
    if url and '@' not in url:
        foundUrl = url
        break

addressRegex = re.compile(r'([A-ZÄÖÜ][a-zA-ZäöüÄÖÜß\.\-\s]+\d{1,4}[a-zA-Z]?)[,\s\n\r]+(\d{5})\s+([A-ZÄÖÜ][a-zA-ZäöüÄÖÜß\-]+)')
addressMatch = addressRegex.search(text)
if addressMatch:
    street = addressMatch.group(1).strip()
    plz = addressMatch.group(2).strip()
    city = addressMatch.group(3).strip()
    street = street.split('\n')[-1].strip()
    foundAddress = f"{street}, {plz} {city}"

print(f"Title: {foundTitle}")
print(f"Company: {foundCompany}")
print(f"Date: {foundDate}")
print(f"URL: {foundUrl}")
print(f"Email: {foundEmail}")
print(f"Phone: {foundPhone}")
print(f"Address: {foundAddress}")

