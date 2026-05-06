import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class SimpleContact {
  final String name;
  final String phone;
  SimpleContact({required this.name, required this.phone});
}

class ContactsService {
  static Future<List<SimpleContact>> _fetchContacts() async {
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    debugPrint("Contacts raw count=${contacts.length}");

    final out = <SimpleContact>[];

    for (final contact in contacts) {
      final name = contact.displayName.trim();
      for (final phoneEntry in contact.phones) {
        final phone = normalizePhone(phoneEntry.number);
        if (phone.isNotEmpty) {
          out.add(
            SimpleContact(
              name: name.isEmpty ? "Unknown" : name,
              phone: phone,
            ),
          );
        }
      }
    }

    // Remove duplicates by phone.
    final map = <String, SimpleContact>{};
    for (final item in out) {
      map[item.phone] = item;
    }

    debugPrint("Contacts parsed unique phones=${map.length}");
    return map.values.toList();
  }

  // Requests permission if needed (may prompt UI) then returns contacts.
  static Future<List<SimpleContact>> getAllContacts() async {
    var status = await Permission.contacts.status;
    debugPrint("Contacts permission status=$status");

    if (!status.isGranted) {
      status = await Permission.contacts.request();
      debugPrint("Contacts permission after request=$status");
    }

    if (status.isPermanentlyDenied) {
      debugPrint("Contacts permission permanently denied; opening settings");
      await openAppSettings();
      return [];
    }

    if (!status.isGranted) {
      debugPrint("Contacts permission not granted");
      return [];
    }

    return _fetchContacts();
  }

  // Silent: DOES NOT request permission / open settings. Returns empty if not granted.
  static Future<List<SimpleContact>> getAllContactsIfPermitted() async {
    final status = await Permission.contacts.status;
    if (!status.isGranted) return [];
    return _fetchContacts();
  }

  static String normalizePhone(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.startsWith('91') && cleaned.length > 10) {
      return cleaned.substring(cleaned.length - 10);
    }
    if (cleaned.length > 10) return cleaned.substring(cleaned.length - 10);
    return cleaned;
  }
}

