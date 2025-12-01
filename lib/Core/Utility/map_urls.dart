import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class  MapUrls  {
  MapUrls._(); // prevent instantiation

  static Future<void> openMap({
    required BuildContext context,
    required String latitude,
    required String longitude,
  }) async {
    final Uri googleMapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    try {
      final bool launched = await launchUrl(
        googleMapUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showError(context, 'Could not open Google Maps');
      }
    } catch (e) {
      debugPrint('Error launching map: $e');
      _showError(context, 'Failed to open map');
    }
  }

  static void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }


  static Future<void> openDialer(
      BuildContext context,
      String? rawPhone,
      ) async {
    if (rawPhone == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    // Remove spaces and common formatting characters
    final sanitized = rawPhone.replaceAll(RegExp(r'[\s\-()]'), '');

    if (sanitized.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid phone number')),
      );
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: sanitized, // e.g. +919885555555
    );

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open dialer: $e')),
      );
    }
  }
}
