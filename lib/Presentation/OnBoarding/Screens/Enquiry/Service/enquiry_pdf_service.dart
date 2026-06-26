import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../Model/enquiry_models.dart';

/// Builds the human-facing enquiry artifacts: a WhatsApp text summary and a
/// shareable PDF document.
///
/// Kept free of Flutter/BuildContext so it can run off the UI isolate-friendly
/// path and be unit-tested. All heavy work (PDF byte generation, file IO) is
/// async and awaited by the caller behind a loading state.
class EnquiryPdfService {
  EnquiryPdfService._();

  // The default PDF (Helvetica) font has no Rupee glyph, so the PDF uses the
  // ASCII-safe "Rs." prefix. The WhatsApp text (rendered by the OS) keeps the
  // proper ₹ symbol.
  static final NumberFormat _amount = NumberFormat('#,##0.00', 'en_IN');

  static String _money(double value) => _amount.format(value);

  static String formatDateTime(DateTime dt) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(dt);

  /// A safe, descriptive file name for the generated PDF.
  static String fileName(String shopName, DateTime dt) {
    final slug = shopName
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(dt);
    final base = slug.isEmpty ? 'shop' : slug;
    return 'Enquiry_${base}_$stamp.pdf';
  }

  /// Builds the plain-text WhatsApp message (list format).
  static String buildWhatsappMessage({
    required String shopName,
    required EnquiryCustomer customer,
    required List<EnquiryLineItem> items,
    required DateTime generatedAt,
  }) {
    final buffer = StringBuffer();
    final isService =
        items.isNotEmpty && items.every((e) => e.kind == EnquiryKind.service);
    final noun = isService ? 'service' : 'product';

    buffer.writeln('*Enquiry – ${shopName.isEmpty ? 'Shop' : shopName}*');
    buffer.writeln();
    buffer.writeln(
      'Hi, I would like to enquire about the following $noun(s):',
    );
    buffer.writeln();

    var index = 1;
    for (final item in items) {
      buffer.writeln('$index. ${item.name}');
      final unit = item.unitLabel?.trim();
      final unitSuffix = (unit != null && unit.isNotEmpty) ? ' ($unit)' : '';
      buffer.writeln(
        '   Qty: ${item.quantity}$unitSuffix  |  ₹${_money(item.lineTotal)}',
      );
      index++;
    }

    final grandTotal = items.fold<double>(0, (s, e) => s + e.lineTotal);
    final totalQty = items.fold<int>(0, (s, e) => s + e.quantity);

    buffer.writeln();
    buffer.writeln('--------------------------------');
    buffer.writeln('*Total: ₹${_money(grandTotal)}*');
    buffer.writeln('Items: ${items.length}  |  Qty: $totalQty');

    if (customer.hasAnyDetail) {
      buffer.writeln();
      final name = customer.name.trim();
      final phone = customer.phone.trim();
      if (name.isNotEmpty) buffer.writeln('Customer: $name');
      if (phone.isNotEmpty) buffer.writeln('Contact: $phone');
    }

    buffer.writeln();
    buffer.writeln('Date: ${formatDateTime(generatedAt)}');
    buffer.writeln();
    buffer.writeln('_Sent via Tringo_');

    return buffer.toString();
  }

