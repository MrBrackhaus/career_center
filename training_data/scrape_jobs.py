import os
import time
from playwright.sync_api import sync_playwright

def get_job_urls(page, max_jobs=200):
    job_urls = set()
    current_page = 1
    
    while len(job_urls) < max_jobs:
        url = f"https://jobs.zeit.de/stellenanzeigen?page={current_page}"
        print(f"Fetching job list page {current_page}...")
        page.goto(url, wait_until="networkidle")
        
        links = page.locator("a[href*='/jobs/']").all()
        new_links = 0
        for link in links:
            href = link.get_attribute("href")
            if href and "/jobs/" in href:
                if not href.startswith("http"):
                    href = "https://jobs.zeit.de" + href
                if len(href.split('/')[-1]) > 15:
                    if href not in job_urls:
                        job_urls.add(href)
                        new_links += 1
                        if len(job_urls) >= max_jobs:
                            break
        
        if new_links == 0:
            print("No more new links found or bot protection active.")
            break
            
        current_page += 1
        time.sleep(1)
        
    return list(job_urls)

def save_to_pdf(page, url, index, out_dir):
    try:
        print(f"[{index}/200] Fetching {url}")
        page.goto(url, wait_until="networkidle", timeout=60000)
        
        page.evaluate('''
            const selectors = [
                '#usercentrics-root', 
                '.cookie-banner', 
                '.banner',
                'div[role="dialog"]',
                'div[id^="usercentrics"]'
            ];
            selectors.forEach(sel => {
                try {
                    const els = document.querySelectorAll(sel);
                    els.forEach(e => e.remove());
                } catch(e) {}
            });
            const uc = document.querySelector('#usercentrics-root');
            if (uc) uc.remove();
            
            document.body.style.overflow = 'auto';
        ''')
        
        pdf_path = os.path.join(out_dir, f"job_{index:03d}.pdf")
        page.pdf(path=pdf_path, format="A4", print_background=True)
        print(f"Saved: {pdf_path}")
    except Exception as e:
        print(f"Error saving {url}: {e}")

def main():
    out_dir = r"S:\Projekte\JobTracker\training_data\jobs_pdf"
    os.makedirs(out_dir, exist_ok=True)
    print(f"Saving PDFs to: {out_dir}")
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1920, "height": 1080})
        page = context.new_page()
        
        urls = get_job_urls(page, 200)
        print(f"Found {len(urls)} job URLs.")
        
        for i, url in enumerate(urls, 1):
            save_to_pdf(page, url, i, out_dir)
            
        browser.close()
        print("Done! Collection complete.")

if __name__ == "__main__":
    main()
