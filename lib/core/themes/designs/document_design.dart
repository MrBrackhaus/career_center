import 'dart:io';

import 'package:flutter/material.dart';

/// Hilfsklasse, um alle benötigten Text-Controller und Farben an das Design zu übergeben.
class CoverLetterDesignContext {
  final TextEditingController userNameCtrl;
  final TextEditingController userProfessionCtrl;
  final TextEditingController userEmailCtrl;
  final TextEditingController userPhoneCtrl;
  final TextEditingController userAddressCtrl;
  final TextEditingController companyNameCtrl;
  final TextEditingController contactNameCtrl;
  final TextEditingController companyAddressCtrl;
  final TextEditingController dateCtrl;
  final Color accentColor;
  final Color textColor;

  CoverLetterDesignContext({
    required this.userNameCtrl,
    required this.userProfessionCtrl,
    required this.userEmailCtrl,
    required this.userPhoneCtrl,
    required this.userAddressCtrl,
    required this.companyNameCtrl,
    required this.contactNameCtrl,
    required this.companyAddressCtrl,
    required this.dateCtrl,
    required this.accentColor,
    this.textColor = const Color(0xFF374151),
  });
}

class CvTimelineItem {
  final String dateRange;
  final String title;
  final String subtitle;
  final String description;

  const CvTimelineItem({
    required this.dateRange,
    required this.title,
    this.subtitle = '',
    this.description = '',
  });
}

class CvData {
  final String initials;
  final String name;
  final String title;
  final String introText;
  final String email;
  final String address;
  final String phone;
  final String maritalStatus;
  final String birthplace;
  final String birthdate;
  final String? profileImagePath;
  final List<CvTimelineItem> experiences;
  final List<CvTimelineItem> educations;
  final List<dynamic> skills;
  final List<dynamic> languages;
  final List<dynamic> customItems;
  final Color textColor;
  final EdgeInsets pageMargins;

  const CvData({
    this.initials = '',
    this.name = '',
    this.title = '',
    this.introText = '',
    this.email = '',
    this.address = '',
    this.phone = '',
    this.maritalStatus = '',
    this.birthplace = '',
    this.birthdate = '',
    this.profileImagePath,
    this.experiences = const [],
    this.educations = const [],
    this.skills = const [],
    this.languages = const [],
    this.customItems = const [],
    this.textColor = const Color(0xFF374151),
    this.pageMargins = const EdgeInsets.only(left: 94, top: 170, right: 32, bottom: 32),
  });
}

extension CvDataFormatting on CvData {
  /// Geburtsangabe für die Anzeige, z. B. "01.01.1990 in Berlin".
  /// Leere Teile werden weggelassen (kein hängendes " in ").
  String get birthLine {
    final date = birthdate.trim();
    final place = birthplace.trim();
    if (date.isNotEmpty && place.isNotEmpty) return '$date in $place';
    if (date.isNotEmpty) return date;
    if (place.isNotEmpty) return 'geboren in $place';
    return '';
  }

  /// Bild des Bewerbungsfotos oder null, wenn keines gesetzt/vorhanden ist.
  /// Prüft das Dateisystem nur einmal pro Aufruf.
  ImageProvider? get profileImage {
    final path = profileImagePath;
    if (path == null || path.isEmpty) return null;
    final file = File(path);
    return file.existsSync() ? FileImage(file) : null;
  }
}

/// Initialen (max. 2 Buchstaben) aus einem Namen, leer bei leerem Namen.
String initialsFromName(String name) => name
    .trim()
    .split(RegExp(r'\s+'))
    .where((e) => e.isNotEmpty)
    .map((e) => e[0].toUpperCase())
    .take(2)
    .join();

/// Abstrakte Basisklasse für alle Designs in der Bewerbungszentrale
abstract class DocumentDesign {
  final String id;
  final String name;
  final String fontFamily;
  final double baseFontSize;
  final double baseLineHeight;

  const DocumentDesign({
    required this.id,
    required this.name,
    required this.fontFamily,
    required this.baseFontSize,
    required this.baseLineHeight,
  });

  // --- ANSCHREIBEN ---
  Widget buildCoverLetterHeader(
    BuildContext context,
    CoverLetterDesignContext designContext,
  );
  Widget buildCoverLetterFooter(
    BuildContext context,
    CoverLetterDesignContext designContext,
  );

  // --- LEBENSLAUF ---
  Widget buildCurriculumVitae(
    BuildContext context,
    Color accentColor,
    CvData cvData,
  ) {
    return const Center(
      child: Text('Lebenslauf-Layout noch nicht implementiert'),
    );
  }

  // Hilfsmethode für einheitliche Textfelder im Header
  Widget buildEditableText(
    TextEditingController controller,
    double fontSize, {
    FontWeight? fontWeight,
    int? maxLines = 1,
    Color color = const Color(0xFF374151),
    TextAlign textAlign = TextAlign.left,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: maxLines,
    );
  }
}
