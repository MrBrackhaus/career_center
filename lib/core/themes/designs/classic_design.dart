import 'package:flutter/material.dart';
import 'document_design.dart';

class ClassicDesign extends DocumentDesign {
  const ClassicDesign() : super(
    id: 'classic',
    name: 'Klassisch',
    fontFamily: 'Times New Roman',
    baseFontSize: 12,
    baseLineHeight: 1.5,
  );

  @override
  Widget buildCoverLetterHeader(BuildContext context, CoverLetterDesignContext dc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(dc.userNameCtrl.text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        Text('${dc.userAddressCtrl.text} | ${dc.userPhoneCtrl.text} | ${dc.userEmailCtrl.text}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dc.companyNameCtrl.text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  if (dc.contactNameCtrl.text.isNotEmpty) Text(dc.contactNameCtrl.text, style: const TextStyle(fontSize: 12)),
                  Text(dc.companyAddressCtrl.text, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Text(dc.dateCtrl.text, style: const TextStyle(fontSize: 12)),
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
    final primaryColor = accentColor == Colors.transparent ? Colors.blueGrey : accentColor;
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(cvData.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(cvData.title, style: TextStyle(fontSize: 16, color: primaryColor)),
                const SizedBox(height: 16),
                Text('${cvData.address} | ${cvData.phone} | ${cvData.email}', style: const TextStyle(fontSize: 10, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (cvData.experiences.isNotEmpty)
            _buildTimelineSection('BERUFSERFAHRUNG', cvData.experiences, primaryColor),
          if (cvData.educations.isNotEmpty)
            _buildTimelineSection('AUSBILDUNG', cvData.educations, primaryColor),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(String title, List<CvTimelineItem> items, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.2)),
          const Divider(thickness: 1, height: 16),
          const SizedBox(height: 8),
          ...items.map((item) => _buildTimelineItem(item)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(CvTimelineItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(item.dateRange, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                if (item.subtitle.isNotEmpty) Text(item.subtitle, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.description, style: const TextStyle(fontSize: 11, height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
