import '../../data/database/app_database.dart';
import '../../data/database/daos/settings_dao.dart';
import 'package:intl/intl.dart';

class DocumentTemplateService {
  final SettingsDao _settingsDao;

  DocumentTemplateService(this._settingsDao);

  Future<String> generateHeader(Application? application, String language) async {
    final name = (await _settingsDao.getSettingByKey('userName'))?.value ?? 'Max Mustermann';
    final address = (await _settingsDao.getSettingByKey('userAddress'))?.value ?? 'Musterstrasse 1';
    final zip = (await _settingsDao.getSettingByKey('userZip'))?.value ?? '12345';
    final city = (await _settingsDao.getSettingByKey('userCity'))?.value ?? 'Musterstadt';
    final company = application?.company ?? 'Unternehmensname';
    final position = application?.position ?? 'Position';
    
    final now = DateTime.now();
    String formattedDate;
    String datePrefix;
    String subjectPrefix;
    String greeting;

    if (language == 'en') {
      formattedDate = DateFormat('MMMM d, yyyy').format(now);
      datePrefix = '$city, ';
      subjectPrefix = 'Application for ';
      greeting = 'Dear Hiring Manager,\n\n';
    } else if (language == 'fr') {
      formattedDate = DateFormat('dd/MM/yyyy').format(now); // Intl default if no locale loaded, fallback to basic
      datePrefix = '$city, le ';
      subjectPrefix = 'Candidature pour le poste de ';
      greeting = 'Madame, Monsieur,\n\n';
    } else if (language == 'es') {
      formattedDate = DateFormat('dd/MM/yyyy').format(now);
      datePrefix = '$city, a ';
      subjectPrefix = 'Candidatura para el puesto de ';
      greeting = 'Estimados señores,\n\n';
    } else {
      // Default to German
      formattedDate = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
      datePrefix = '$city, den ';
      subjectPrefix = 'Bewerbung als ';
      greeting = 'Sehr geehrte Damen und Herren,\n\n';
    }

    return "$name * $address * $zip $city\n\n"
        "$company\n"
        "Personalabteilung\n\n\n\n"
        "$datePrefix$formattedDate\n\n"
        "$subjectPrefix$position\n\n"
        "$greeting";
  }
}
