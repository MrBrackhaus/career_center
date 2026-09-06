import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/imap_service.dart';
import 'database_provider.dart';
import '../../data/database/app_database.dart';

class EmailScannerState {
  final bool isLoading;
  final bool isImporting;
  final List<ScannableEmail> emails;
  final Set<String> selectedUids;
  final String? error;
  final int? lastImportCount;

  const EmailScannerState({
    this.isLoading = false,
    this.isImporting = false,
    this.emails = const [],
    this.selectedUids = const {},
    this.error,
    this.lastImportCount,
  });

  EmailScannerState copyWith({
    bool? isLoading,
    bool? isImporting,
    List<ScannableEmail>? emails,
    Set<String>? selectedUids,
    String? error,
    int? lastImportCount,
  }) {
    return EmailScannerState(
      isLoading: isLoading ?? this.isLoading,
      isImporting: isImporting ?? this.isImporting,
      emails: emails ?? this.emails,
      selectedUids: selectedUids ?? this.selectedUids,
      error: error,
      lastImportCount: lastImportCount ?? this.lastImportCount,
    );
  }
}

class EmailScannerNotifier extends Notifier<EmailScannerState> {
  @override
  EmailScannerState build() => const EmailScannerState();

  Future<void> loadEmails() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final db = ref.read(databaseProvider);
      final imapService = ImapService();

      final serverSetting = await db.settingsDao.getSettingByKey('imapServer');
      final portSetting = await db.settingsDao.getSettingByKey('imapPort');
      final emailSetting = await db.settingsDao.getSettingByKey('imapEmail');
      final passSetting = await db.settingsDao.getSettingByKey('imapPassword');

      if (serverSetting == null || emailSetting == null || passSetting == null) {
        throw Exception('IMAP Zugangsdaten nicht konfiguriert.');
      }

      final password = await ImapService.getPassword();
      final emails = await imapService.fetchEmailsForScanner(
        db,
        serverSetting.value,
        int.tryParse(portSetting?.value ?? '993') ?? 993,
        emailSetting.value,
        password,
      );

      // Pre-select detected applications that are not yet imported
      final autoSelected = emails
          .where((e) => e.detectedStatus != null && !e.isAlreadyImported)
          .map((e) => e.uid)
          .toSet();

      state = state.copyWith(
        isLoading: false,
        emails: emails,
        selectedUids: autoSelected,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleSelection(String uid) {
    final current = Set<String>.from(state.selectedUids);
    if (current.contains(uid)) {
      current.remove(uid);
    } else {
      current.add(uid);
    }
    state = state.copyWith(selectedUids: current);
  }

  void selectAllDetected() {
    final uids = state.emails
        .where((e) => e.detectedStatus != null && !e.isAlreadyImported)
        .map((e) => e.uid)
        .toSet();
    state = state.copyWith(selectedUids: uids);
  }

  void deselectAll() {
    state = state.copyWith(selectedUids: {});
  }

  Future<int> importSelected() async {
    final toImport = state.emails.where((e) => state.selectedUids.contains(e.uid)).toList();
    if (toImport.isEmpty) return 0;

    state = state.copyWith(isImporting: true);
    try {
      final db = ref.read(databaseProvider);
      final imapService = ImapService();
      final count = await imapService.importSelectedEmails(db, toImport);

      // Mark imported as already imported in the list
      final updatedEmails = state.emails.map((e) {
        if (state.selectedUids.contains(e.uid)) {
          return ScannableEmail(
            uid: e.uid,
            subject: e.subject,
            fromTo: e.fromTo,
            date: e.date,
            bodySnippet: e.bodySnippet,
            detectedStatus: e.detectedStatus,
            isAlreadyImported: true,
            folder: e.folder,
            company: e.company,
          );
        }
        return e;
      }).toList();

      state = state.copyWith(
        isImporting: false,
        emails: updatedEmails,
        selectedUids: {},
        lastImportCount: count,
      );
      return count;
    } catch (e) {
      state = state.copyWith(isImporting: false, error: e.toString());
      return 0;
    }
  }
}

final emailScannerProvider =
    NotifierProvider.autoDispose<EmailScannerNotifier, EmailScannerState>(
        EmailScannerNotifier.new);

