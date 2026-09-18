import 'package:flutter/material.dart';
import 'document_design.dart';

class ClassicDesign extends DocumentDesign {
  const ClassicDesign() : super(
    id: 'classic',
    name: 'Klassisch (Corporate)',
    fontFamily: 'Georgia',
    baseFontSize: 11,
    baseLineHeight: 1.5,
  );

  @override
  Widget buildCoverLetterHeader(BuildContext context, CoverLetterDesignContext dc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Text(dc.userNameCtrl.text.toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: dc.textColor)),
              const SizedBox(height: 4),
              Text(
                '${dc.userAddressCtrl.text}  •  ${dc.userPhoneCtrl.text}  •  ${dc.userEmailCtrl.text}',
                style: TextStyle(fontSize: 9, color: dc.textColor.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Divider(color: dc.textColor.withValues(alpha: 0.3), thickness: 1),
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
    return Container();
  }

  @override
  Widget buildCurriculumVitae(BuildContext context, Color accentColor, CvData cvData) {
    return Padding(
      padding: cvData.pageMargins,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(cvData.name.toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: cvData.textColor)),
                const SizedBox(height: 4),
                Text(cvData.title, style: TextStyle(fontSize: 12, color: cvData.textColor.withValues(alpha: 0.8), letterSpacing: 1.0)),
                const SizedBox(height: 8),
                Text('${cvData.address}  •  ${cvData.phone}  •  ${cvData.email}', style: TextStyle(fontSize: 9, color: cvData.textColor.withValues(alpha: 0.8))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: cvData.textColor.withValues(alpha: 0.3), thickness: 1),
          const SizedBox(height: 24),
          
          if (cvData.introText.isNotEmpty) ...[
            Text(cvData.introText, style: TextStyle(fontSize: 10, height: 1.5, color: cvData.textColor)),
            const SizedBox(height: 24),
          ],
          
          if (cvData.experiences.isNotEmpty)
            _buildTimelineSection('Berufserfahrung', cvData.experiences, cvData.textColor),
            
          if (cvData.educations.isNotEmpty)
            _buildTimelineSection('Ausbildung', cvData.educations, cvData.textColor),
          ..._buildCustomSections(cvData.customItems, cvData.textColor),
            
          if (cvData.skills.isNotEmpty || cvData.languages.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cvData.skills.isNotEmpty)
                  Expanded(child: _buildListSection('Fähigkeiten', cvData.skills.map<String>((s) => s.name.toString()).toList(), cvData.textColor)),
                if (cvData.skills.isNotEmpty && cvData.languages.isNotEmpty)
                  const SizedBox(width: 32),
                if (cvData.languages.isNotEmpty)
                  Expanded(child: _buildListSection('Sprachen', cvData.languages.map<String>((l) => '${l.name} (${l.level})').toList(), cvData.textColor)),
              ],
            ),
        ],
      ),
    );
  }


  List<Widget> _buildCustomSections(List<dynamic> customItems, Color textColor) {
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
    return grouped.entries.map((e) => _buildTimelineSection(e.key, e.value, textColor)).toList();
  }

  Widget _buildTimelineSection(String title, List<CvTimelineItem> items, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Divider(color: textColor.withOpacity(0.2), thickness: 0.5),
          const SizedBox(height: 12),
          ...items.map((item) => _buildTimelineItem(item, textColor)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(CvTimelineItem item, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(item.dateRange, style: TextStyle(fontSize: 10, color: textColor.withValues(alpha: 0.8))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                if (item.subtitle.isNotEmpty) Text(item.subtitle, style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: textColor.withOpacity(0.9))),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(item.description, style: TextStyle(fontSize: 10, height: 1.5, color: textColor)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListSection(String title, List<String> items, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Divider(color: textColor.withOpacity(0.2), thickness: 0.5),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(fontSize: 10, color: textColor)),
              Expanded(child: Text(item, style: TextStyle(fontSize: 10, color: textColor))),
            ],
          ),
        )),
      ],
    );
  }
}
