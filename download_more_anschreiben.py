import os
import urllib.request
import concurrent.futures
import json

json_path = r"S:\Projekte\JobTracker\training_data\cover_letter_templates.json"
out_dir = r"S:\Projekte\JobTracker\training_data"
os.makedirs(out_dir, exist_ok=True)

with open(json_path, 'r', encoding='utf-8') as f:
    urls = json.load(f)

def download_url(url):
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    filename = url.split('/')[-1].split('?')[0]
    out_path = os.path.join(out_dir, filename)
    
    if os.path.exists(out_path):
        return f"Already exists: {filename}"
        
    try:
        with urllib.request.urlopen(req, timeout=15) as response, open(out_path, 'wb') as out_file:
            data = response.read()
            out_file.write(data)
        return f"Downloaded: {filename}"
    except Exception as e:
        return f"Error downloading {url}: {e}"

if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        results = list(executor.map(download_url, urls))
    
    success = sum(1 for r in results if r.startswith("Downloaded") or r.startswith("Already exists"))
    print(f"Successfully processed: {success} out of {len(urls)}")
    
    for r in results:
        if r.startswith("Error"):
            print(r)
