import 'package:flutter/material.dart';
import 'document_design.dart';

class ModernSidebarDesign extends DocumentDesign {
  const ModernSidebarDesign() : super(
    id: 'modern',
    name: 'Kreativ (Zweispaltig)',
    fontFamily: 'Segoe UI',
    baseFontSize: 11,
    baseLineHeight: 1.5,
  );

  @override
  Widget buildCoverLetterHeader(BuildContext context, CoverLetterDesignContext dc) {
    final primaryColor = dc.accentColor == Colors.transparent ? const Color(0xFF2C3E50) : dc.accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: primaryColor, width: 4)),
            color: primaryColor.withValues(alpha: 0.05),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dc.userNameCtrl.text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
              const SizedBox(height: 4),
              Text(
                '${dc.userAddressCtrl.text}  •  ${dc.userPhoneCtrl.text}  •  ${dc.userEmailCtrl.text}',
                style: TextStyle(fontSize: 10, color: dc.textColor.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dc.companyNameCtrl.text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: dc.textColor)),
                  if (dc.contactNameCtrl.text.isNotEmpty) Text(dc.contactNameCtrl.text, style: TextStyle(fontSize: 11, color: dc.textColor)),
                  Text(dc.companyAddressCtrl.text, style: TextStyle(fontSize: 11, color: dc.textColor)),
                ],
              ),
            ),
            Text(dc.dateCtrl.text, style: TextStyle(fontSize: 11, color: dc.textColor)),
          ],
        ),
      ],
    );
  }

  @override
  Widget buildCoverLetterFooter(BuildContext context, CoverLetterDesignContext dc) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildCurriculumVitae(BuildContext context, Color accentColor, CvData cvData) {
    final primaryColor = accentColor == Colors.transparent ? const Color(0xFF2C3E50) : accentColor;
    final isLight = primaryColor.computeLuminance() > 0.5;
    final sidebarTextColor = isLight ? Colors.black87 : Colors.white;
    final sidebarTextDim = isLight ? Colors.black54 : Colors.white70;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Sidebar
        Container(
          width: 220, // A bit narrower for elegant proportions
          color: primaryColor,
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: cvData.pageMargins.top,
            bottom: cvData.pageMargins.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cvData.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: sidebarTextColor, height: 1.1)),
              const SizedBox(height: 6),
              Text(cvData.title, style: TextStyle(fontSize: 10, color: sidebarTextDim, fontWeight: FontWeight.w500)),
              const SizedBox(height: 32),
              
              _buildSidebarTitle('KONTAKT', sidebarTextColor),
              _buildSidebarContactItem(Icons.email, cvData.email, sidebarTextDim),
              _buildSidebarContactItem(Icons.phone, cvData.phone, sidebarTextDim),
              _buildSidebarContactItem(Icons.location_on, cvData.address, sidebarTextDim),
              if (cvData.birthdate.isNotEmpty)
                _buildSidebarContactItem(Icons.cake, '${cvData.birthdate} in ${cvData.birthplace}', sidebarTextDim),
              if (cvData.maritalStatus.isNotEmpty)
                _buildSidebarContactItem(Icons.people, cvData.maritalStatus, sidebarTextDim),
              
              const SizedBox(height: 32),
              
              if (cvData.skills.isNotEmpty) ...[
                _buildSidebarTitle('FÄHIGKEITEN', sidebarTextColor),
                ...cvData.skills.map<Widget>((s) => _buildSidebarTag(s.name.toString(), sidebarTextColor, primaryColor)),
                const SizedBox(height: 32),
              ],

              if (cvData.languages.isNotEmpty) ...[
                _buildSidebarTitle('SPRACHEN', sidebarTextColor),
                ...cvData.languages.map<Widget>((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l.name.toString(), style: TextStyle(fontSize: 9, color: sidebarTextColor)),
                      Text(l.level.toString(), style: TextStyle(fontSize: 9, color: sidebarTextDim, fontStyle: FontStyle.italic)),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        
        // Right Content
        Expanded(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 32,
              right: cvData.pageMargins.right,
              top: cvData.pageMargins.top,
              bottom: cvData.pageMargins.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cvData.introText.isNotEmpty) ...[
                  Text('PROFIL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                  const SizedBox(height: 8),
                  Text(cvData.introText, style: TextStyle(fontSize: 10, height: 1.5, color: cvData.textColor)),
                  const SizedBox(height: 24),
                ],
                if (cvData.experiences.isNotEmpty)
                  _buildTimelineSection('BERUFSERFAHRUNG', cvData.experiences, primaryColor, cvData.textColor),
                if (cvData.educations.isNotEmpty)
                  _buildTimelineSection('AUSBILDUNG', cvData.educations, primaryColor, cvData.textColor),
                ..._buildCustomSections(cvData.customItems, primaryColor, cvData.textColor),
              ],
            ),
          ),
        ),
      ],
    ));
  }
  
  Widget _buildSidebarTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Container(height: 1, width: 24, color: color.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildSidebarContactItem(IconData icon, String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 9, color: color))),
        ],
      ),
    );
  }
  
  Widget _buildSidebarTag(String text, Color textColor, Color bgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: textColor)),
    );
  }


  List<Widget> _buildCustomSections(List<dynamic> customItems, Color primaryColor, Color textColor) {
    if (customItems.isEmpty) return [];
    final Map<String, List<CvTimelineItem>> grouped = {};
    for (var item in customItems) {
      final sectionName = item.sectionName as String;
      if (!grouped.containsKey(sectionName)) grouped[sectionName] = [];
      grouped[sectionName]!.add(CvTimelineItem(
        dateRange: item.dateRange ?? '',
        title: item.title,
        subtitle: item.subtitle ?? '',
        description: item.description ?? '',
      ));
    }
    return grouped.entries.map((e) => _buildTimelineSection(e.key.toUpperCase(), e.value, primaryColor, textColor)).toList();
  }

  Widget _buildTimelineSection(String title, List<CvTimelineItem> items, Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 16),
          ...items.map((item) => _buildTimelineItem(item, primaryColor, textColor)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(CvTimelineItem item, Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(item.dateRange, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: primaryColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                if (item.subtitle.isNotEmpty) Text(item.subtitle, style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: textColor.withOpacity(0.8))),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.description, style: TextStyle(fontSize: 10, height: 1.4, color: textColor)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
