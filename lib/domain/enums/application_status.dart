/// Kanonische Bewerbungsstatus, die das Kanban-Board kennt.
///
/// Alle Stellen, die einen Status in die Datenbank schreiben, sollten den
/// Wert vorher mit [normalizeApplicationStatus] normalisieren, damit keine
/// Bewerbungen mit unbekanntem Status vom Board "verschwinden".
class ApplicationStatus {
  ApplicationStatus._();

  static const String offen = 'offen';
  static const String versendet = 'versendet';
  static const String interview = 'interview';
  static const String zusage = 'zusage';
  static const String absage = 'absage';

  static const List<String> values = [
    offen,
    versendet,
    interview,
    zusage,
    absage,
  ];
}

const Map<String, String> _statusAliases = {
  // kanonische Werte
  'offen': ApplicationStatus.offen,
  'versendet': ApplicationStatus.versendet,
  'interview': ApplicationStatus.interview,
  'zusage': ApplicationStatus.zusage,
  'absage': ApplicationStatus.absage,
  // Aliase aus Extraktoren / KI / Altdaten
  'bestaetigung': ApplicationStatus.versendet,
  'bestätigung': ApplicationStatus.versendet,
  'eingangsbestätigung': ApplicationStatus.versendet,
  'eingangsbestaetigung': ApplicationStatus.versendet,
  'gesendet': ApplicationStatus.versendet,
  'beworben': ApplicationStatus.versendet,
  'in prüfung': ApplicationStatus.versendet,
  'in pruefung': ApplicationStatus.versendet,
  'sent': ApplicationStatus.versendet,
  'applied': ApplicationStatus.versendet,
  'einladung': ApplicationStatus.interview,
  'vorstellungsgespräch': ApplicationStatus.interview,
  'vorstellungsgespraech': ApplicationStatus.interview,
  'gespräch': ApplicationStatus.interview,
  'angebot': ApplicationStatus.zusage,
  'jobangebot': ApplicationStatus.zusage,
  'offer': ApplicationStatus.zusage,
  'abgelehnt': ApplicationStatus.absage,
  'rejected': ApplicationStatus.absage,
  'rejection': ApplicationStatus.absage,
  'open': ApplicationStatus.offen,
  'entwurf': ApplicationStatus.offen,
};

/// Bildet einen beliebigen Status-String (z.B. aus E-Mail-Extraktion, KI oder
/// Altdaten) auf einen der kanonischen Werte aus [ApplicationStatus] ab.
///
/// Groß-/Kleinschreibung und umgebende Leerzeichen werden ignoriert.
/// Unbekannte oder leere Werte liefern [fallback].
String normalizeApplicationStatus(
  String? raw, {
  String fallback = ApplicationStatus.versendet,
}) {
  if (raw == null) return fallback;
  final key = raw.trim().toLowerCase();
  if (key.isEmpty) return fallback;
  return _statusAliases[key] ?? fallback;
}
