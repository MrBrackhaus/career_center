import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contact_entity.dart';
import 'database_provider.dart';

final contactsProvider = StreamProvider.family.autoDispose<List<ContactEntity>, int>((
  ref,
  applicationId,
) {
  return ref.watch(contactsRepositoryProvider).watchContactsForApplication(applicationId);
});

class ContactsNotifier extends Notifier<AsyncValue<void>> {
  final int applicationId;
  ContactsNotifier(this.applicationId);

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> addContact(
    String? name,
    String? email,
    String? phone,
    String? role,
  ) async {
    final repo = ref.read(contactsRepositoryProvider);
    await repo.addContact(applicationId, name, email, phone, role);
  }

  Future<void> updateContact(ContactEntity contact) async {
    final repo = ref.read(contactsRepositoryProvider);
    await repo.updateContact(contact);
  }

  Future<void> deleteContact(int id) async {
    final repo = ref.read(contactsRepositoryProvider);
    await repo.deleteContact(id);
  }
}

final contactsNotifierProvider = NotifierProvider.autoDispose
    .family<ContactsNotifier, AsyncValue<void>, int>(
      (id) => ContactsNotifier(id),
    );
