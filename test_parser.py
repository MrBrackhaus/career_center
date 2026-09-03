import re

text = """Michael Kurz
FACHINFORMATIKER FÜR SYSTEMINTEGRATION
PERSÖNLICHE DATEN
E-MAIL ANSCHRIFT TELEFON
bewerbung.kurz@gmail.com Breyeller Straße 114
41334 Nettetal
0157-37879672
Stadtverwaltung Krefeld
Fachbereich E-Government und Informationstechnik
47792 Krefeld
Nettetal, den 16.08.2026
Bewerbung als Systemadministrator/in Netzwerk (m/w/d) – Kennziffer E-125/26/11
Sehr geehrte Damen und Herren,
"""

lines = [l.strip() for l in text.split('\n') if l.strip()]

foundTitle = None
foundCompany = None
foundDate = None

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
        if idx >= 0:
            if streetRegex.match(lines[idx]) or "straße" in lines[idx].lower() or "str." in lines[idx].lower() or "fachbereich" in lines[idx].lower() or "abteilung" in lines[idx].lower() or "z.hd." in lines[idx].lower():
                companyLine = idx - 1
                if companyLine >= 0 and (streetRegex.match(lines[companyLine]) or "straße" in lines[companyLine].lower()):
                    companyLine -= 1
        
        # Another heuristic: just go up until we hit the first non-street/non-dept line
        company_idx = recipientCityIndex - 1
        while company_idx > max(-1, recipientCityIndex - 4):
            l_low = lines[company_idx].lower()
            if streetRegex.match(lines[company_idx]) or "straße" in l_low or "str." in l_low or "fachbereich" in l_low or "abteilung" in l_low or "z.hd" in l_low or "herr" in l_low or "frau" in l_low or "postfach" in l_low:
                company_idx -= 1
            else:
                break
                
        if company_idx >= 0:
             foundCompany = lines[company_idx]
             
else:
    foundTitle = lines[0] if len(lines) > 0 else None
    foundCompany = lines[1] if len(lines) > 1 else None

print("Title:", foundTitle)
print("Company:", foundCompany)
print("Date:", foundDate)
