import os
from fpdf import FPDF

anschreiben_text = """
Bewerbung als Marketing Manager

Sehr geehrte Damen und Herren,

mit großem Interesse habe ich Ihre Stellenanzeige gelesen. 
Durch meine langjährige Erfahrung im Bereich Online Marketing bin ich 
davon überzeugt, dass ich einen wertvollen Beitrag zu Ihrem Unternehmen 
leisten kann.

In den letzten 5 Jahren habe ich erfolgreich Kampagnen für diverse
Kunden konzipiert und umgesetzt. Ich bringe tiefgehende Kenntnisse in 
SEO, SEA und Social Media Management mit.

Ich freue mich auf ein persönliches Gespräch.

Mit freundlichen Grüßen,
Max Mustermann
"""

stellengesuch_text = """
Erfahrener Projektmanager sucht neue Herausforderung

Profil:
- 10 Jahre Berufserfahrung im agilen Projektmanagement (Scrum, Kanban)
- Zertifizierter Scrum Master
- Branchenerfahrung: IT, E-Commerce, Automotive

Kenntnisse:
- Jira, Confluence, Trello, MS Project
- Fließend Deutsch und Englisch
- Starke Kommunikations- und Führungsfähigkeiten

Gesucht wird:
Eine Position als Senior IT Projektmanager im Raum München oder 100% Remote.
"""

def create_pdf(filename, text, title):
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    pdf.cell(200, 10, txt=title, ln=True, align='C')
    pdf.ln(10)
    for line in text.split('\n'):
        # Fix encoding for special characters
        line = line.encode('latin-1', 'replace').decode('latin-1')
        pdf.cell(200, 10, txt=line, ln=True)
    pdf.output(filename)

create_pdf("s:/Projekte/JobTracker/training_data/Anschreiben_6.pdf", anschreiben_text, "Bewerbungsanschreiben")
create_pdf("s:/Projekte/JobTracker/training_data/Stellengesuch_6.pdf", stellengesuch_text, "Stellengesuch")
print("PDFs generated successfully.")
