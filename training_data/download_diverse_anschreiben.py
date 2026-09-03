import os
import urllib.request
import concurrent.futures
import json
import uuid

json_path = r"S:\Projekte\JobTracker\training_data\cover_letter_templates_2.json"
out_dir = r"S:\Projekte\JobTracker\training_data"
os.makedirs(out_dir, exist_ok=True)

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

def download_url(item):
    url = item['downloadUrl']
    name_hint = item['url'].strip('/').split('/')[-1]
    # To determine extension, we might just use .zip or .docx depending on content-disposition, but let's just save and guess if needed,
    # or just use name_hint + ".zip" (these sites often give zips or pdfs).
    # Since we can't be sure, let's open it to get headers.
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    try:
        with urllib.request.urlopen(req, timeout=15) as response:
            cd = response.headers.get('Content-Disposition', '')
            ext = '.pdf'
            if 'filename=' in cd:
                filename = cd.split('filename=')[1].strip('"\'')
            else:
                if 'application/zip' in response.headers.get('Content-Type', ''):
                    ext = '.zip'
                elif 'application/vnd.openxmlformats' in response.headers.get('Content-Type', ''):
                    ext = '.docx'
                elif 'application/msword' in response.headers.get('Content-Type', ''):
                    ext = '.doc'
                filename = f"{name_hint}_{uuid.uuid4().hex[:4]}{ext}"
            
            out_path = os.path.join(out_dir, filename)
            
            if os.path.exists(out_path):
                return f"Already exists: {filename}"
                
            with open(out_path, 'wb') as out_file:
                out_file.write(response.read())
            return f"Downloaded: {filename}"
    except Exception as e:
        return f"Error downloading {url}: {e}"

if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        results = list(executor.map(download_url, data))
    
    success = sum(1 for r in results if r.startswith("Downloaded") or r.startswith("Already exists"))
    print(f"Successfully processed: {success} out of {len(data)}")
    
    for r in results:
        if r.startswith("Error"):
            print(r)