  /// Generates the enquiry PDF and writes it to the app's temp directory.
  ///
  /// Returns the written [File]. Throws on IO/encoding failure so the caller
  /// can present an error + fallback.
  static Future<File> buildPdfFile({
    required String shopName,
    required EnquiryCustomer customer,
    required List<EnquiryLineItem> items,
    required DateTime generatedAt,
  }) async {
    final bytes = await _buildPdfBytes(
      shopName: shopName,
      customer: customer,
      items: items,
      generatedAt: generatedAt,
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${fileName(shopName, generatedAt)}');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Writes server-generated PDF bytes to a temporary file for OS sharing.
  static Future<File> writeTempPdfFile({
    required List<int> bytes,
    required String fileName,
  }) async {
    final safeName = _safePdfFileName(fileName);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String _safePdfFileName(String value) {
    final trimmed = value.trim();
    final base = trimmed.isEmpty ? 'Enquiry.pdf' : trimmed;
    final safe = base
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    return safe.toLowerCase().endsWith('.pdf') ? safe : '$safe.pdf';
  }

  static Future<List<int>> _buildPdfBytes({
    required String shopName,
    required EnquiryCustomer customer,
    required List<EnquiryLineItem> items,
    required DateTime generatedAt,
  }) async {
    final doc = pw.Document(
      title: 'Enquiry – $shopName',
      author: 'Tringo',
    );

    const brand = PdfColor.fromInt(0xFF2C8DD1); // AppColor.blue
    const darkBlue = PdfColor.fromInt(0xFF071016); // AppColor.darkBlue
    const lightGrey = PdfColor.fromInt(0xFFEFEFEF);
    const midGrey = PdfColor.fromInt(0xFF8A8A8A);

    final isService =
        items.isNotEmpty && items.every((e) => e.kind == EnquiryKind.service);
    final itemsHeading = isService ? 'Services' : 'Products';

    final grandTotal = items.fold<double>(0, (s, e) => s + e.lineTotal);
    final totalQty = items.fold<int>(0, (s, e) => s + e.quantity);

    pw.Widget headerCell(String text, {bool right = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: pw.Text(
            text,
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),
        );

    pw.Widget bodyCell(String text, {bool right = false, bool bold = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: pw.Text(
            text,
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
            style: pw.TextStyle(
              fontSize: 10,
              color: darkBlue,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 32, 28, 36),
        build: (context) => [
          // ---- Header band ----
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: darkBlue,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      shopName.isEmpty ? 'Shop' : shopName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Product / Service Enquiry',
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: const pw.BoxDecoration(
                    color: brand,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(20)),
                  ),
                  child: pw.Text(
                    'ENQUIRY',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ---- Meta: date + customer ----
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _metaBlock(
                  'Customer Details',
                  customer.hasAnyDetail
                      ? [
                          if (customer.name.trim().isNotEmpty)
                            'Name: ${customer.name.trim()}',
                          if (customer.phone.trim().isNotEmpty)
                            'Phone: ${customer.phone.trim()}',
                        ]
                      : ['Not provided'],
                  midGrey,
                  darkBlue,
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: _metaBlock(
                  'Generated On',
                  [formatDateTime(generatedAt)],
                  midGrey,
                  darkBlue,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 18),

          pw.Text(
            'Selected $itemsHeading',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: darkBlue,
            ),
          ),
          pw.SizedBox(height: 8),

          // ---- Items table ----
          pw.Table(
            border: pw.TableBorder.symmetric(
              inside: const pw.BorderSide(color: lightGrey, width: 0.8),
            ),
            columnWidths: const {
              0: pw.FixedColumnWidth(28), // #
              1: pw.FlexColumnWidth(4), // name
              2: pw.FixedColumnWidth(42), // qty
              3: pw.FlexColumnWidth(2), // unit price
              4: pw.FlexColumnWidth(2), // amount
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: brand),
                children: [
                  headerCell('#'),
                  headerCell('Item'),
                  headerCell('Qty', right: true),
                  headerCell('Unit Price', right: true),
                  headerCell('Amount', right: true),
                ],
              ),
              for (var i = 0; i < items.length; i++)
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: i.isEven ? PdfColors.white : const PdfColor.fromInt(0xFFF7F9FB),
                  ),
                  children: [
                    bodyCell('${i + 1}'),
                    bodyCell(_itemLabel(items[i])),
                    bodyCell('${items[i].quantity}', right: true),
                    bodyCell('Rs. ${_money(items[i].effectiveUnitPrice)}',
                        right: true),
                    bodyCell('Rs. ${_money(items[i].lineTotal)}',
                        right: true, bold: true),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 14),

          // ---- Totals ----
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                width: 220,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFFF7F9FB),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: lightGrey),
                ),
                child: pw.Column(
                  children: [
                    _totalRow('Total Items', '${items.length}', midGrey,
                        darkBlue),
                    pw.SizedBox(height: 4),
                    _totalRow('Total Qty', '$totalQty', midGrey, darkBlue),
                    pw.Divider(color: lightGrey, height: 14),
                    _totalRow(
                      'Grand Total',
                      'Rs. ${_money(grandTotal)}',
                      darkBlue,
                      brand,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),

          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFFFF7E6),
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              'Note: This is an enquiry and not a confirmed order. Prices are '
              'indicative and subject to confirmation by the shop.',
              style: const pw.TextStyle(fontSize: 9, color: midGrey),
            ),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Generated by Tringo  •  Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: midGrey),
          ),
        ),
      ),
    );

    return doc.save();
  }

  static String _itemLabel(EnquiryLineItem item) {
    final unit = item.unitLabel?.trim();
    if (unit != null && unit.isNotEmpty) {
      return '${item.name}  ($unit)';
    }
    return item.name;
  }

  static pw.Widget _metaBlock(
    String title,
    List<String> lines,
    PdfColor labelColor,
    PdfColor valueColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 8,
            letterSpacing: 0.5,
            fontWeight: pw.FontWeight.bold,
            color: labelColor,
          ),
        ),
        pw.SizedBox(height: 4),
        for (final line in lines)
          pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(
              line,
              style: pw.TextStyle(fontSize: 10, color: valueColor),
            ),
          ),
      ],
    );
  }

  static pw.Widget _totalRow(
    String label,
    String value,
    PdfColor labelColor,
    PdfColor valueColor, {
    bool bold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: bold ? 11 : 9,
            color: labelColor,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: bold ? 12 : 9,
            color: valueColor,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
