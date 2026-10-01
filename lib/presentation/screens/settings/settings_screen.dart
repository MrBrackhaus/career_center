import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/signature_dialog.dart' as signature_dialog;
import '../changelog/changelog_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auto_updater_provider.dart';
import 'widgets/update_banner.dart';
import 'widgets/companion_token_card.dart';
import 'widgets/locked_database_banner.dart';
import 'widgets/recovery_key_dialogs.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/custom_columns_provider.dart';
import '../../providers/imap_provider.dart';
import '../../providers/streak_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/utils/csv_generator.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/db_key_service.dart';
import '../../../core/services/imap_service.dart';
import '../../../core/utils/spell_checker.dart';
import '../../../core/services/secure_settings_service.dart';

/// Gültiger Bereich für das wöchentliche Bewerbungsziel.
const _minWeeklyGoal = 1;
const _maxWeeklyGoal = 100;

/// Gibt das wöchentliche Bewerbungsziel zurück oder `null`, wenn die Eingabe
/// keine ganze Zahl zwischen 1 und 100 ist.
int? parseWeeklyGoal(String raw) {
  final value = raw.trim();
  if (!RegExp(r'^\d+$').hasMatch(value)) return null;
  final goal = int.tryParse(value);
  if (goal == null || goal < _minWeeklyGoal || goal > _maxWeeklyGoal) return null;
  return goal;
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _skillsController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _websiteController = TextEditingController();
  final _weeklyGoalController = TextEditingController();

  final _aiUrlController = TextEditingController();
  final _aiModelController = TextEditingController();
  final _apiKeyController = TextEditingController();

  String _selectedPreset = 'IT / Software';
  String _spellCheckLanguage = 'de';
  String _customColumns = '';
  final _customColumnsController = TextEditingController();

  // IMAP & SMTP
  final _imapServerController = TextEditingController();
  final _imapPortController = TextEditingController();
  final _smtpServerController = TextEditingController();
  final _smtpPortController = TextEditingController();
  final _imapEmailController = TextEditingController();
  final _imapPasswordController = TextEditingController();
  String _selectedMailProvider = 'Manuell';
  String _lastSyncDate = 'Nie';

  bool _isLoading = true;
  bool _jobcenterMode = false;
  bool _aiCvAssistantEnabled = false;
  bool _cloudAiEnabled = false;
  String _appVersion = '';

  final _dbKeyService = DbKeyService();

  final _presets = {
    'IT / Software': 'Tech-Stack, Portfolio-Link, Remote-Anteil',
    'Handwerk / Bau': 'Führerscheine, Maschinen, Montagebereitschaft',
    'Medizin / Pflege': 'Approbation, Schichtbereitschaft, Fachbereich',
    'Büro / Verwaltung': 'Softwarekenntnisse, Sprachen',
    'Individuell': '',
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Formatiert den gespeicherten ISO-Zeitstempel des letzten IMAP-Syncs.
  static String _formatLastSync(String? raw) {
    if (raw == null || raw.isEmpty) return 'Nie';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return 'Nie';
    return DateFormat('dd.MM.yyyy HH:mm').format(parsed.toLocal());
  }

  /// Zeitlimit für Secure-Storage-Zugriffe (z.B. gesperrter Schlüsselbund).
  static const _secureStorageTimeout = Duration(seconds: 5);

  Future<String> _loadAiApiKey(AppDatabase db) async {
    try {
      await SecureSettingsService.migrateLegacyAiApiKey(db).timeout(_secureStorageTimeout);
      return await SecureSettingsService.getAiApiKey().timeout(_secureStorageTimeout);
    } catch (e) {
      debugPrint('API-Key konnte nicht aus dem Secure Storage geladen werden: $e');
      return '';
    }
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    final dao = db.settingsDao;
    final nameSetting = await dao.getSettingByKey('userName');
    final addressSetting = await dao.getSettingByKey('userAddress');
    final emailSetting = await dao.getSettingByKey('userEmail');
    final phoneSetting = await dao.getSettingByKey('userPhone');
    final citySetting = await dao.getSettingByKey('userCity');
    final zipSetting = await dao.getSettingByKey('userZip');
    final birthSetting = await dao.getSettingByKey('userBirthdate');
    final skillsSetting = await dao.getSettingByKey('userSkills');
    final linkedinSetting = await dao.getSettingByKey('userLinkedin');
    final websiteSetting = await dao.getSettingByKey('userWebsite');
    final presetSetting = await dao.getSettingByKey('profilePreset');
    final colsSetting = await dao.getSettingByKey('customColumns');
    final jobcenterSetting = await dao.getSettingByKey('jobcenterMode');
    final spellLangSetting = await dao.getSettingByKey('spellCheckLanguage');
    final aiCvSetting = await dao.getSettingByKey('aiCvAssistantEnabled');
    final cloudAiSetting = await dao.getSettingByKey('cloudAiEnabled');
    final apiKey = await _loadAiApiKey(db);

    final imapProviderSetting = await dao.getSettingByKey('imapProvider');
    final imapServerSetting = await dao.getSettingByKey('imapServer');
    final imapPortSetting = await dao.getSettingByKey('imapPort');
    final smtpServerSetting = await dao.getSettingByKey('smtpServer');
    final smtpPortSetting = await dao.getSettingByKey('smtpPort');
    final lastSyncSetting = await dao.getSettingByKey('imapLastSync');
    final weeklyGoalSetting = await dao.getSettingByKey('weeklyApplicationGoal');
    
    _weeklyGoalController.text = weeklyGoalSetting?.value ?? '5';
    
    final aiUrlSetting = await dao.getSettingByKey('aiServerUrl');
    _aiUrlController.text = aiUrlSetting?.value ?? 'http://localhost:11434/api/generate';
    final aiModelSetting = await dao.getSettingByKey('aiModelName');
    _aiModelController.text = aiModelSetting?.value ?? 'llama3.2';
    
    _apiKeyController.text = apiKey;
    
    final imapEmailSetting = await dao.getSettingByKey('imapEmail');
    final packageInfo = await PackageInfo.fromPlatform();

    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
        _nameController.text = nameSetting?.value ?? '';
        _emailController.text = emailSetting?.value ?? '';
        _phoneController.text = phoneSetting?.value ?? '';
        _addressController.text = addressSetting?.value ?? '';
        _cityController.text = citySetting?.value ?? '';
        _zipController.text = zipSetting?.value ?? '';
        _birthdateController.text = birthSetting?.value ?? '';
        _skillsController.text = skillsSetting?.value ?? '';
        _linkedinController.text = linkedinSetting?.value ?? '';
        _websiteController.text = websiteSetting?.value ?? '';

        _selectedPreset = presetSetting?.value ?? 'IT / Software';
        _customColumns = colsSetting?.value ?? _presets[_selectedPreset]!;
        _customColumnsController.text = _customColumns;
        _jobcenterMode = jobcenterSetting?.value == 'true';
        _spellCheckLanguage = spellLangSetting?.value ?? 'de';
        _aiCvAssistantEnabled = aiCvSetting?.value == 'true';
        _cloudAiEnabled = cloudAiSetting?.value == 'true';

        _selectedMailProvider = imapProviderSetting?.value ?? 'Manuell';
        _imapServerController.text = imapServerSetting?.value ?? '';
        _imapPortController.text = imapPortSetting?.value ?? '993';
        _smtpServerController.text = smtpServerSetting?.value ?? '';
        _smtpPortController.text = smtpPortSetting?.value ?? '465';
        _imapEmailController.text = imapEmailSetting?.value ?? '';
        _imapPasswordController.text = '********'; 
        _lastSyncDate = _formatLastSync(lastSyncSetting?.value);

        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final weeklyGoal = parseWeeklyGoal(_weeklyGoalController.text);
    if (weeklyGoal == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Das wöchentliche Bewerbungsziel muss eine Zahl zwischen $_minWeeklyGoal und $_maxWeeklyGoal sein. Einstellungen wurden nicht gespeichert.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final dao = ref.read(databaseProvider).settingsDao;
    await dao.insertOrUpdateSetting(Setting(key: 'userName', value: _nameController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userEmail', value: _emailController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userPhone', value: _phoneController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userAddress', value: _addressController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userCity', value: _cityController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userZip', value: _zipController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userBirthdate', value: _birthdateController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userSkills', value: _skillsController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userLinkedin', value: _linkedinController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userWebsite', value: _websiteController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'weeklyApplicationGoal', value: weeklyGoal.toString()));
    await dao.insertOrUpdateSetting(Setting(key: 'aiServerUrl', value: _aiUrlController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'aiModelName', value: _aiModelController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'aiCvAssistantEnabled', value: _aiCvAssistantEnabled.toString()));
    await dao.insertOrUpdateSetting(Setting(key: 'cloudAiEnabled', value: _cloudAiEnabled.toString()));
    await dao.insertOrUpdateSetting(Setting(key: 'profilePreset', value: _selectedPreset));
    await dao.insertOrUpdateSetting(Setting(key: 'customColumns', value: _customColumnsController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'imapProvider', value: _selectedMailProvider));
    await dao.insertOrUpdateSetting(Setting(key: 'imapServer', value: _imapServerController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'imapPort', value: _imapPortController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'smtpServer', value: _smtpServerController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'smtpPort', value: _smtpPortController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'imapEmail', value: _imapEmailController.text));

    String? apiKeyError;
    try {
      await SecureSettingsService.setAiApiKey(_apiKeyController.text.trim()).timeout(_secureStorageTimeout);
    } catch (e) {
      apiKeyError = e.toString();
    }

    if (_imapPasswordController.text != '********' && _imapPasswordController.text.isNotEmpty) {
      await ImapService.savePassword(_imapPasswordController.text);
      await dao.insertOrUpdateSetting(const Setting(key: 'imapPassword', value: 'SECURE_STORAGE'));
    }

    ref.invalidate(customColumnsProvider);
    ref.invalidate(weeklyGoalProvider);

    if (mounted) {
      if (apiKeyError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Einstellungen gespeichert, aber der API-Key konnte nicht sicher gespeichert werden: $apiKeyError'), backgroundColor: Colors.orange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Einstellungen gespeichert'), backgroundColor: Colors.green),
        );
      }
    }
  }

  Future<void> _exportBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'career_center.sqlite'));

      if (!await dbFile.exists()) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keine Datenbankdatei gefunden.')));
        return;
      }

      final saveLocation = await getSaveLocation(
        acceptedTypeGroups: [const XTypeGroup(label: 'SQLite Database', extensions: ['sqlite', 'db'])],
        suggestedName: 'career_center_backup.sqlite',
      );

      if (saveLocation == null) return;
      final target = File(saveLocation.path);
      if (p.equals(p.absolute(target.path), p.absolute(dbFile.path))) {
        throw Exception('Das Backup kann nicht über die laufende Datenbank gespeichert werden.');
      }
      // VACUUM INTO und File.copy schlagen fehl bzw. überschreiben – der Nutzer
      // hat das Überschreiben im Speichern-Dialog bereits bestätigt.
      if (await target.exists()) {
        await target.delete();
      }

      // Konsistente Kopie der geöffneten Datenbank (inkl. WAL-Inhalt) erzeugen.
      // Fallback: Rohkopie der Datei, falls VACUUM INTO nicht unterstützt wird.
      try {
        final escapedPath = target.path.replaceAll("'", "''");
        await ref.read(databaseProvider).customStatement("VACUUM INTO '$escapedPath'");
      } catch (e) {
        debugPrint('VACUUM INTO fehlgeschlagen, kopiere Datei direkt: $e');
        if (await target.exists()) {
          await target.delete();
        }
        await dbFile.copy(target.path);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Backup erfolgreich gespeichert! Bewahre deinen Wiederherstellungsschlüssel sicher auf – '
                'ohne ihn lässt sich das Backup auf einem anderen PC oder nach einer Neuinstallation nicht öffnen '
                '(Export & Backup → Wiederherstellungsschlüssel anzeigen).'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 8),
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red));
    }
  }

  Future<String?> _readDbKey() async {
    try {
      return await _dbKeyService.readKey().timeout(_secureStorageTimeout);
    } catch (e) {
      debugPrint('Datenbankschlüssel konnte nicht gelesen werden: $e');
      return null;
    }
  }

  Future<void> _showRecoveryKey() async {
    if (!await confirmShowRecoveryKey(context)) return;
    final key = await _readDbKey();
    if (!mounted) return;
    if (key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Der Wiederherstellungsschlüssel konnte nicht gelesen werden.'), backgroundColor: Colors.red),
      );
      return;
    }
    await showRecoveryKeyDialog(context, key);
  }

  // Die Schlüsselableitung von SQLCipher dauert spürbar – daher im Isolate.
  // Statische Helfer, damit die Closures keinen Widget-State einfangen.
  static Future<BackupKeyStatus> _checkBackupInIsolate(String path, String? key) =>
      Isolate.run(() => DbKeyService.checkBackup(File(path), key));

  static Future<bool> _opensWithKeyInIsolate(String path, String key) =>
      Isolate.run(() => DbKeyService.opensWithKey(File(path), key));

  /// Maximale Größe einer importierten Datenbank (Plausibilitätsprüfung).
  static const _maxBackupBytes = 2 * 1024 * 1024 * 1024;

  /// Prüft, ob [file] plausibel eine SQLite- bzw. SQLCipher-Datenbank ist.
  /// Gibt eine Fehlermeldung zurück oder `null`, wenn die Datei gültig ist.
  static Future<String?> _validateBackupFile(File file) async {
    if (!await file.exists()) {
      return 'Die ausgewählte Datei existiert nicht.';
    }
    final length = await file.length();
    if (length == 0) {
      return 'Die ausgewählte Datei ist leer.';
    }
    if (length > _maxBackupBytes) {
      return 'Die ausgewählte Datei ist zu groß für ein Backup.';
    }
    // SQLite-/SQLCipher-Dateien bestehen aus ganzen Seiten (mind. 512 Byte,
    // immer eine Zweierpotenz) – die Dateigröße ist daher ein Vielfaches von 512.
    if (length < 512 || length % 512 != 0) {
      return 'Die ausgewählte Datei ist keine gültige Datenbank-Datei.';
    }
    // Unverschlüsselte SQLite-Dateien beginnen mit "SQLite format 3\0".
    // SQLCipher-Dateien sind vollständig verschlüsselt (zufälliger Header)
    // und lassen sich ohne Schlüssel nicht weiter prüfen.
    final raf = await file.open();
    try {
      final header = await raf.read(16);
      final isPlainSqlite = String.fromCharCodes(header) == 'SQLite format 3\u0000';
      if (!isPlainSqlite && header.every((b) => b == 0)) {
        return 'Die ausgewählte Datei ist keine gültige Datenbank-Datei.';
      }
    } finally {
      await raf.close();
    }
    return null;
  }

  Future<void> _importBackup() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.settingsExportRestart), duration: const Duration(seconds: 4)),
      );
    }
    var dbClosed = false;
    try {
      final file = await openFile(acceptedTypeGroups: [const XTypeGroup(label: 'SQLite Database', extensions: ['sqlite', 'db'])]);
      if (file == null) return;

      final source = File(file.path);
      final validationError = await _validateBackupFile(source);
      if (validationError != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validationError), backgroundColor: Colors.red));
        return;
      }

      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'career_center.sqlite'));
      if (p.equals(p.absolute(source.path), p.absolute(dbFile.path))) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diese Datei ist bereits die aktive Datenbank.'), backgroundColor: Colors.red));
        return;
      }

      // Prüfen, ob das Backup mit dem aktuellen Schlüssel lesbar ist.
      // Unverschlüsselte Backups werden beim nächsten Start verschlüsselt.
      final currentKey = await _readDbKey();
      final status = await _checkBackupInIsolate(source.path, currentKey);
      String? backupKey;
      if (status == BackupKeyStatus.otherKey) {
        if (!mounted) return;
        final entered = await askForBackupRecoveryKey(context);
        if (entered == null) return;
        final opens = await _opensWithKeyInIsolate(source.path, entered);
        if (!opens) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Das Backup lässt sich mit diesem Wiederherstellungsschlüssel nicht öffnen. Es wurde nichts importiert.'),
              backgroundColor: Colors.red,
            ));
          }
          return;
        }
        backupKey = entered;
      }

      // Ab hier keine Datenbankzugriffe mehr – die App muss danach beendet werden.
      await ref.read(databaseProvider).close();
      dbClosed = true;

      // Veraltete Journal-/WAL-Dateien der alten Datenbank entfernen, sonst
      // würden sie beim nächsten Start auf die neue Datei angewendet.
      for (final suffix in ['-journal', '-wal', '-shm']) {
        final sidecar = File('${dbFile.path}$suffix');
        if (await sidecar.exists()) {
          await sidecar.delete();
        }
      }

      // Erst vollständig neben die Datenbank kopieren, dann ggf. den
      // Schlüssel des Backups speichern und zuletzt die Datei austauschen –
      // so passen Datenbank und Schlüssel auch bei Fehlern zusammen.
      final tempFile = File('${dbFile.path}.import-tmp');
      if (await tempFile.exists()) await tempFile.delete();
      await source.copy(tempFile.path);
      if (backupKey != null) {
        try {
          await _dbKeyService.writeKey(backupKey).timeout(_secureStorageTimeout);
        } catch (e) {
          await tempFile.delete();
          throw Exception('Der Wiederherstellungsschlüssel konnte nicht gespeichert werden ($e). Die bisherige Datenbank bleibt unverändert.');
        }
      }
      try {
        await tempFile.rename(dbFile.path);
      } catch (e) {
        if (backupKey != null && currentKey != null) {
          await _dbKeyService.writeKey(currentKey).timeout(_secureStorageTimeout);
        }
        if (await tempFile.exists()) await tempFile.delete();
        rethrow;
      }

      if (mounted) {
        await _showQuitDialog(
          title: '✅ Import erfolgreich',
          message: backupKey != null
              ? 'Die Datenbank wurde ersetzt und der Wiederherstellungsschlüssel des Backups ist jetzt der aktive Schlüssel. Bitte schließe die App komplett und starte sie neu, um die Änderungen zu laden.'
              : 'Die Datenbank wurde ersetzt. Bitte schließe die App komplett und starte sie neu, um die Änderungen zu laden.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (dbClosed) {
        // Die Datenbank ist bereits geschlossen – die App kann nicht sicher
        // weiterlaufen, daher ebenfalls zum Beenden zwingen.
        await _showQuitDialog(
          title: '❌ Import fehlgeschlagen',
          message: 'Beim Ersetzen der Datenbank ist ein Fehler aufgetreten:\n$e\n\nBitte beende die App und starte sie neu.',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showQuitDialog({required String title, required String message}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => exit(0), child: Text(AppLocalizations.of(ctx)!.settingsAppQuit)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: Column(
        children: [
          const UpdateBanner(),
          const LockedDatabaseBanner(),
          Expanded(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profil & Kontakt')),
                    NavigationRailDestination(icon: Icon(Icons.psychology), label: Text('KI & Automatisierung')),
                    NavigationRailDestination(icon: Icon(Icons.email), label: Text('E-Mail Scanner')),
                    NavigationRailDestination(icon: Icon(Icons.bar_chart), label: Text('Bewerbungs-Setup')),
                    NavigationRailDestination(icon: Icon(Icons.save), label: Text('Export & Backup')),
                    NavigationRailDestination(icon: Icon(Icons.info), label: Text('Über die App')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: _buildSelectedContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildProfileContact();
      case 1:
        return _buildAiAutomation();
      case 2:
        return _buildEmailScanner();
      case 3:
        return _buildApplicationSetup();
      case 4:
        return _buildExportBackup();
      case 5:
        return _buildAboutApp();
      default:
        return const SizedBox();
    }
  }

  Widget _buildProfileContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profil & Kontakt', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()))),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: _birthdateController, decoration: const InputDecoration(labelText: 'Geburtsdatum (TT.MM.JJJJ)', border: OutlineInputBorder()))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'E-Mail', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress)),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()), keyboardType: TextInputType.phone)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 2, child: TextField(controller: _addressController, decoration: const InputDecoration(labelText: 'Adresse', border: OutlineInputBorder()))),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: _zipController, decoration: const InputDecoration(labelText: 'PLZ', border: OutlineInputBorder()))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'Stadt', border: OutlineInputBorder()))),
          ],
        ),
        const SizedBox(height: 16),
        TextField(controller: _skillsController, decoration: const InputDecoration(labelText: 'Skills / Kenntnisse (kommagetrennt)', border: OutlineInputBorder()), maxLines: 2),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TextField(controller: _linkedinController, decoration: const InputDecoration(labelText: 'LinkedIn / Xing URL', border: OutlineInputBorder()))),
            const SizedBox(width: 16),
            Expanded(child: TextField(controller: _websiteController, decoration: const InputDecoration(labelText: 'Website / Portfolio', border: OutlineInputBorder()))),
          ],
        ),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: _saveSettings, child: const Text('Speichern'))),
      ],
    );
  }

  Widget _buildAiAutomation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('KI & Automatisierung', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        
        // LOKALE KI SECTION
        Text('Lokale KI (z.B. lokaler Jetson / Ollama)', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 8),
        const Text('Die KI läuft komplett offline auf deiner eigenen Hardware. 100% Datenschutz.'),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Lokale KI-Verarbeitung (Datenschutz)'),
          subtitle: const Text('Erlaubt der App, deine E-Mails und Daten lokal auf deinem eigenen Rechner auszuwerten. Absolut sicher und privat.'),
          value: _aiCvAssistantEnabled, // Wir nutzen diesen Key weiterhin für die lokale KI Freigabe
          onChanged: (val) {
            setState(() => _aiCvAssistantEnabled = val);
            _saveSettings();
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _aiUrlController,
          decoration: const InputDecoration(labelText: 'Lokale Server URL', hintText: 'http://localhost:11434', border: OutlineInputBorder(), prefixIcon: Icon(Icons.computer)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _aiModelController,
          decoration: const InputDecoration(labelText: 'Lokales KI-Modell', hintText: 'llama3.1', border: OutlineInputBorder(), prefixIcon: Icon(Icons.memory)),
        ),
        
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),

        // CLOUD KI SECTION
        Text('Cloud KI (z.B. OpenAI / Anthropic)', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        const Text('Nutze eine externe, kostenpflichtige API, falls du keine Hardware für eine lokale KI besitzt.'),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Cloud-API Zugriff erlauben (DSGVO)'),
          subtitle: const Text('Achtung: Erlaubt der App, deine E-Mails und Daten an externe Cloud-Server (wie OpenAI) zu senden. Nur aktivieren, wenn du die externe API nutzt!'),
          value: _cloudAiEnabled,
          onChanged: (val) async {
            if (val == true) {
              final accepted = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('⚠️ WICHTIGER DATENSCHUTZ-HINWEIS', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  content: const Text(
                    'Wenn du diese Option aktivierst, werden ALLE abgerufenen E-Mails komplett UNGEFILTERT an die externe Cloud-LLM (z.B. OpenAI) gesendet!\n\n'
                    'Das bedeutet: Jede einzelne deiner E-Mails liegt dann im Klartext auf den Servern des LLM-Herstellers und wird von diesem verarbeitet.\n\n'
                    'DIESE OPTION WIRD AUSDRÜCKLICH NICHT EMPFOHLEN UND IST REIN EXPERIMENTELL!\n\n'
                    'Du handelst vollständig auf eigene Gefahr. Akzeptierst du dieses Risiko?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Abbrechen'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Ich verstehe die Gefahr und akzeptiere'),
                    ),
                  ],
                ),
              );
              
              if (accepted == true) {
                setState(() => _cloudAiEnabled = true);
                _saveSettings();
              }
            } else {
              setState(() => _cloudAiEnabled = false);
              _saveSettings();
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _apiKeyController,
          decoration: const InputDecoration(labelText: 'API-Key', hintText: 'sk-...', border: OutlineInputBorder(), prefixIcon: Icon(Icons.vpn_key)),
          obscureText: true,
        ),
        
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),

        // BROWSER-ERWEITERUNG / COMPANION
        Text('Browser-Erweiterung & MCP', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        const CompanionTokenCard(),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),

        // SONSTIGES
        Text('Sonstiges', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Sprache der Rechtschreibprüfung', border: OutlineInputBorder(), prefixIcon: Icon(Icons.spellcheck)),
          initialValue: _spellCheckLanguage,
          items: SpellChecker.availableLanguages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
          onChanged: (val) async {
            if (val == null) return;
            setState(() => _spellCheckLanguage = val);
            await ref.read(databaseProvider).settingsDao.insertOrUpdateSetting(Setting(key: 'spellCheckLanguage', value: val));
            SpellChecker.loadDictionary(language: val);
          },
        ),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: _saveSettings, child: const Text('Speichern'))),
      ],
    );
  }

  Widget _buildEmailScanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-Mail Scanner', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _selectedMailProvider,
          decoration: const InputDecoration(labelText: 'E-Mail Anbieter', border: OutlineInputBorder()),
          items: ['Manuell', 'Gmail', 'GMX', 'Web.de', 'Outlook', 'iCloud'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedMailProvider = val;
                if (val == 'Gmail') {
                  _imapServerController.text = 'imap.gmail.com'; _imapPortController.text = '993'; _smtpServerController.text = 'smtp.gmail.com'; _smtpPortController.text = '465';
                } else if (val == 'GMX') {
                  _imapServerController.text = 'imap.gmx.net'; _imapPortController.text = '993'; _smtpServerController.text = 'mail.gmx.net'; _smtpPortController.text = '465';
                } else if (val == 'Web.de') {
                  _imapServerController.text = 'imap.web.de'; _imapPortController.text = '993'; _smtpServerController.text = 'smtp.web.de'; _smtpPortController.text = '465';
                } else if (val == 'Outlook') {
                  _imapServerController.text = 'outlook.office365.com'; _imapPortController.text = '993'; _smtpServerController.text = 'smtp.office365.com'; _smtpPortController.text = '587';
                } else if (val == 'iCloud') {
                  _imapServerController.text = 'imap.mail.me.com'; _imapPortController.text = '993'; _smtpServerController.text = 'smtp.mail.me.com'; _smtpPortController.text = '587';
                }
              });
            }
          },
        ),
        if (_selectedMailProvider == 'Gmail' || _selectedMailProvider == 'iCloud')
          Container(
            margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.all(8), color: Colors.amber.withValues(alpha: 0.1),
            child: const Row(children: [Icon(Icons.warning_amber, color: Colors.amber, size: 20), SizedBox(width: 8), Expanded(child: Text('Wichtig: Ein App-Passwort wird benötigt!'))]),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 3, child: TextField(controller: _imapServerController, decoration: const InputDecoration(labelText: 'IMAP Server', border: OutlineInputBorder()), enabled: _selectedMailProvider == 'Manuell')),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: TextField(controller: _imapPortController, decoration: const InputDecoration(labelText: 'Port', border: OutlineInputBorder()), keyboardType: TextInputType.number, enabled: _selectedMailProvider == 'Manuell')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 3, child: TextField(controller: _smtpServerController, decoration: const InputDecoration(labelText: 'SMTP Server', border: OutlineInputBorder()), enabled: _selectedMailProvider == 'Manuell')),
            const SizedBox(width: 12),
            Expanded(flex: 1, child: TextField(controller: _smtpPortController, decoration: const InputDecoration(labelText: 'Port', border: OutlineInputBorder()), keyboardType: TextInputType.number, enabled: _selectedMailProvider == 'Manuell')),
          ],
        ),
        const SizedBox(height: 16),
        TextField(controller: _imapEmailController, decoration: const InputDecoration(labelText: 'E-Mail Adresse', border: OutlineInputBorder()), keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        TextField(controller: _imapPasswordController, decoration: const InputDecoration(labelText: 'Passwort / App-Passwort', border: OutlineInputBorder()), obscureText: true),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Letzter Sync-Zeitpunkt'),
          subtitle: Text(_lastSyncDate),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Letzten Sync-Zeitpunkt löschen',
            onPressed: () async {
              await ref.read(databaseProvider).settingsDao.insertOrUpdateSetting(const Setting(key: 'imapLastSync', value: ''));
              ref.invalidate(imapLastSyncProvider);
              setState(() => _lastSyncDate = 'Nie');
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync-Zeitpunkt gelöscht.')));
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                final server = _imapServerController.text;
                final port = int.tryParse(_imapPortController.text) ?? 993;
                final email = _imapEmailController.text;
                final pass = _imapPasswordController.text;
                if (server.isEmpty || email.isEmpty || pass.isEmpty) return;
                try {
                  String actualPass = pass == '********' ? await ImapService.getPassword() : pass;
                  final client = await ref.read(imapServiceProvider).connect(server, port, email, actualPass);
                  if (client != null) {
                    await client.disconnect();
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erfolgreich verbunden!'), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red));
                }
              },
              icon: const Icon(Icons.cable),
              label: const Text('Testen'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(onPressed: _saveSettings, child: const Text('Speichern')),
          ],
        ),
      ],
    );
  }

  Widget _buildApplicationSetup() {
    final themeState = ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bewerbungs-Setup', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: _selectedPreset,
          decoration: const InputDecoration(labelText: 'Berufsfeld / Preset', border: OutlineInputBorder()),
          items: _presets.keys.map((key) => DropdownMenuItem(value: key, child: Text(key))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedPreset = val;
                if (val != 'Individuell') _customColumnsController.text = _presets[val]!;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _customColumnsController,
          decoration: const InputDecoration(labelText: 'Eigene Spalten (kommagetrennt)', hintText: 'z.B. Portfolio-Link, Sprachen', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _weeklyGoalController,
          decoration: const InputDecoration(labelText: 'Wöchentliches Bewerbungsziel', helperText: 'Zahl zwischen 1 und 100', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Jobcenter Modus'),
          subtitle: const Text('Aktiviert zusätzliche Felder und Export-Optionen für die Agentur für Arbeit.'),
          value: _jobcenterMode,
          onChanged: (val) async {
            setState(() => _jobcenterMode = val);
            await ref.read(databaseProvider).settingsDao.insertOrUpdateSetting(Setting(key: 'jobcenterMode', value: val.toString()));
            ref.invalidate(jobcenterModeProvider);
          },
        ),
        const Divider(),
        const Text('Design & Personalisierung', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final locale = ref.watch(localeProvider);
            return DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'App Sprache', border: OutlineInputBorder(), prefixIcon: Icon(Icons.translate)),
              initialValue: locale?.languageCode ?? '',
              items: const [
                DropdownMenuItem(value: '', child: Text('Systemstandard')),
                DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val == null) return;
                if (val.isEmpty) {
                  ref.read(localeProvider.notifier).clearLocale();
                } else {
                  ref.read(localeProvider.notifier).setLocale(val);
                }
              },
            );
          },
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.brightness_6), title: const Text('Theme'),
          trailing: DropdownButton<ThemeMode>(
            value: themeState.themeMode,
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (mode) { if (mode != null) ref.read(themeProvider.notifier).setThemeMode(mode); },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.color_lens), title: const Text('Akzentfarbe'),
          trailing: Wrap(
            spacing: 8,
            children: [Colors.teal, Colors.blue, Colors.purple, Colors.orange, Colors.green, Colors.pink].map((color) {
              return InkWell(
                onTap: () => ref.read(themeProvider.notifier).setSeedColor(color),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: (themeState.preset == ThemePreset.standard && themeState.seedColor.toARGB32() == color.toARGB32()) ? Colors.white : Colors.transparent, width: 2)),
                ),
              );
            }).toList(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.auto_awesome), title: const Text('Design-Preset'),
          trailing: Wrap(
            spacing: 8,
            children: [
              FilterChip(label: const Text('Standard'), selected: themeState.preset == ThemePreset.standard, onSelected: (_) => ref.read(themeProvider.notifier).setPreset(ThemePreset.standard)),
              FilterChip(label: const Text('🖤 Obsidian'), selected: themeState.preset == ThemePreset.obsidian, selectedColor: const Color(0xFF45475A), labelStyle: TextStyle(color: themeState.preset == ThemePreset.obsidian ? const Color(0xFFCBA6F7) : null), onSelected: (_) { ref.read(themeProvider.notifier).setPreset(ThemePreset.obsidian); ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark); }),
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.draw), title: const Text('Unterschrift konfigurieren'), trailing: const Icon(Icons.chevron_right),
          onTap: () async => showDialog(context: context, builder: (context) => const signature_dialog.SignatureDialog()),
        ),
        const SizedBox(height: 24),
        Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: _saveSettings, child: const Text('Speichern'))),
      ],
    );
  }

  Widget _buildExportBackup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export & Backup', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf), title: const Text('Als PDF exportieren'),
          onTap: () async {
            final applications = await ref.read(applicationsRepositoryProvider).getAllApplications();
            await PdfGenerator.generateAndSharePdf(applications, ref.read(settingsRepositoryProvider));
          },
        ),
        ListTile(
          leading: const Icon(Icons.table_chart), title: const Text('Als CSV exportieren'),
          onTap: () async {
            final applications = await ref.read(applicationsRepositoryProvider).getAllApplications();
            await CsvGenerator.generateAndShareCsv(applications);
          },
        ),
        ListTile(leading: const Icon(Icons.backup), title: const Text('Backup erstellen'), onTap: _exportBackup),
        ListTile(leading: const Icon(Icons.restore), title: const Text('Backup wiederherstellen'), onTap: _importBackup),
        ListTile(
          leading: const Icon(Icons.key),
          title: const Text('Wiederherstellungsschlüssel anzeigen'),
          subtitle: const Text('Wird benötigt, um Backups auf einem anderen PC oder nach einer Neuinstallation wiederherzustellen.'),
          onTap: _showRecoveryKey,
        ),
      ],
    );
  }

  Widget _buildAboutApp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Über die App', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        ListTile(leading: const Icon(Icons.info_outline), title: const Text('Version'), trailing: Text(_appVersion.isNotEmpty ? _appVersion : 'Lade...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        ListTile(
          leading: const Icon(Icons.new_releases), title: const Text('Changelog ansehen'), trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogScreen())),
        ),
        Consumer(
          builder: (context, ref, child) {
            final updateState = ref.watch(autoUpdaterProvider);
            final isChecking = updateState.status == UpdaterStatus.checking;
            return ListTile(
              leading: const Icon(Icons.system_update_alt), title: const Text('Nach Updates suchen'),
              trailing: isChecking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.chevron_right),
              onTap: isChecking ? null : () async {
                await ref.read(autoUpdaterProvider.notifier).checkForUpdates(isManual: true);
                if (context.mounted) {
                  final status = ref.read(autoUpdaterProvider).status;
                  if (status == UpdaterStatus.upToDate) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Die App ist auf dem neuesten Stand.')));
                  } else if (status == UpdaterStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: ${ref.read(autoUpdaterProvider).errorMessage}')));
                  } else if (status == UpdaterStatus.available) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Neues Update verfügbar!')));
                  }
                }
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined), title: const Text('Open-Source-Lizenzen'), trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(context: context, applicationName: 'Bewerbungszentrale', applicationVersion: _appVersion.isNotEmpty ? _appVersion : 'Lade...', applicationLegalese: '© 2026 Alle Rechte vorbehalten.'),
        ),
      ],
    );
  }
}
