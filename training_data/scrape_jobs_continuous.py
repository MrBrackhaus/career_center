import os
import time
import random
from playwright.sync_api import sync_playwright

SEARCH_TERMS = [
    "Softwareentwickler", "Marketing", "Vertrieb", "Pflege", "Ingenieur", 
    "Buchhaltung", "Projektmanager", "Logistik", "Handwerk", "Design", 
    "Verkauf", "Lehrer", "Koch", "Medizin", "Kaufmann", "Mechatroniker", 
    "Architekt", "Personalwesen", "Büro", "Consultant", "Manager", "Analyst",
    "Fahrer", "Techniker", "Chemiker", "Biologe", "Jurist", "Anwalt",
    "Apotheker", "Bauingenieur", "Controller", "Dolmetscher", "Erzieher",
    "Friseur", "Grafiker", "Hausmeister", "Informatiker", "Journalist",
    "Kellner", "Lektor", "Maler", "Notar", "Optiker", "Physiotherapeut"
]

def get_urls_jobware(page, term, max_jobs=20):
    job_urls = set()
    current_page = 1
    while len(job_urls) < max_jobs and current_page <= 3:
        try:
            page.goto(f"https://www.jobware.de/jobsuche?q={term}&p={current_page}", wait_until="networkidle", timeout=15000)
            links = page.locator("a[href*='/job/']").all()
            for link in links:
                href = link.get_attribute("href")
                if href:
                    if not href.startswith("http"): href = "https://www.jobware.de" + href
                    job_urls.add(href)
            current_page += 1
        except: break
    return list(job_urls)[:max_jobs]

def save_to_pdf(page, url, prefix, out_dir):
    try:
        page.goto(url, wait_until="networkidle", timeout=20000)
        page.evaluate('''
            const selectors = ['.cookie-banner', '.banner', 'div[role="dialog"]', 'div[id^="usercentrics"]', 'div[id^="sp_message_container"]'];
            selectors.forEach(sel => { try { document.querySelectorAll(sel).forEach(e => e.remove()); } catch(e) {} });
            document.body.style.overflow = 'auto';
        ''')
        filename = f"{prefix}_{random.randint(100000, 999999)}.pdf"
        pdf_path = os.path.join(out_dir, filename)
        page.pdf(path=pdf_path, format="A4", print_background=True)
        print(f"Saved job: {filename}")
    except:
        pass

def main():
    start_time = time.time()
    max_duration = 27 * 60 # 27 minutes
    out_dir = r"S:\Projekte\JobTracker\training_data\jobs_pdf"
    os.makedirs(out_dir, exist_ok=True)
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1920, "height": 1080})
        page = context.new_page()
        
        for term in SEARCH_TERMS:
            if time.time() - start_time > max_duration:
                break
                
            print(f"Scraping jobs for: {term}")
            urls_jw = get_urls_jobware(page, term, 15)
            for url in urls_jw:
                if time.time() - start_time > max_duration:
                    break
                save_to_pdf(page, url, "jobware", out_dir)
                
        browser.close()
        print("Continuous job scraping finished.")

if __name__ == "__main__":
    main()
