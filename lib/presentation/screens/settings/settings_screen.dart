/*
 * JobTracker
 * Copyright (C) 2026 
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import 'dart:io';
import 'package:flutter/material.dart';
import '../changelog/changelog_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/applications_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/custom_columns_provider.dart';
import '../../providers/imap_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/utils/csv_generator.dart';
import '../../../data/database/app_database.dart';
import '../../../core/services/imap_service.dart';
import '../../../core/utils/spell_checker.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
  String _selectedPreset = 'IT / Software';
  String _spellCheckLanguage = 'en';
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

  bool _isLoading = true;
  bool _jobcenterMode = false;

  final _presets = {
    'IT / Software': 'Tech-Stack, Portfolio-Link, Remote-Anteil',
    'Handwerk / Bau': 'Führerscheine, Maschinen, Montagebereitschaft',
    'Medizin / Pflege': 'Approbation, Schichtbereitschaft, Fachbereich',
    'Büro / Verwaltung': 'Softwarekenntnisse, Sprachen',
    'Individuell': ''
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dao = ref.read(databaseProvider).settingsDao;
    final nameSetting     = await dao.getSettingByKey('userName');
    final addressSetting  = await dao.getSettingByKey('userAddress');
    final emailSetting    = await dao.getSettingByKey('userEmail');
    final phoneSetting    = await dao.getSettingByKey('userPhone');
    final citySetting     = await dao.getSettingByKey('userCity');
    final zipSetting      = await dao.getSettingByKey('userZip');
    final birthSetting    = await dao.getSettingByKey('userBirthdate');
    final skillsSetting   = await dao.getSettingByKey('userSkills');
    final linkedinSetting = await dao.getSettingByKey('userLinkedin');
    final websiteSetting  = await dao.getSettingByKey('userWebsite');
    final presetSetting   = await dao.getSettingByKey('profilePreset');
    final colsSetting = await dao.getSettingByKey('customColumns');
    final jobcenterSetting = await dao.getSettingByKey('jobcenterMode');
    final spellLangSetting = await dao.getSettingByKey('spellCheckLanguage');
    
    final imapProviderSetting = await dao.getSettingByKey('imapProvider');
    final imapServerSetting = await dao.getSettingByKey('imapServer');
    final imapPortSetting = await dao.getSettingByKey('imapPort');
    final smtpServerSetting = await dao.getSettingByKey('smtpServer');
    final smtpPortSetting = await dao.getSettingByKey('smtpPort');
    final imapEmailSetting = await dao.getSettingByKey('imapEmail');
    
    if (mounted) {
      setState(() {
        _nameController.text       = nameSetting?.value ?? '';
        _emailController.text      = emailSetting?.value ?? '';
        _phoneController.text      = phoneSetting?.value ?? '';
        _addressController.text    = addressSetting?.value ?? '';
        _cityController.text       = citySetting?.value ?? '';
        _zipController.text        = zipSetting?.value ?? '';
        _birthdateController.text  = birthSetting?.value ?? '';
        _skillsController.text     = skillsSetting?.value ?? '';
        _linkedinController.text   = linkedinSetting?.value ?? '';
        _websiteController.text    = websiteSetting?.value ?? '';
        
        _selectedPreset = presetSetting?.value ?? 'IT / Software';
        _customColumns = colsSetting?.value ?? _presets[_selectedPreset]!;
        _customColumnsController.text = _customColumns;
        _jobcenterMode = jobcenterSetting?.value == 'true';
        _spellCheckLanguage = spellLangSetting?.value ?? 'de';
        
        _selectedMailProvider = imapProviderSetting?.value ?? 'Manuell';
        _imapServerController.text = imapServerSetting?.value ?? '';
        _imapPortController.text = imapPortSetting?.value ?? '993';
        _smtpServerController.text = smtpServerSetting?.value ?? '';
        _smtpPortController.text = smtpPortSetting?.value ?? '465';
        _imapEmailController.text = imapEmailSetting?.value ?? '';
        _imapPasswordController.text = '********'; // Fake password indicator
        
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final dao = ref.read(databaseProvider).settingsDao;
    await dao.insertOrUpdateSetting(Setting(key: 'userName',      value: _nameController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userEmail',     value: _emailController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userPhone',     value: _phoneController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userAddress',   value: _addressController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userCity',      value: _cityController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userZip',       value: _zipController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userBirthdate', value: _birthdateController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userSkills',    value: _skillsController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userLinkedin',  value: _linkedinController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'userWebsite',   value: _websiteController.text));

    await dao.insertOrUpdateSetting(Setting(key: 'profilePreset', value: _selectedPreset));
    await dao.insertOrUpdateSetting(Setting(key: 'customColumns', value: _customColumnsController.text));
    
    await dao.insertOrUpdateSetting(Setting(key: 'imapProvider', value: _selectedMailProvider));
    await dao.insertOrUpdateSetting(Setting(key: 'imapServer', value: _imapServerController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'imapPort', value: _imapPortController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'smtpServer', value: _smtpServerController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'smtpPort', value: _smtpPortController.text));
    await dao.insertOrUpdateSetting(Setting(key: 'imapEmail', value: _imapEmailController.text));
    
    if (_imapPasswordController.text != '********' && _imapPasswordController.text.isNotEmpty) {
      await ImapService.savePassword(_imapPasswordController.text);
      await dao.insertOrUpdateSetting(const Setting(key: 'imapPassword', value: 'SECURE_STORAGE'));
    }

    // Live-Update: customColumnsProvider in ApplicationsScreen sofort neu laden
    ref.invalidate(customColumnsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('âœ… Einstellungen gespeichert'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'jobtracker.sqlite'));
      
      if (!await dbFile.exists()) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Keine Datenbankdatei gefunden.')));
        return;
      }

      final saveLocation = await getSaveLocation(
        acceptedTypeGroups: [const XTypeGroup(label: 'SQLite Database', extensions: ['sqlite', 'db'])],
        suggestedName: 'jobtracker_backup.sqlite',
      );

      if (saveLocation == null) return;
      
      await dbFile.copy(saveLocation.path);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('âœ… Backup erfolgreich gespeichert!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _importBackup() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.settingsExportRestart), 
        duration: Duration(seconds: 4)
      ));
    }
    
    try {
      final typeGroup = const XTypeGroup(label: 'SQLite Database', extensions: ['sqlite', 'db']);
      final file = await openFile(acceptedTypeGroups: [typeGroup]);

      if (file == null) return;

      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'jobtracker.sqlite'));

      // Copy uploaded file to the db location (overwriting it)
      final uploadedFile = File(file.path);
      await uploadedFile.copy(dbFile.path);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('âœ… Import erfolgreich'),
            content: const Text('Die Datenbank wurde ersetzt. Bitte schlieÃŸe die App komplett und starte sie neu, um die Ã„nderungen zu laden.'),
            actions: [
              TextButton(onPressed: () => exit(0), child: Text(AppLocalizations.of(context)!.settingsAppQuit)),
            ],
          )
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Design & Personalisierung
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                            Text(AppLocalizations.of(context)!.settingsLanguage, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Consumer(
                        builder: (context, ref, child) {
                          final locale = ref.watch(localeProvider);
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.settingsAppLanguage,
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.translate),
                            ),
                            value: locale?.languageCode ?? '',
                            items: [
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
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sprache der Rechtschreibpr\u00fcfung',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.spellcheck),
                        ),
                        value: _spellCheckLanguage,
                        items: SpellChecker.availableLanguages.entries.map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                        ).toList(),
                        onChanged: (val) async {
                          if (val == null) return;
                          setState(() => _spellCheckLanguage = val);
                          final dao = ref.read(databaseProvider).settingsDao;
                          await dao.insertOrUpdateSetting(Setting(key: 'spellCheckLanguage', value: val));
                          // Reload dictionary in background
                          SpellChecker.loadDictionary(language: val);
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(AppLocalizations.of(context)!.settingsDesignTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.brightness_6),
                        title: Text(AppLocalizations.of(context)!.settingsTheme),
                        trailing: DropdownButton<ThemeMode>(
                          value: themeState.themeMode,
                          items: [
                            DropdownMenuItem(value: ThemeMode.system, child: Text(AppLocalizations.of(context)!.settingsThemeSystem)),
                            DropdownMenuItem(value: ThemeMode.light, child: Text(AppLocalizations.of(context)!.settingsThemeLight)),
                            DropdownMenuItem(value: ThemeMode.dark, child: Text(AppLocalizations.of(context)!.settingsThemeDark)),
                          ],
                          onChanged: (mode) {
                            if (mode != null) themeNotifier.setThemeMode(mode);
                          },
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.color_lens),
                        title: Text(AppLocalizations.of(context)!.settingsAccentColor),
                        trailing: Wrap(
                          spacing: 8,
                          children: [Colors.teal, Colors.blue, Colors.purple, Colors.orange, Colors.green, Colors.pink].map((color) {
                            return InkWell(
                              onTap: () => themeNotifier.setSeedColor(color),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (themeState.preset == ThemePreset.standard && themeState.seedColor.value == color.value)
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.auto_awesome),
                        title: Text(AppLocalizations.of(context)!.settingsPreset),
                        subtitle: Text(AppLocalizations.of(context)!.settingsPresetDesc),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('Standard'),
                              selected: themeState.preset == ThemePreset.standard,
                              onSelected: (_) => themeNotifier.setPreset(ThemePreset.standard),
                            ),
                            FilterChip(
                              label: const Text('🖤 Obsidian'),
                              selected: themeState.preset == ThemePreset.obsidian,
                              selectedColor: const Color(0xFF45475A),
                              labelStyle: TextStyle(
                                color: themeState.preset == ThemePreset.obsidian
                                    ? const Color(0xFFCBA6F7)
                                    : null,
                              ),
                              onSelected: (_) {
                                themeNotifier.setPreset(ThemePreset.obsidian);
                                themeNotifier.setThemeMode(ThemeMode.dark);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      SwitchListTile(
                        secondary: const Icon(Icons.account_balance),
                        title: Text(AppLocalizations.of(context)!.settingsJobcenterMode),
                        subtitle: Text(AppLocalizations.of(context)!.settingsJobcenterDesc),
                        value: _jobcenterMode,
                        onChanged: (val) async {
                          setState(() => _jobcenterMode = val);
                          final dao = ref.read(databaseProvider).settingsDao;
                          await dao.insertOrUpdateSetting(Setting(key: 'jobcenterMode', value: val.toString()));
                          ref.invalidate(jobcenterModeProvider);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Berufsfeld
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.settingsFieldTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPreset,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsFieldSelect, border: OutlineInputBorder()),
                        items: _presets.keys.map((key) => DropdownMenuItem(value: key, child: Text(key))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPreset = val;
                              if (val != 'Individuell') {
                                _customColumnsController.text = _presets[val]!;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customColumnsController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.settingsCustomCols,
                          hintText: 'z.B. Portfolio-Link, Sprachen, Remote-Anteil',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Persönliche Daten
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.settingsPersonalData, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsYourName, border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _birthdateController,
                              decoration: InputDecoration(labelText: 'Geburtsdatum', hintText: 'TT.MM.JJJJ', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: 'E-Mail', border: OutlineInputBorder()),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              decoration: InputDecoration(labelText: 'Telefon', border: OutlineInputBorder()),
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _addressController,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsYourAddress, border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _zipController,
                              decoration: InputDecoration(labelText: 'PLZ', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: _cityController,
                              decoration: InputDecoration(labelText: 'Stadt', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _skillsController,
                        decoration: InputDecoration(labelText: 'Skills / Kenntnisse', hintText: 'z.B. Java, Flutter, Projektmanagement (kommagetrennt)', border: OutlineInputBorder()),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _linkedinController,
                              decoration: InputDecoration(labelText: 'LinkedIn / Xing Profil URL', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _websiteController,
                              decoration: InputDecoration(labelText: 'Persönliche Website / Portfolio', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          child: Text(AppLocalizations.of(context)!.settingsImapSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // IMAP E-Mail Integration
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.settingsImapTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.orange.withOpacity(0.6)),
                            ),
                            child: const Text(
                              'âš— EXPERIMENTELL',
                              style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                          ),
                        ],
                      ),
                      Text(AppLocalizations.of(context)!.settingsImapDesc, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.settingsImapWarning,
                                style: TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedMailProvider,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsImapProvider, border: OutlineInputBorder()),
                        items: [
                          DropdownMenuItem(value: 'Manuell', child: Text(AppLocalizations.of(context)!.settingsImapManual)),
                          DropdownMenuItem(value: 'Gmail', child: Text('Gmail')),
                          DropdownMenuItem(value: 'GMX', child: Text('GMX')),
                          DropdownMenuItem(value: 'Web.de', child: Text('Web.de')),
                          DropdownMenuItem(value: 'Outlook', child: Text('Outlook / Hotmail')),
                          DropdownMenuItem(value: 'iCloud', child: Text('iCloud')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedMailProvider = val;
                              if (val == 'Gmail') { 
                                _imapServerController.text = 'imap.gmail.com'; _imapPortController.text = '993'; 
                                _smtpServerController.text = 'smtp.gmail.com'; _smtpPortController.text = '465';
                              }
                              if (val == 'GMX') { 
                                _imapServerController.text = 'imap.gmx.net'; _imapPortController.text = '993'; 
                                _smtpServerController.text = 'mail.gmx.net'; _smtpPortController.text = '465';
                              }
                              if (val == 'Web.de') { 
                                _imapServerController.text = 'imap.web.de'; _imapPortController.text = '993'; 
                                _smtpServerController.text = 'smtp.web.de'; _smtpPortController.text = '465';
                              }
                              if (val == 'Outlook') { 
                                _imapServerController.text = 'outlook.office365.com'; _imapPortController.text = '993'; 
                                _smtpServerController.text = 'smtp.office365.com'; _smtpPortController.text = '587';
                              }
                              if (val == 'iCloud') { 
                                _imapServerController.text = 'imap.mail.me.com'; _imapPortController.text = '993'; 
                                _smtpServerController.text = 'smtp.mail.me.com'; _smtpPortController.text = '587';
                              }
                            });
                          }
                        },
                      ),
                      if (_selectedMailProvider == 'Gmail' || _selectedMailProvider == 'iCloud') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.amber.withOpacity(0.1),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber, color: Colors.amber, size: 20),
                              SizedBox(width: 8),
                              Expanded(child: Text('Wichtig: Für diesen Anbieter musst du in deinen Account-Einstellungen ein "App-Passwort" generieren! Dein normales Passwort funktioniert hier nicht.', style: TextStyle(fontSize: 12))),
                            ],
                          ),
                        )
                      ],
                      const SizedBox(height: 16),
                      const Text('Eingangsserver (IMAP)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _imapServerController,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsImapServer, border: OutlineInputBorder()),
                              enabled: _selectedMailProvider == 'Manuell',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _imapPortController,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsImapPort, border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              enabled: _selectedMailProvider == 'Manuell',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Ausgangsserver (SMTP)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _smtpServerController,
                              decoration: InputDecoration(labelText: 'SMTP Server (Versand)', border: OutlineInputBorder()),
                              enabled: _selectedMailProvider == 'Manuell',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: _smtpPortController,
                              decoration: InputDecoration(labelText: 'SMTP Port', border: OutlineInputBorder()),
                              keyboardType: TextInputType.number,
                              enabled: _selectedMailProvider == 'Manuell',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Zugangsdaten', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _imapEmailController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsImapEmail, border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _imapPasswordController,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.settingsImapPassword, border: OutlineInputBorder()),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final server = _imapServerController.text;
                              final port = int.tryParse(_imapPortController.text) ?? 993;
                              final email = _imapEmailController.text;
                              final pass = _imapPasswordController.text;
                              
                              if (server.isEmpty || email.isEmpty || pass.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bitte Server, E-Mail und Passwort ausfüllen.')),
                                );
                                return;
                              }
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Verbindung wird getestet...')),
                              );
                              
                              try {
                                String actualPass = pass;
                                if (pass == '********') {
                                  actualPass = await ImapService.getPassword();
                                }
                                
                                final client = await ref.read(imapServiceProvider).connect(server, port, email, actualPass);
                                if (client != null) {
                                  await client.disconnect();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Erfolgreich verbunden!'), backgroundColor: Colors.green),
                                    );
                                  }
                                } else {
                                  throw Exception('Fehler bei der Anmeldung.');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Verbindung fehlgeschlagen: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.cable),
                            label: const Text('Verbindung testen'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          child: Text(AppLocalizations.of(context)!.settingsImapSave),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Daten-Export
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.settingsExportTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: Text(AppLocalizations.of(context)!.settingsExportPdf),
                        onTap: () async {
                          final applications = await ref.read(applicationsRepositoryProvider).getAllApplications();
                          final settingsDao = ref.read(databaseProvider).settingsDao;
                          await PdfGenerator.generateAndSharePdf(applications, settingsDao);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.table_chart),
                        title: Text(AppLocalizations.of(context)!.settingsExportCsv),
                        onTap: () async {
                          final applications = await ref.read(applicationsRepositoryProvider).getAllApplications();
                          await CsvGenerator.generateAndShareCsv(applications);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.backup),
                        title: Text(AppLocalizations.of(context)!.settingsExportBackup),
                        onTap: _exportBackup,
                      ),
                      ListTile(
                        leading: const Icon(Icons.restore),
                        title: Text(AppLocalizations.of(context)!.settingsExportRestore),
                        onTap: _importBackup,
                      ),
                    ],
                  ),
                ),
              ),

              // Über diese App
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Über diese App', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text('Version'),
                        trailing: Text('0.6.1 Alpha', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.new_releases),
                        title: const Text('Changelog ansehen'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangelogScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}



