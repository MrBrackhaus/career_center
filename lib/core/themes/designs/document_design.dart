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
  });
}

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
    Color color = Colors.black87,
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
