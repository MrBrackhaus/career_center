/*
 * Bewerbungszentrale (Career Center)
 * Copyright (C) 2026. Alle Rechte vorbehalten / All rights reserved.
 * Siehe README.md.
 */
import '../../../domain/enums/document_type.dart';
import 'naive_bayes_classifier.dart';

class PretrainedModel {
  static NaiveBayesClassifier create() {
    var classifier = NaiveBayesClassifier();

    // Synthetische Trainingsbeispiele (frei erfunden, keine echten Personendaten).
    var samples = {
      DocumentType.anschreiben: [
        "Max Mustermann Musterstraße 1 12345 Musterstadt Telefon 0123 456789 E-Mail max.mustermann@example.com Beispiel GmbH Personalabteilung Hauptstraße 10 54321 Beispielstadt Musterstadt, 01.03.2026 Bewerbung als Fachinformatiker für Systemintegration (m/w/d) Sehr geehrte Damen und Herren, mit großem Interesse habe ich Ihre Stellenanzeige gelesen und bewerbe mich hiermit um die ausgeschriebene Position. Während meiner Ausbildung konnte ich umfangreiche Erfahrungen in der Administration von Windows- und Linux-Servern sammeln. Zu meinen Stärken zählen Zuverlässigkeit, Teamfähigkeit und eine strukturierte Arbeitsweise. Über eine Einladung zu einem persönlichen Gespräch freue ich mich sehr. Mit freundlichen Grüßen Max Mustermann Anlagen Lebenslauf Zeugnisse",
        "Erika Musterfrau Beispielweg 5 12345 Musterstadt erika.musterfrau@example.com Muster AG z. Hd. Frau Beispiel Industriestraße 3 54321 Beispielstadt Bewerbung um eine Stelle als Kauffrau für Büromanagement Sehr geehrte Frau Beispiel, hiermit bewerbe ich mich auf Ihre Stellenanzeige. In meiner bisherigen Tätigkeit habe ich Erfahrungen in der Terminplanung, der Korrespondenz und der Buchhaltung gesammelt. Ich arbeite gerne im Team und bringe ein hohes Maß an Organisationstalent mit. Mein frühestmöglicher Eintrittstermin ist der 01.04.2026. Ich freue mich darauf, Sie in einem persönlichen Gespräch von meiner Motivation zu überzeugen. Mit freundlichen Grüßen Erika Musterfrau",
        "Bewerbung als IT-Systemadministrator (m/w/d) Sehr geehrter Herr Muster, Ihre Stellenausschreibung hat mein Interesse geweckt, da sie genau meinen Kenntnissen und Erfahrungen entspricht. Seit mehreren Jahren betreue ich Netzwerke, Active Directory und virtuelle Server. Besonders reizt mich an Ihrem Unternehmen die Möglichkeit, Verantwortung zu übernehmen und mich fachlich weiterzuentwickeln. Meine Gehaltsvorstellung liegt bei 48.000 Euro brutto jährlich. Über eine Einladung zu einem Vorstellungsgespräch würde ich mich sehr freuen. Mit freundlichen Grüßen",
        "Sehr geehrte Damen und Herren, auf Ihrer Internetseite bin ich auf die ausgeschriebene Stelle als IT-Support Mitarbeiter aufmerksam geworden und bewerbe mich hiermit. Ich bin ein kommunikativer und lösungsorientierter Mensch und unterstütze Anwender gerne bei technischen Problemen. Im First- und Second-Level-Support habe ich bereits Erfahrungen gesammelt. Gerne überzeuge ich Sie in einem persönlichen Gespräch davon, dass ich gut in Ihr Team passe. Mit freundlichen Grüßen",
        "Initiativbewerbung als Softwareentwickler Sehr geehrte Damen und Herren, ich möchte mich Ihnen initiativ als Softwareentwickler vorstellen. Ich habe ein Studium der Informatik abgeschlossen und verfüge über Kenntnisse in Java, Python und Dart. In Projekten habe ich gelernt, Anforderungen strukturiert umzusetzen und im Team zu arbeiten. Ihr Unternehmen begeistert mich durch seine innovativen Produkte. Ich freue mich über eine Rückmeldung und die Gelegenheit zu einem Gespräch. Mit freundlichen Grüßen Anlagen",
        "Bewerbung um einen Ausbildungsplatz als Fachinformatiker Anwendungsentwicklung Sehr geehrte Frau Beispiel, hiermit bewerbe ich mich um einen Ausbildungsplatz in Ihrem Unternehmen. Ich besuche derzeit die zwölfte Klasse und werde im Sommer mein Abitur abschließen. Schon seit meiner Kindheit interessiere ich mich für Computer und programmiere in meiner Freizeit. Ein Praktikum hat mich in meinem Berufswunsch bestärkt. Über eine Einladung zu einem Vorstellungsgespräch freue ich mich. Mit freundlichen Grüßen",
        "Bewerbung als Pflegefachkraft (m/w/d) Sehr geehrte Damen und Herren, mit großem Interesse habe ich Ihre Anzeige gelesen. Als examinierte Pflegefachkraft bringe ich mehrjährige Berufserfahrung in der stationären Pflege mit. Die Arbeit mit Menschen erfüllt mich, und ich bin es gewohnt, im Schichtdienst zuverlässig und belastbar zu arbeiten. Ich bin ab sofort verfügbar und freue mich darauf, Sie persönlich kennenzulernen. Mit freundlichen Grüßen",
        "Ihre Stellenanzeige als Elektriker Sehr geehrter Herr Muster, hiermit bewerbe ich mich auf die ausgeschriebene Stelle als Elektroniker für Energie- und Gebäudetechnik. Nach meiner abgeschlossenen Ausbildung habe ich mehrere Jahre auf Baustellen gearbeitet und Elektroinstallationen in Wohn- und Gewerbegebäuden durchgeführt. Ich besitze einen Führerschein der Klasse B und bin flexibel einsetzbar. Gerne stelle ich mich Ihnen in einem persönlichen Gespräch vor. Mit freundlichen Grüßen",
        "Bewerbung für die Position Projektmanager Sehr geehrte Damen und Herren, die ausgeschriebene Position als Projektmanager spricht mich sehr an. In meiner aktuellen Position leite ich Projekte mit bis zu zehn Mitarbeitern und verantworte Budget, Zeitplanung und Kommunikation mit Kunden. Ich bin überzeugt, dass ich mit meiner Erfahrung einen wertvollen Beitrag zu Ihrem Unternehmen leisten kann. Meine Kündigungsfrist beträgt drei Monate. Über eine positive Rückmeldung freue ich mich sehr. Mit freundlichen Grüßen",
        "Sehr geehrte Frau Beispiel, vielen Dank für das freundliche Telefonat. Wie besprochen sende ich Ihnen meine Bewerbungsunterlagen für die Stelle als Lagerlogistiker. Ich habe Erfahrung in der Kommissionierung, im Wareneingang und mit dem Staplerschein. Ich arbeite sorgfältig, bin pünktlich und teamfähig. Ich freue mich darauf, von Ihnen zu hören, und stehe für ein Vorstellungsgespräch jederzeit zur Verfügung. Mit freundlichen Grüßen Anlagen Lebenslauf Arbeitszeugnisse",
        "Bewerbung als Werkstudent im Bereich Marketing Sehr geehrte Damen und Herren, als Student der Betriebswirtschaftslehre bewerbe ich mich hiermit um eine Stelle als Werkstudent. Ich verfüge über erste Erfahrungen im Social-Media-Marketing und in der Erstellung von Inhalten. Ich kann bis zu zwanzig Stunden pro Woche arbeiten. Ich freue mich auf Ihre Antwort und ein persönliches Kennenlernen. Mit freundlichen Grüßen",
        "Cover Letter Application for the position of System Administrator Dear Sir or Madam, I am writing to apply for the position advertised on your website. I have several years of experience administering Windows and Linux servers and supporting users. I am a reliable team player and enjoy solving technical problems. I would welcome the opportunity to discuss my application in an interview. Yours sincerely",
      ],
      DocumentType.stellenanzeige: [
        "Stellenangebot Fachinformatiker für Systemintegration (m/w/d) Beispiel GmbH Arbeitsort Beispielstadt Anstellungsart Vollzeit unbefristet Beginn ab sofort Wir suchen Verstärkung für unser IT-Team. Ihre Aufgaben: Administration der Server- und Netzwerkinfrastruktur, Betreuung der Anwender im Support, Pflege von Active Directory und Microsoft 365. Ihr Profil: abgeschlossene Ausbildung als Fachinformatiker, Kenntnisse in Windows Server und Linux, Teamfähigkeit. Wir bieten: attraktive Vergütung, 30 Tage Urlaub, flexible Arbeitszeiten, Homeoffice, Weiterbildungsmöglichkeiten. Haben wir Ihr Interesse geweckt? Dann freuen wir uns auf Ihre Bewerbung unter Angabe Ihrer Gehaltsvorstellung. Jetzt bewerben",
        "Jobbörse Stellenangebot IT-Systemadministrator (m/w/d) Muster AG Vollzeit Gehalt 45.000 € – 55.000 € pro Jahr Deine Aufgaben Betrieb und Weiterentwicklung unserer IT-Systeme Virtualisierung mit VMware Backup und Monitoring Dein Profil Berufserfahrung in der Systemadministration gute Deutschkenntnisse Das bieten wir dir unbefristeter Arbeitsvertrag Jobrad betriebliche Altersvorsorge moderne Arbeitsplätze Bewirb dich jetzt online Ansprechpartner Personalabteilung Jobs Karriere Arbeitgeber",
        "Wir suchen Sie als IT-Support Techniker (m/w/d) Standort Musterstadt Anstellungsart Vollzeit oder Teilzeit Ihre Aufgaben First- und Second-Level-Support für unsere Kunden Installation und Konfiguration von Hardware und Software Dokumentation im Ticketsystem Ihr Profil Ausbildung im IT-Bereich oder vergleichbare Qualifikation Kundenorientierung Führerschein Klasse B Unser Angebot Firmenwagen Weiterbildung angenehmes Betriebsklima Bewerbung bitte per E-Mail an jobs@example.com Stellenangebote Karriere",
        "Karriere Stellenangebote Softwareentwickler (m/w/d) Flutter / Dart Remote möglich Beispiel Software GmbH Über uns Wir entwickeln innovative Apps für unsere Kunden. Deine Aufgaben Entwicklung neuer Features Code Reviews Zusammenarbeit im agilen Team Scrum Dein Profil Studium der Informatik oder Ausbildung Erfahrung mit Flutter Git REST Wir bieten 30 Tage Urlaub Homeoffice Weiterbildungsbudget Gehalt 55.000 € bis 70.000 € Jetzt bewerben Datenschutz Impressum",
        "Stellenanzeige Kaufmann / Kauffrau für Büromanagement (m/w/d) Muster GmbH & Co. KG Arbeitsort Musterstadt Arbeitszeit Teilzeit 30 Stunden Ihre Aufgaben Allgemeine Büro- und Verwaltungstätigkeiten Bearbeitung der Korrespondenz Terminkoordination Unterstützung der Buchhaltung Ihr Profil abgeschlossene kaufmännische Ausbildung sicherer Umgang mit MS Office Wir bieten unbefristete Anstellung Vergütung nach Tarif Zuschuss zum Deutschlandticket Wir freuen uns auf Ihre aussagekräftigen Bewerbungsunterlagen Stellenangebote Jobsuche",
        "Jobsuche Stellenangebot Pflegefachkraft (m/w/d) Seniorenzentrum Beispiel Arbeitsort Beispielstadt Vollzeit Teilzeit Schichtdienst Ihre Aufgaben Grund- und Behandlungspflege Pflegedokumentation Betreuung der Bewohner Ihr Profil examinierte Pflegefachkraft Empathie Zuverlässigkeit Wir bieten Vergütung nach Tarif Zuschläge betriebliche Altersvorsorge Fort- und Weiterbildungen Bewerben Sie sich jetzt Ansprechpartner Personalabteilung Telefon 0123 456789 Merken Teilen",
        "Stellenangebot Elektroniker für Energie- und Gebäudetechnik (m/w/d) Elektro Muster GmbH Beginn ab sofort Vollzeit Deine Aufgaben Elektroinstallation in Neubauten und Bestandsgebäuden Wartung und Instandhaltung Prüfung von Anlagen Dein Profil abgeschlossene Berufsausbildung Führerschein Klasse B Wir bieten übertarifliche Bezahlung Firmenfahrzeug moderne Werkzeuge Arbeitskleidung Jetzt bewerben Stellenangebote Jobs Arbeitgeber",
        "Lagerlogistik Stellenangebot Fachkraft für Lagerlogistik (m/w/d) Logistik Beispiel AG Arbeitsort Musterstadt Arbeitszeit Vollzeit Schicht Ihre Aufgaben Wareneingang und Warenausgang Kommissionierung Bedienung von Flurförderzeugen Inventur Ihr Profil Staplerschein Erfahrung in der Logistik Zuverlässigkeit Wir bieten unbefristeter Arbeitsvertrag Schichtzulagen Gehalt 2.800 € bis 3.200 € monatlich Jetzt online bewerben Stellenangebote",
        "Projektmanager (m/w/d) Vollzeit unbefristet Muster Consulting GmbH Wir sind ein wachsendes Beratungsunternehmen. Ihre Aufgaben Planung, Steuerung und Controlling von Kundenprojekten Budgetverantwortung Kommunikation mit Stakeholdern Ihr Profil abgeschlossenes Studium mehrjährige Berufserfahrung im Projektmanagement Zertifizierung PRINCE2 oder PMP von Vorteil Wir bieten attraktives Gehalt Dienstwagen flexible Arbeitszeiten Homeoffice Haben wir Ihr Interesse geweckt Jetzt bewerben Karriere",
        "Werkstudent (m/w/d) Marketing Beispiel Startup GmbH Arbeitsort Beispielstadt Teilzeit 20 Stunden pro Woche Deine Aufgaben Unterstützung bei Social-Media-Kampagnen Erstellung von Inhalten Analyse von Kennzahlen Dein Profil eingeschriebener Student Wirtschaftswissenschaften oder Kommunikation Kreativität Wir bieten flexible Arbeitszeiten junges Team Vergütung 15 € pro Stunde Bewirb dich jetzt Stellenangebote Jobs",
        "Ausbildung Fachinformatiker Anwendungsentwicklung (m/w/d) Ausbildungsbeginn 01.08.2026 Muster IT GmbH Ausbildungsdauer 3 Jahre Das erwartet dich Programmierung von Anwendungen Datenbanken Webentwicklung Berufsschule Das bringst du mit Abitur oder Fachabitur Interesse an IT logisches Denken Wir bieten Ausbildungsvergütung Übernahmechance Laptop Bewirb dich jetzt Ausbildungsplätze Karriere",
        "Job offer System Administrator (m/f/d) Example Corp Location Example City Full-time Your tasks Administration of Windows and Linux servers network management user support Your profile completed vocational training or degree in computer science experience with virtualization We offer competitive salary 30 days vacation remote work Apply now Jobs Careers",
      ],
      DocumentType.absage: [
        "Ihre Bewerbung als Fachinformatiker Sehr geehrter Herr Mustermann wir bedanken uns für Ihre Bewerbung leider müssen wir Ihnen mitteilen dass wir uns für einen anderen Bewerber entschieden haben",
        "wir haben Ihre Bewerbung sorgfältig geprüft leider können wir Ihre Bewerbung nicht berücksichtigen die Stelle wurde anderweitig besetzt",
        "Absage Bewerbung als IT-Consultant wir danken Ihnen für das entgegengebrachte Interesse und die Übersendung Ihrer Unterlagen leider fiel die Entscheidung auf einen Mitbewerber",
        "Ihre Bewerbung bei uns Sehr geehrte Frau Müller wir bedauern Ihnen mitteilen zu müssen dass wir Ihnen keine positive Nachricht geben können",
        "Wir danken für das angenehme Gespräch leider müssen wir Ihnen heute eine Absage erteilen",
        "Leider können wir Sie im aktuellen Auswahlverfahren nicht weiter berücksichtigen wir wünschen Ihnen für Ihre berufliche Zukunft alles Gute",
      ],
      DocumentType.einladung: [
        "Einladung zum Vorstellungsgespräch Sehr geehrter Herr Mustermann wir möchten Sie gerne persönlich kennenlernen und laden Sie herzlich zu einem Vorstellungsgespräch ein",
        "Interview-Einladung vielen Dank für Ihre Bewerbung wir würden uns freuen Sie zu einem persönlichen Gespräch einzuladen",
        "Einladung zum Online-Interview Sehr geehrte Frau Schmidt",
        "Wir freuen uns Sie zu einem Kennenlerngespräch in unser Büro einzuladen",
        "Vorstellungsgespräch Terminbestätigung",
      ],
      DocumentType.bestaetigung: [
        "Eingangsbestätigung Ihrer Bewerbung Sehr geehrter Herr Mustermann vielen Dank für Ihre Bewerbung wir haben Ihre Unterlagen erhalten und werden diese sorgfältig prüfen",
        "Bestätigung Bewerbungseingang wir bestätigen den Eingang Ihrer Bewerbung als Fachinformatiker",
        "Vielen Dank für Ihre Bewerbung und das entgegengebrachte Interesse an unserem Unternehmen",
        "Wir haben Ihre Bewerbungsunterlagen erhalten und melden uns in Kürze",
      ],
      DocumentType.lebenslauf: [
        "Lebenslauf Max Mustermann Persönliche Daten Geburtsdatum Berufserfahrung Ausbildung Fachinformatiker Systemintegration Kenntnisse Windows Linux",
        "Curriculum Vitae Beruflicher Werdegang Schulbildung Weiterbildung EDV-Kenntnisse Sprachen Hobbys",
        "Werdegang Berufserfahrung Praktika IT-Kenntnisse Schulischer Werdegang",
        "CV Personal Details Work Experience Education Skills Languages",
      ],
      DocumentType.zertifikat: [
        "Zeugnis Ausbildungszeugnis Herr Mustermann hat die Ausbildung zum Fachinformatiker mit der Note gut bestanden",
        "Zertifikat ITIL Foundation Certificate hiermit wird bestätigt dass Herr Mustermann die Prüfung erfolgreich bestanden hat",
        "IHK Abschlusszeugnis Fachinformatiker",
        "Teilnahmebescheinigung Schulung Seminar Azure Administrator",
        "Zertifikat Microsoft Certified Professional",
      ],
    };

    classifier.trainBatch(samples);
    return classifier;
  }
}
