import 'dart:io';

import 'package:flutter/services.dart';

/// Opens a specific shop's WhatsApp chat with a generated PDF attached.
///
/// The OS share sheet cannot route a file to a specific number, so this uses a
/// native Android `ACTION_SEND` + `jid` intent (see `MainActivity.kt`). It is
/// Android-only and returns false when WhatsApp isn't available or anything
/// fails, so callers can fall back to the standard share sheet.
class WhatsappFileSender {
  WhatsappFileSender._();

  static const MethodChannel _channel = MethodChannel('tringo/whatsapp_share');

  /// Returns true if a WhatsApp chat for [phone] was opened with the PDF at
  /// [filePath] attached. Tries consumer WhatsApp first, then WhatsApp Business.
  static Future<bool> sharePdfToNumber({
    required String filePath,
    required String phone,
    String caption = '',
  }) async {
    if (!Platform.isAndroid) return false;
    if (phone.trim().isEmpty || filePath.trim().isEmpty) return false;

    Future<bool> tryShare({required bool business}) async {
      try {
        final ok = await _channel.invokeMethod<bool>('shareFileToWhatsApp', {
          'filePath': filePath,
          'phone': phone,
          'caption': caption,
          'business': business,
        });
        return ok == true;
      } catch (_) {
        return false;
      }
    }

    if (await tryShare(business: false)) return true;
    return tryShare(business: true);
  }
}
