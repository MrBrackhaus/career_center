void main() {
  String title = 'Bewerbung als IT';
  title = title.replaceFirst(
    RegExp(r'^.*?[Bb]ewerbung\s+(als|auf|um|für|:|-)\s*', caseSensitive: false),
    '',
  );
  print("'" + title + "'");
}
