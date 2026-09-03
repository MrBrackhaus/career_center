# -*- coding: utf-8 -*-
import os

de_content = """{
  "appName": "Bewerbungszentrale",
  "navDashboard": "Dashboard",
  "navApplications": "Bewerbungen",
  "navCalendar": "Kalender",
  "navTemplates": "Vorlagen",
  "navSettings": "Einstellungen",
  
  "applicationsTitle": "Meine Bewerbungen",
  "btnNewApplication": "Neue Bewerbung",
  
  "statusOpen": "Offen",
  "statusSent": "Versendet",
  "statusInterview": "Interview",
  "statusAccepted": "Zusage",
  "statusRejected": "Absage",
  
  "kanbanPreparation": "📝 In Vorbereitung",
  "kanbanWaiting": "⏳ Warten auf Antwort",
  "kanbanInterview": "🗣️ Im Gespräch",
  "kanbanOffers": "🎉 Angebote",
  "kanbanArchive": "🗑️ Archiv (Absagen)",

  "searchPlaceholder": "Suche nach Firma, Position, Ort...",
  
  "emptyApplicationsTitle": "Noch keine Bewerbungen",
  "emptyApplicationsDesc": "Es sieht so aus, als hättest du noch keine Bewerbungen hinzugefügt. Klicke auf 'Neue Bewerbung', um loszulegen!"
}"""

en_content = """{
  "appName": "Career Center",
  "navDashboard": "Dashboard",
  "navApplications": "Applications",
  "navCalendar": "Calendar",
  "navTemplates": "Templates",
  "navSettings": "Settings",

  "applicationsTitle": "My Applications",
  "btnNewApplication": "New Application",

  "statusOpen": "Open",
  "statusSent": "Sent",
  "statusInterview": "Interview",
  "statusAccepted": "Accepted",
  "statusRejected": "Rejected",

  "kanbanPreparation": "📝 In Preparation",
  "kanbanWaiting": "⏳ Waiting for Reply",
  "kanbanInterview": "🗣️ In Interviews",
  "kanbanOffers": "🎉 Offers",
  "kanbanArchive": "🗑️ Archive (Rejected)",

  "searchPlaceholder": "Search for company, position...",
  
  "emptyApplicationsTitle": "No applications yet",
  "emptyApplicationsDesc": "It looks like you haven't added any applications yet. Click 'New Application' to get started!"
}"""

with open('lib/l10n/app_de.arb', 'w', encoding='utf-8') as f:
    f.write(de_content)

with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    f.write(en_content)

print("ARB files fixed.")
