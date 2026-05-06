import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/DataSource/api_data_source.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/contacts/contacts_service.dart';

class ContactsSyncHelper {
  static const _prefContactsSynced = 'contacts_synced';
  static const _prefContactsSyncSkipped = 'contacts_sync_skipped';
  static const _prefContactsSyncInProgress = 'contacts_sync_in_progress';

  // Full sync (can be large, e.g., 10k+ contacts). We send in chunks to avoid huge payloads.
  static const int _chunkSize = 200;

  static String _normalizePhoneE164India(String raw) {
    final digits = raw.replaceAll(RegExp(r'\\D+'), '');
    if (digits.isEmpty) return '';
    // Prefer last 10 digits for Indian numbers.
    final ten = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    if (ten.length != 10) return '';
    return '+91$ten';
  }

  // Silent background sync:
  // - No permission prompt (skips if not granted)
  // - No UI messages (logs only)
  // - Chunked API calls
  static Future<void> syncOnceInBackground(
    ApiDataSource api, {
    bool ignoreSkipped = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySynced = prefs.getBool(_prefContactsSynced) ?? false;
    final skipped = prefs.getBool(_prefContactsSyncSkipped) ?? false;
    final inProgress = prefs.getBool(_prefContactsSyncInProgress) ?? false;

    if (alreadySynced || inProgress || (skipped && !ignoreSkipped)) return;

    await prefs.setBool(_prefContactsSyncInProgress, true);
    try {
      final contacts = await ContactsService.getAllContactsIfPermitted();
      if (contacts.isEmpty) return;

      // Full address-book sync:
      // - Deduplicate by normalized phone
      // - Upload in batches to keep memory + API payload safe
      final seenPhones = <String>{};
      final batch = <Map<String, String>>[];
      var totalPrepared = 0;

      Future<void> flushBatch() async {
        if (batch.isEmpty) return;
        final sending = List<Map<String, String>>.from(batch);
        batch.clear();

        final result = await api.syncContacts(items: sending);
        result.fold((l) => throw Exception(l.message), (r) {
          AppLogger.log.i(
            "contacts sync batch ok total=${r.data.total} inserted=${r.data.inserted} touched=${r.data.touched} skipped=${r.data.skipped}",
          );
        });

        // Gentle pacing so we don't overload the backend on very large address books.
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }

      for (final c in contacts) {
        final phone = _normalizePhoneE164India(c.phone);
        if (phone.isEmpty) continue;
        if (!seenPhones.add(phone)) continue;
        final name = (c.name).trim();
        batch.add({"name": name, "phone": phone});
        totalPrepared++;

        if (batch.length >= _chunkSize) {
          await flushBatch();
        }

        // Yield periodically so UI stays smooth even with very large address books (e.g., 10k+).
        if (totalPrepared % 500 == 0) {
          await Future<void>.delayed(Duration.zero);
        }
      }

      await flushBatch();

      if (totalPrepared == 0) return;

      await prefs.setBool(_prefContactsSynced, true);
      await prefs.remove(_prefContactsSyncSkipped);
      AppLogger.log.i("contacts sync completed");
    } catch (e) {
      AppLogger.log.e("contacts sync failed: $e");
    } finally {
      await prefs.setBool(_prefContactsSyncInProgress, false);
    }
  }

  // Kept for backward compatibility; still runs silently.
  static Future<void> syncOnce(ApiDataSource api) =>
      syncOnceInBackground(api, ignoreSkipped: true);
}
