import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../Core/Utility/map_urls.dart';
import '../Model/enquiry_models.dart';
import 'enquiry_pdf_service.dart';

/// Prepared, ready-to-send enquiry artifacts.
class EnquiryArtifacts {
  final String message;
  final File pdfFile;
  final DateTime generatedAt;

  const EnquiryArtifacts({
    required this.message,
    required this.pdfFile,
    required this.generatedAt,
  });
}

/// Orchestrates building and delivering an enquiry over WhatsApp.
///
/// WhatsApp deep links cannot pre-attach a file to a specific number, so
/// delivery is offered in two complementary ways:
///   * [shareWithPdf]  – opens the OS share sheet with the PDF + caption so the
///     user can drop both into the shop's WhatsApp chat (the only reliable way
///     to attach a file, works on Android/iOS/tablet).
///   * [openShopChat]  – opens the shop's WhatsApp chat directly with the text
///     summary prefilled (guaranteed targeting, used as a fallback).
class EnquirySender {
  EnquirySender._();

  /// Reads the cached customer profile written at login/profile time.
  static Future<EnquiryCustomer> loadCustomer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = (prefs.getString('profileName') ?? '').trim();
      final phone = (prefs.getString('profilePhone') ?? '').trim();
      return EnquiryCustomer(
        name: name.toLowerCase() == 'null' ? '' : name,
        phone: phone.toLowerCase() == 'null' ? '' : phone,
      );
    } catch (_) {
      return EnquiryCustomer.empty;
    }
  }

  /// Builds the JSON body for the backend multi-item enquiry endpoint.
  ///
  /// Shape documented in `EnquirySubmitResponse`. The server uses this to
  /// generate the PDF; [message] is the human-readable fallback caption.
  static Map<String, dynamic> buildEnquiryBody({
    required List<EnquiryLineItem> items,
    required EnquiryCustomer customer,
    required String message,
  }) {
    final hasProduct = items.any((e) => e.kind == EnquiryKind.product);
    final hasService = items.any((e) => e.kind == EnquiryKind.service);
    final kind = hasProduct && hasService
        ? 'MIXED'
        : (hasService ? 'SERVICE' : 'PRODUCT');

    final grandTotal = items.fold<double>(0, (s, e) => s + e.lineTotal);
    final totalQty = items.fold<int>(0, (s, e) => s + e.quantity);

    return {
      'kind': kind,
      'generatePdf': true,
      'message': message,
      'customer': {
        'name': customer.name.trim(),
        'phone': customer.phone.trim(),
      },
      'totals': {
        'itemCount': items.length,
        'totalQuantity': totalQty,
        'grandTotal': grandTotal,
      },
      'items': [
        for (final e in items)
          {
            'id': e.id,
            'type': e.kind == EnquiryKind.service ? 'SERVICE' : 'PRODUCT',
            'name': e.name,
            'quantity': e.quantity,
            'unitPrice': e.effectiveUnitPrice,
            'offerPrice': e.offerPrice,
            'lineTotal': e.lineTotal,
            if (e.unitLabel != null && e.unitLabel!.trim().isNotEmpty)
              'unitLabel': e.unitLabel!.trim(),
          },
      ],
    };
  }

  /// Builds the WhatsApp caption text for the current selection.
  static String buildMessage({
    required String shopName,
    required EnquiryCustomer customer,
    required List<EnquiryLineItem> items,
  }) {
    return EnquiryPdfService.buildWhatsappMessage(
      shopName: shopName,
      customer: customer,
      items: items,
      generatedAt: DateTime.now(),
    );
  }

  /// Appends a server PDF link to a message in a WhatsApp-friendly way.
  static String appendPdfLink(String message, String pdfUrl) {
    final url = pdfUrl.trim();
    if (url.isEmpty) return message;
    return '$message\n\n📄 View full enquiry (PDF):\n$url';
  }

  /// Builds the WhatsApp message + PDF for the current selection.
  static Future<EnquiryArtifacts> prepare({
    required String shopName,
    required EnquiryCustomer customer,
    required List<EnquiryLineItem> items,
  }) async {
    final generatedAt = DateTime.now();

    final message = EnquiryPdfService.buildWhatsappMessage(
      shopName: shopName,
      customer: customer,
      items: items,
      generatedAt: generatedAt,
    );

    final pdf = await EnquiryPdfService.buildPdfFile(
      shopName: shopName,
      customer: customer,
      items: items,
      generatedAt: generatedAt,
    );

    return EnquiryArtifacts(
      message: message,
      pdfFile: pdf,
      generatedAt: generatedAt,
    );
  }

  /// Builds share artifacts from a server-rendered, non-persisted PDF payload.
  static Future<EnquiryArtifacts> prepareFromServerPdf({
    required String message,
    required String pdfBase64,
    required String fileName,
  }) async {
    final generatedAt = DateTime.now();
    final pdfFile = await EnquiryPdfService.writeTempPdfFile(
      bytes: base64Decode(pdfBase64),
      fileName: fileName.isEmpty
          ? EnquiryPdfService.fileName('Tringo', generatedAt)
          : fileName,
    );

    return EnquiryArtifacts(
      message: message,
      pdfFile: pdfFile,
      generatedAt: generatedAt,
    );
  }

  /// Shares the PDF + message through the system share sheet.
  ///
  /// Returns true only when the platform reports a completed share.
  static Future<bool> shareWithPdf({
    required EnquiryArtifacts artifacts,
    required String shopName,
    Rect? sharePositionOrigin,
  }) async {
    final result = await Share.shareXFiles(
      [XFile(artifacts.pdfFile.path, mimeType: 'application/pdf')],
      text: artifacts.message,
      subject: 'Enquiry – $shopName',
      sharePositionOrigin: sharePositionOrigin,
    );
    return result.status == ShareResultStatus.success;
  }

  /// Opens the shop's WhatsApp chat directly with the text summary prefilled.
  static Future<void> openShopChat({
    required BuildContext context,
    required String phone,
    required String message,
  }) async {
    await MapUrls.openWhatsapp(
      context: context,
      phone: phone,
      message: message,
    );
  }
}
