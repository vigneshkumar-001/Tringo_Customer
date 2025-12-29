import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsService {
  static Future<List<String>> getAllNumbers() async {
    if (!await FlutterContacts.requestPermission()) return [];

    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final nums = <String>[];

    for (final c in contacts) {
      for (final p in c.phones) {
        final n = normalizePhone(p.number);
        if (n.isNotEmpty) nums.add(n);
      }
    }
    return nums.toSet().toList();
  }

  static String normalizePhone(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9+]'), '');
  }
}
