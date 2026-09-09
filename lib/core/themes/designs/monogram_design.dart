import 'dart:io';

import 'package:flutter/material.dart';

import 'document_design.dart';

class MonogramDesign extends DocumentDesign {
  const MonogramDesign()
    : super(
        id: 'monogram',
        name: 'Monogram',
        fontFamily: 'Segoe UI',
        baseFontSize: 12,
        baseLineHeight: 1.5,
      );

  @override
  Widget buildCoverLetterHeader(
    BuildContext context,
    CoverLetterDesignContext dc,
  ) {
    final name = dc.userNameCtrl.text.trim().isNotEmpty
        ? dc.userNameCtrl.text.trim()
        : 'Max Mustermann';
    final initials = name
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0].toUpperCase())
        .take(2)
        .join('');

    return Padding(
      padding: const EdgeInsets.only(left: 94, right: 75, top: 50, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: dc.accentColor, width: 3),
                    bottom: BorderSide(color: dc.accentColor, width: 3),
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 12,
                  bottom: 4,
                  right: 12,
                  top: 4,
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF374151),
                    letterSpacing: -2,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildEditableText(
                      dc.userNameCtrl,
                      32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                    const SizedBox(height: 4),
                    buildEditableText(
                      dc.userProfessionCtrl,
                      14,
                      color: const Color(0xFF4B5563),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'PERSÖNLICHE DATEN',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: dc.accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(height: 1, color: dc.accentColor),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'E-MAIL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    buildEditableText(
                      dc.userEmailCtrl,
                      12,
                      color: const Color(0xFF4B5563),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ANSCHRIFT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    buildEditableText(
                      dc.userAddressCtrl,
                      12,
                      color: const Color(0xFF4B5563),
                      maxLines: null,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TELEFON',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    buildEditableText(
                      dc.userPhoneCtrl,
                      12,
                      color: const Color(0xFF4B5563),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildEditableText(dc.companyNameCtrl, 12),
                    buildEditableText(dc.contactNameCtrl, 12),
                    buildEditableText(
                      dc.companyAddressCtrl,
                      12,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 150,
                child: buildEditableText(
                  dc.dateCtrl,
                  12,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget buildCoverLetterFooter(
    BuildContext context,
    CoverLetterDesignContext dc,
  ) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: dc.accentColor, width: 3)),
      ),
    );
  }

  @override
  Widget buildCurriculumVitae(
    BuildContext context,
    Color accentColor,
    CvData cvData,
  ) {
    // Falls die accentColor zu hell ist, definieren wir hier ein typisches dunkles Blau als Fallback
    final primaryColor = accentColor == Colors.transparent
        ? const Color(0xFF1E3A8A)
        : accentColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: MK, Name, Title, Picture
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: primaryColor, width: 4),
                    bottom: BorderSide(color: primaryColor, width: 4),
                  ),
                ),
                padding: const EdgeInsets.only(
                  left: 8,
                  bottom: 4,
                  right: 12,
                  top: 4,
                ),
                child: Text(
                  cvData.initials.isNotEmpty ? cvData.initials : 'MK',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF374151),
                    letterSpacing: -2,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cvData.name.isNotEmpty ? cvData.name : 'Max Mustermann',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cvData.title.isNotEmpty
                          ? cvData.title.toUpperCase()
                          : 'BERUFSBEZEICHNUNG',
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.0,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 90,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image:
                      cvData.profileImagePath != null &&
                          cvData.profileImagePath!.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(File(cvData.profileImagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    cvData.profileImagePath == null ||
                        cvData.profileImagePath!.isEmpty
                    ? const Center(
                        child: Icon(Icons.person, size: 50, color: Colors.grey),
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // INTRO TEXT
          Text(
            cvData.introText.isNotEmpty
                ? cvData.introText
                : 'Dein Kurzprofil oder Intro-Text erscheint hier...',
            style: const TextStyle(
              fontSize: 10,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // PERSÖNLICHE DATEN
          _buildSectionHeader('PERSÖNLICHE DATEN', primaryColor),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoBlock('E-MAIL:', cvData.email, primaryColor),
              ),
              Expanded(
                child: _buildInfoBlock(
                  'ANSCHRIFT:',
                  cvData.address,
                  primaryColor,
                ),
              ),
              Expanded(
                child: _buildInfoBlock('TELEFON:', cvData.phone, primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoBlock(
                  'FAMILIENSTAND:',
                  cvData.maritalStatus,
                  primaryColor,
                ),
              ),
              Expanded(
                child: _buildInfoBlock(
                  'GEBURTSORT:',
                  cvData.birthplace,
                  primaryColor,
                ),
              ),
              Expanded(
                child: _buildInfoBlock(
                  'GEBURTSDATUM:',
                  cvData.birthdate,
                  primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // BERUFLICHER WERDEGANG
          if (cvData.experiences.isNotEmpty) ...[
            _buildSectionHeader('BERUFLICHER WERDEGANG', primaryColor),
            const SizedBox(height: 16),
            for (int i = 0; i < cvData.experiences.length; i++)
              _buildTimelineItem(
                cvData.experiences[i].dateRange,
                cvData.experiences[i].title,
                cvData.experiences[i].subtitle,
                cvData.experiences[i].description,
                primaryColor,
                isLast:
                    i == cvData.experiences.length - 1 &&
                    cvData.educations.isEmpty,
              ),
          ],

          // AUSBILDUNG
          if (cvData.educations.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('AUSBILDUNG', primaryColor),
            const SizedBox(height: 16),
            for (int i = 0; i < cvData.educations.length; i++)
              _buildTimelineItem(
                cvData.educations[i].dateRange,
                cvData.educations[i].title,
                cvData.educations[i].subtitle,
                cvData.educations[i].description,
                primaryColor,
                isLast: i == cvData.educations.length - 1,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(height: 1, color: accentColor),
      ],
    );
  }

  Widget _buildInfoBlock(String label, String value, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : '-',
          style: const TextStyle(fontSize: 10, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String date,
    String title,
    String subtitle,
    String desc,
    Color accentColor, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              date,
              style: const TextStyle(fontSize: 10, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: accentColor, width: 2),
                  ),
                ),
                padding: EdgeInsets.only(left: 12, bottom: isLast ? 0 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                left: -3, // Centers an 8px box over a 2px border (-3 = (8-2)/2)
                top: 4,
                child: Container(width: 8, height: 8, color: accentColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
