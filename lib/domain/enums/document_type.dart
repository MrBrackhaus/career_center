/// Alle erkennbaren Dokumenttypen im JobTracker.
enum DocumentType {
  /// Eigenes Bewerbungsanschreiben (ausgehend)
  anschreiben,

  /// Stellenanzeige / Job-Posting von Arbeitgeber oder Portal
  stellenanzeige,

  /// Ablehnungsschreiben / Absage vom Arbeitgeber
  absage,

  /// Einladung zum Vorstellungsgespräch / Interview
  einladung,

  /// Eingangsbestätigung der Bewerbung
  bestaetigung,

  /// Lebenslauf / CV
  lebenslauf,

  /// Zeugnis / Zertifikat
  zertifikat,

  /// Nicht klassifizierbar
  unknown,
}

/// Menschenlesbare Bezeichnungen für die UI.
extension DocumentTypeLabel on DocumentType {
  String get label {
    switch (this) {
      case DocumentType.anschreiben:
        return 'Anschreiben';
      case DocumentType.stellenanzeige:
        return 'Stellenanzeige';
      case DocumentType.absage:
        return 'Absage';
      case DocumentType.einladung:
        return 'Einladung';
      case DocumentType.bestaetigung:
        return 'Bestätigung';
      case DocumentType.lebenslauf:
        return 'Lebenslauf';
      case DocumentType.zertifikat:
        return 'Zertifikat';
      case DocumentType.unknown:
        return 'Unbekannt';
    }
  }
}

