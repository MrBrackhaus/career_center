import 'package:flutter/material.dart';
import 'document_design.dart';

class ModernSidebarDesign extends DocumentDesign {
  const ModernSidebarDesign() : super(
    id: 'modern',
    name: 'Modern',
    fontFamily: 'Segoe UI',
    baseFontSize: 14,
    baseLineHeight: 1.6,
  );

  @override
  Widget buildCoverLetterHeader(BuildContext context, CoverLetterDesignContext dc) {
    return const SizedBox.shrink(); // Cover letter handles its own layout usually
  }

  @override
  Widget buildCoverLetterFooter(BuildContext context, CoverLetterDesignContext dc) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildCurriculumVitae(BuildContext context, Color accentColor, CvData cvData) {
    final primaryColor = accentColor == Colors.transparent ? const Color(0xFF2C3E50) : accentColor;
    
    // We split into left sidebar (35%) and right content (65%)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Sidebar
        Container(
          width: 260,
          color: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cvData.profileImagePath != null) ...[
                // Would render image here if we had bytes/path loading handled in UI
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white24,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 24),
              ],
              Flexible(child: Text(cvData.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1))),
              const SizedBox(height: 8),
              Text(cvData.title, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 32),
              
              _buildSidebarContactItem(Icons.email, cvData.email),
              _buildSidebarContactItem(Icons.phone, cvData.phone),
              _buildSidebarContactItem(Icons.location_on, cvData.address),
              _buildSidebarContactItem(Icons.cake, '${cvData.birthdate} in ${cvData.birthplace}'),
              
              const SizedBox(height: 32),
              
              // We could filter sections here and put "text" or "tags" into the sidebar, 
              // but for now we put all sections in the main body.
            ],
          ),
        ),
        
        // Right Content
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cvData.experiences.isNotEmpty)
                  _buildTimelineSection('BERUFSERFAHRUNG', cvData.experiences, primaryColor),
                if (cvData.educations.isNotEmpty)
                  _buildTimelineSection('AUSBILDUNG', cvData.educations, primaryColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildSidebarContactItem(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 10, color: Colors.white))),
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
          Row(
            children: [
              Container(width: 4, height: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _buildTimelineItem(item, primaryColor)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(CvTimelineItem item, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(item.dateRange, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: primaryColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                if (item.subtitle.isNotEmpty) Text(item.subtitle, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black54)),
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
