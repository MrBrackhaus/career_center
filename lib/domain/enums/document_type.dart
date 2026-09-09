/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
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
