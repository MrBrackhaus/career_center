$AnschreibenURLs = @(
"https://afaverden.de/media/checkliste_fuer_ein_eindrucksvolles_anschreiben_.pdf",
"https://web.pdx.edu/~fischerw/courses/301_302/docs/AnschreibenBewerbung_JobScout_836_JS24.pdf",
"https://www.dienstleistungsberufe.de/tipps/pdf/anschreiben.pdf",
"https://www.mustertexte-musterbewerbung.de/bewerbungsanschreiben-vorlagen-und-mustertexte.pdf",
"https://www.arbeit-bildung-zukunft.de/sites/default/files/dokumente/anleitung_anschreiben_0.pdf",
"https://www.worksmart.de/wp-content/uploads/2019/01/Beispiel-fu%CC%88r-eine-erfolgreiche-Bewerbung-mit-verkaufsfa%CC%88higer-Botschaft.pdf",
"https://www.tu-chemnitz.de/career-service/pdf/bewerberbroschuere_2026_onlineversion.pdf",
"https://www.projekt-team.de/wp-content/uploads/2017/06/Das-Anschreiben.pdf",
"https://www.berufsstrategie.de/_img/bewerbungsunterlagen/5-anschreiben-formulieren-beispiel-link.pdf",
"https://www.zukunftimglas.de/fileadmin/user_upload/ZIG_Onlinebewerbung_Checkliste.pdf"
)

$StellengesucheURLs = @(
"https://www.gplus.ch/de-wAssets/docs/Mustertexte-fuer-Stellengesuche.pdf",
"https://www.hs-harz.de/user-mounts/451_m2947/Hilfestellung_zur_Gestaltung_von_Stellenanzeigen_fuer_Unternehmen.pdf",
"https://www.redalyc.org/pdf/6645/664573490004.pdf",
"https://www.berufsorientierung-gymnasium.bayern.de/fileadmin/user_upload/oberstufe/Umsetzungsbeispiele_Bewerbungstag_idS.pdf",
"https://www.bielmeier-und-partner.de/assets/downloads/62263578/perfekt-bewerben_von-bielmeier--partner.pdf",
"https://www.jobware.de/export/sites/jobware.de/Ressourcen/Pdf/Ratgeber/Jobware-Bewerbungs-Ratgeber.pdf",
"https://www.kofa.de/media/Publikationen/Checklisten/Stellenausschreibung_Menschen_mit_Behinderung.pdf",
"https://polizei.nrw/sites/default/files/2020-02/Stellenausschreibung%20L%20ZA%203.1.pdf",
"https://www.wre-trainings.de/images/2022/11/WRE_Handbuch_Personalgewinnung_Tourismus_Seite_7.pdf",
"http://www.bewerbungsdschungel.com/attachments/File/Anschreiben4_allgemein.pdf"
)

$TargetDir = "s:\Projekte\JobTracker\training_data"
New-Item -ItemType Directory -Force -Path $TargetDir

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$i = 1
foreach ($url in $AnschreibenURLs) {
    $FilePath = Join-Path -Path $TargetDir -ChildPath "Anschreiben_$i.pdf"
    try {
        Invoke-WebRequest -Uri $url -OutFile $FilePath -UseBasicParsing -ErrorAction Stop
        Write-Host "Downloaded Anschreiben_$i.pdf"
    } catch {
        Write-Host "Failed to download Anschreiben_$i.pdf from $url : $_"
    }
    $i++
}

$j = 1
foreach ($url in $StellengesucheURLs) {
    $FilePath = Join-Path -Path $TargetDir -ChildPath "Stellengesuch_$j.pdf"
    try {
        Invoke-WebRequest -Uri $url -OutFile $FilePath -UseBasicParsing -ErrorAction Stop
        Write-Host "Downloaded Stellengesuch_$j.pdf"
    } catch {
        Write-Host "Failed to download Stellengesuch_$j.pdf from $url : $_"
    }
    $j++
}
