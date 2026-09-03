import sqlite3, os, sys
sys.stdout.reconfigure(encoding="utf-8")
db_path = os.path.join(os.environ["USERPROFILE"], "Documents", "jobtracker.sqlite")
conn = sqlite3.connect(db_path)
cur = conn.cursor()
# Also delete the AW: reply that was wrongly imported as sent application
cur.execute("SELECT id, company, position, notes FROM applications")
to_delete = []
for row in cur.fetchall():
    app_id, company, position, notes = row
    # Any remaining junk
    if company and (
        "Ihnen" in (company or "") or
        "vielen Dank" in (company or "") or
        (company or "").startswith('"')
    ):
        to_delete.append(app_id)
        print(f"Will delete id={app_id}: {company} - {position}")

if to_delete:
    cur.executemany("DELETE FROM applications WHERE id = ?", [(i,) for i in to_delete])
    conn.commit()
    print(f"Deleted {len(to_delete)} entries")
else:
    print("Nothing to clean")

# Show remaining
cur.execute("SELECT id, company, position FROM applications")
print("\nRemaining applications:")
for row in cur.fetchall():
    print(row)
conn.close()
