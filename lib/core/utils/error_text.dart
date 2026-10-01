import 'dart:async';
import 'dart:io';

/// Macht aus einer Exception eine für Nutzer lesbare Meldung: entfernt
/// technische Präfixe wie "Exception: " und übersetzt Netzwerkfehler.
String friendlyError(Object error) {
  if (error is SocketException || error is HandshakeException) {
    return 'Server nicht erreichbar. Bitte Internetverbindung bzw. '
        'Server-Adresse in den Einstellungen prüfen.';
  }
  if (error is TimeoutException) {
    return 'Zeitüberschreitung – der Server hat nicht rechtzeitig geantwortet.';
  }
  var text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('Connection refused') ||
      text.contains('ClientException')) {
    return 'Server nicht erreichbar. Bitte Internetverbindung bzw. '
        'Server-Adresse in den Einstellungen prüfen.';
  }
  final prefix = RegExp(r'^(?:[A-Za-z_]*(?:Exception|Error)\b:?\s*)+');
  text = text.replaceFirst(prefix, '');
  // Verschachtelte Präfixe wie "KI-Fehler: Exception: ..." bereinigen.
  text = text.replaceAll(RegExp(r'(?<=:\s)(?:Exception|Error):\s*'), '');
  return text.trim().isEmpty ? 'Unbekannter Fehler' : text.trim();
}
