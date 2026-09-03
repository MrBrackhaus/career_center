import os
import urllib.request
import concurrent.futures

urls = [
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Schuelerpraktikum-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Schuelerpraktikum-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Praktikum-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Praktikum-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Ausbildung-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Ausbildung-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Studium-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Studium-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Werkstudent-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Werkstudent-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Stipendium-Motivationsschreiben.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Stipendium-Motivationsschreiben.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-FSJ.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-FSJ.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-ohne-Berufserfahrung.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-ohne-Berufserfahrung.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Berufseinsteiger-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Berufseinsteiger-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Trainee.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Trainee.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Berufserfahrung-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Berufserfahrung-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Fuehrungskraft-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Fuehrungskraft-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-50plus.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-50plus.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlag-Minijob.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlag-Minijob.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Aushilfe.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Aushilfe.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-interne-Bewerbung-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-interne-Bewerbung-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-Initiativbewerbung-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-Initiativbewerbung-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2026/09/Bewerbungsschreiben-modern-Muster-Word.docx",
  "https://karrierebibel.de/wp-content/uploads/2021/01/Bewerbungsschreiben-modern-Muster-PDF.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Bankkaufmann.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Bankkaufmann.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Einzelhandelskauffrau.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Einzelhandelskauffrau.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Industriekaufmann.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Industriekaufmann.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Kauffrau-Bueromanagement.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Kauffrau-Bueromanagement.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Immobilienkaufmann.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Immobilienkaufmann.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Verkaeuferin.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Verkaeuferin.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Erzieherin.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Erzieherin.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Lehrer.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Lehrer.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Pflegefachkraft.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Pflegefachkraft.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Physiotherapeut.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Physiotherapeut.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Sozialarbeiter.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Sozialarbeiter.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Sozialpaedagoge.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Sozialpaedagoge.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Volage-Kfz-Mechatroniker.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Volage-Kfz-Mechatroniker.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Kommissionierer.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Kommissionierer.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Hotelfachkraft.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Hotelfachkraft.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Kosmetikerin.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Kosmetikerin.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-oeffentlicher-Dienst.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-oeffentlicher-Dienst.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Polizei.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Polizei.pdf",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Fluglotse.docx",
  "https://karrierebibel.de/wp-content/uploads/2030/08/Bewerbungsschreiben-Vorlage-Fluglotse.pdf"
]

out_dir = r"S:\Projekte\JobTracker\training_data"
os.makedirs(out_dir, exist_ok=True)

def download_url(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    filename = url.split('/')[-1]
    out_path = os.path.join(out_dir, filename)
    if os.path.exists(out_path):
        return f"Already exists: {filename}"
    try:
        with urllib.request.urlopen(req) as response, open(out_path, 'wb') as out_file:
            data = response.read()
            out_file.write(data)
        return f"Downloaded: {filename}"
    except Exception as e:
        return f"Error downloading {filename}: {e}"

if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        results = list(executor.map(download_url, urls))
    
    for r in results:
        print(r)
    print(f"Total processed: {len(results)}")
