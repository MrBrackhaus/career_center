import 'package:flutter/material.dart';

/// Liefert bis zu zwei Initialen eines Firmennamens (ohne Netzwerkzugriff).
String companyInitials(String company) {
  final words = company
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && RegExp(r'[A-Za-zÄÖÜäöü0-9]').hasMatch(w[0]))
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) return words.first[0].toUpperCase();
  return (words[0][0] + words[1][0]).toUpperCase();
}

/// Lokaler Avatar mit den Initialen der Firma. Bewusst ohne externe
/// Logo-Dienste, damit keine Firmendaten an Dritte übertragen werden.
class CompanyAvatar extends StatelessWidget {
  final String company;
  final double radius;

  const CompanyAvatar({super.key, required this.company, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: colorScheme.primaryContainer,
      radius: radius,
      child: Text(
        companyInitials(company),
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
