import os
import time
import random
import urllib.request
import urllib.parse
from playwright.sync_api import sync_playwright

SEARCH_TERMS = [
    "Softwareentwickler", "Marketing", "Vertrieb", "Pflege", "Ingenieur", 
    "Buchhaltung", "Projektmanager", "Logistik", "Handwerk", "Design", 
    "Verkauf", "Lehrer", "Koch", "Medizin", "Kaufmann", "Mechatroniker",
    "Ausbildung", "Praktikum", "Werkstudent", "Initiativbewerbung",
    "Aushilfe", "Minijob", "Teilzeit", "Vollzeit", "Führungskraft",
    "IT", "Consulting", "Bankwesen", "Immobilien", "Handel"
]

def search_ddg_pdfs(page, term):
    pdf_urls = set()
    query = f'filetype:pdf "Bewerbungsschreiben" OR "Anschreiben" {term}'
    url = f"https://duckduckgo.com/?q={urllib.parse.quote(query)}"
    try:
        page.goto(url, wait_until="networkidle", timeout=15000)
        links = page.locator("a[href]").all()
        for link in links:
            href = link.get_attribute("href")
            if href and "uddg=" in href:
                actual_url = urllib.parse.unquote(href.split('uddg=')[1].split('&')[0])
                if actual_url.lower().endswith('.pdf'):
                    pdf_urls.add(actual_url)
    except:
        pass
    return list(pdf_urls)

def download_pdf(url, out_dir):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    filename = f"anschreiben_search_{random.randint(100000, 999999)}.pdf"
    out_path = os.path.join(out_dir, filename)
    if os.path.exists(out_path):
        return
    try:
        with urllib.request.urlopen(req, timeout=10) as response, open(out_path, 'wb') as out_file:
            out_file.write(response.read())
        print(f"Downloaded cover letter: {filename}")
    except:
        pass

def main():
    start_time = time.time()
    max_duration = 27 * 60
    out_dir = r"S:\Projekte\JobTracker\training_data"
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1920, "height": 1080})
        page = context.new_page()
        
        for term in SEARCH_TERMS:
            if time.time() - start_time > max_duration:
                break
            
            print(f"Scraping cover letters for: {term}")
            urls = search_ddg_pdfs(page, term)
            for url in urls:
                if time.time() - start_time > max_duration:
                    break
                download_pdf(url, out_dir)
                
            time.sleep(random.uniform(2, 5))
            
        browser.close()
        print("Continuous cover letter scraping finished.")

if __name__ == "__main__":
    main()
