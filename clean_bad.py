import sqlite3, os, sys
sys.stdout.reconfigure(encoding="utf-8")
db_path = os.path.join(os.environ["USERPROFILE"], "Documents", "jobtracker.sqlite")
conn = sqlite3.connect(db_path)
cur = conn.cursor()
cur.execute("""
    DELETE FROM applications WHERE 
    company = "Unbekannte Firma" OR 
    company LIKE "%Ihnen fuer%" OR
    company LIKE "%Ihnen f%r%" OR
    position LIKE "%Junior) IT%"
""")
print(f"Deleted {cur.rowcount} bad entries")
conn.commit()
conn.close()
