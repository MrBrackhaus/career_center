import os
import time
from playwright.sync_api import sync_playwright

def get_urls_jobware(page, max_jobs=70):
    job_urls = set()
    current_page = 1
    while len(job_urls) < max_jobs:
        page.goto(f"https://www.jobware.de/jobsuche?q=&p={current_page}", wait_until="networkidle")
        links = page.locator("a[href*='/job/']").all()
        start_len = len(job_urls)
        for link in links:
            href = link.get_attribute("href")
            if href:
                if not href.startswith("http"):
                    href = "https://www.jobware.de" + href
                job_urls.add(href)
        if len(job_urls) == start_len:
            break
        current_page += 1
    return list(job_urls)[:max_jobs]

def get_urls_heise(page, max_jobs=70):
    job_urls = set()
    current_page = 1
    while len(job_urls) < max_jobs:
        page.goto(f"https://jobs.heise.de/jobs?page={current_page}", wait_until="networkidle")
        links = page.locator("a[href*='/jobs/']").all()
        start_len = len(job_urls)
        for link in links:
            href = link.get_attribute("href")
            if href and '/jobs/' in href and not '/company/' in href:
                if not href.startswith("http"):
                    href = "https://jobs.heise.de" + href
                job_urls.add(href)
        if len(job_urls) == start_len:
            break
        current_page += 1
    return list(job_urls)[:max_jobs]

def get_urls_stellenanzeigen(page, max_jobs=60):
    job_urls = set()
    page.goto(f"https://www.stellenanzeigen.de/jobs/", wait_until="networkidle")
    links = page.locator("a[href*='/job/']").all()
    for link in links:
        href = link.get_attribute("href")
        if href:
            if not href.startswith("http"):
                href = "https://www.stellenanzeigen.de" + href
            job_urls.add(href)
    return list(job_urls)[:max_jobs]

def save_to_pdf(page, url, prefix, index, out_dir):
    try:
        print(f"Fetching {prefix}: {url}")
        page.goto(url, wait_until="networkidle", timeout=60000)
        # generic cookie banner removal
        page.evaluate('''
            const selectors = ['.cookie-banner', '.banner', 'div[role="dialog"]', 'div[id^="usercentrics"]', 'div[id^="sp_message_container"]'];
            selectors.forEach(sel => {
                try { document.querySelectorAll(sel).forEach(e => e.remove()); } catch(e) {}
            });
            document.body.style.overflow = 'auto';
        ''')
        pdf_path = os.path.join(out_dir, f"{prefix}_job_{index:03d}.pdf")
        page.pdf(path=pdf_path, format="A4", print_background=True)
        print(f"Saved: {pdf_path}")
    except Exception as e:
        print(f"Error saving {url}: {e}")

def main():
    out_dir = r"S:\Projekte\JobTracker\training_data\jobs_pdf"
    os.makedirs(out_dir, exist_ok=True)
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1920, "height": 1080})
        page = context.new_page()
        
        print("Fetching Jobware URLs...")
        urls_jw = get_urls_jobware(page, 70)
        print("Fetching Heise URLs...")
        urls_he = get_urls_heise(page, 70)
        print("Fetching Stellenanzeigen URLs...")
        urls_st = get_urls_stellenanzeigen(page, 60)
        
        urls = [('jobware', u) for u in urls_jw] + [('heise', u) for u in urls_he] + [('stellenanzeigen', u) for u in urls_st]
        
        print(f"Total urls to fetch: {len(urls)}")
        for i, (prefix, url) in enumerate(urls, 1):
            save_to_pdf(page, url, prefix, i, out_dir)
            
        browser.close()
        print("Done downloading diverse jobs!")

if __name__ == "__main__":
    main()
