/// Response for the multi-item enquiry submit endpoint.
///
/// Backend contract (POST `/api/v1/public/shops/{shopId}/enquiries`):
///
/// Request body:
/// ```json
/// {
///   "kind": "PRODUCT" | "SERVICE" | "MIXED",
///   "items": [
///     {
///       "id": "<catalogue id>",
///       "type": "PRODUCT" | "SERVICE",
///       "name": "Garden",
///       "quantity": 2,
///       "unitPrice": 4750.0,
///       "offerPrice": 4750.0,
///       "lineTotal": 9500.0,
///       "unitLabel": "per kg"   // optional
///     }
///   ],
///   "totals": { "itemCount": 2, "totalQuantity": 3, "grandTotal": 16150.0 },
///   "customer": { "name": "John", "phone": "+9198..." },  // may be empty
///   "message": "<human readable fallback summary>",
///   "generatePdf": true
/// }
/// ```
///
/// Success response:
/// ```json
/// {
///   "status": true,
///   "data": {
///     "id": "enq_123",
///     "pdfBase64": "JVBERi0x...",
///     "pdfFileName": "Enquiry_shop_123.pdf",
///     "pdfMimeType": "application/pdf",
///     "whatsappNumber": "+9198...",   // optional; shop's WhatsApp number
///     "message": "...",                // optional; server-formatted caption
///     "createdAt": "2026-06-23T10:00:00Z"
///   }
/// }
/// ```
///
/// `pdfBase64` is decoded into a temporary local file and shared as the actual
/// PDF attachment. The backend does not persist the PDF.
class EnquirySubmitResponse {
  final bool status;
  final String id;
  final String pdfUrl;
  final String pdfBase64;
  final String pdfFileName;
  final String pdfMimeType;
  final String whatsappNumber;
  final String message;
  final String createdAt;

  const EnquirySubmitResponse({
    required this.status,
    this.id = '',
    this.pdfUrl = '',
    this.pdfBase64 = '',
    this.pdfFileName = '',
    this.pdfMimeType = '',
    this.whatsappNumber = '',
    this.message = '',
    this.createdAt = '',
  });

  bool get hasPdfBytes => pdfBase64.trim().isNotEmpty;

  bool get hasPdfLink => pdfUrl.trim().isNotEmpty;

  bool get hasPdf => hasPdfBytes || hasPdfLink;

  static String _str(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.toLowerCase() == 'null' ? '' : s;
  }

  factory EnquirySubmitResponse.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? const {};
    return EnquirySubmitResponse(
      status: json['status'] == true,
      id: _str(data['id']),
      pdfUrl: _str(data['pdfUrl'] ?? data['pdf_url'] ?? data['pdf']),
      pdfBase64: _str(
        data['pdfBase64'] ??
            data['pdf_base64'] ??
            data['pdfBytesBase64'] ??
            data['pdf_bytes_base64'],
      ),
      pdfFileName: _str(
        data['pdfFileName'] ?? data['pdf_file_name'] ?? data['fileName'],
      ),
      pdfMimeType: _str(
        data['pdfMimeType'] ?? data['pdf_mime_type'] ?? data['mimeType'],
      ),
      whatsappNumber: _str(
        data['whatsappNumber'] ??
            data['whatsapp'] ??
            data['shopWhatsapp'] ??
            data['phone'],
      ),
      message: _str(data['message']),
      createdAt: _str(data['createdAt']),
    );
  }
}
