import 'dart:convert';

/// Dekodiert das JSON der benutzerdefinierten Felder. Ungültiges JSON oder
/// Nicht-Objekte ergeben eine leere Map.
Map<String, String> decodeCustomFields(String? raw) {
  if (raw == null || raw.trim().isEmpty) return {};
  try {
    final decoded = json.decode(raw);
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  } catch (_) {
    return {};
  }
}

/// Führt die gespeicherten Felder [stored] mit den aktuellen Eingaben
/// [edited] zusammen.
///
/// Felder, die nicht (mehr) in der Spaltenkonfiguration stehen und daher
/// keinen Controller haben, bleiben erhalten. Felder mit Controller werden
/// mit dem Eingabewert überschrieben; ein geleertes Feld wird entfernt.
/// Gibt `null` zurück, wenn keine Felder übrig bleiben.
String? mergeCustomFields(
  Map<String, String> stored,
  Map<String, String> edited,
) {
  final merged = Map<String, String>.from(stored);
  edited.forEach((key, value) {
    if (value.isEmpty) {
      merged.remove(key);
    } else {
      merged[key] = value;
    }
  });
  merged.removeWhere((_, v) => v.isEmpty);
  if (merged.isEmpty) return null;
  return json.encode(merged);
}
