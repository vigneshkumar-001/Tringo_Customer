import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/painting.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  static String buildRichText({
    required String baseText,
    String? title,
    String? description,
  }) {
    var t = baseText.trim();
    if (t.isEmpty) return '';

    final titleText = (title ?? '').trim();
    final descText = (description ?? '').trim();

    if (titleText.isNotEmpty && !_containsIgnoreCase(t, titleText)) {
      t = '$titleText\n$t';
    }

    if (descText.isEmpty || _containsIgnoreCase(t, descText)) return t;

    // Insert description right after the first line (title), to make it look
    // like Amazon-style sharing: Title -> Description -> Link.
    final lines = t.split('\n');
    if (lines.length >= 2) {
      final first = lines.first.trimRight();
      final rest = lines.skip(1).join('\n').trimLeft();
      return '$first\n$descText\n$rest'.trim();
    }

    return '$t\n$descText'.trim();
  }

  static String buildAttractiveText({
    required String baseText,
    String? title,
    String? description,
    List<String> metaLines = const [],
    String brand = 'Tringo',
  }) {
    final raw = baseText.trim();
    if (raw.isEmpty) return '';

    final url = _extractFirstUrl(raw) ?? raw;

    final titleText = (title ?? '').trim();
    final descText = _cleanSingleLine(description ?? '');
    final meta = metaLines
        .map(_cleanSingleLine)
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .toList();

    final parts = <String>[];
    if (titleText.isNotEmpty) {
      parts.add('Check out: $titleText');
    } else {
      parts.add('Check this out');
    }

    if (meta.isNotEmpty) {
      parts.add(meta.take(2).join(' | '));
    }

    if (descText.isNotEmpty) {
      parts.add(_truncateAscii(descText, 140));
    } else if (meta.isEmpty) {
      parts.add('Open in $brand for details, offers & directions.');
    }

    parts.add(url);

    return parts.join('\n').trim();
  }

  static Future<void> shareText(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await Share.share(t);
  }

  static Future<void> shareTextWithImage({
    required String text,
    String? imageUrl,
    String? cardTitle,
    String? cardDescription,
    List<String> cardMetaLines = const [],
    String? badgeText,
    double? ratingValue,
    int? ratingCount,
    bool useDesignCard = false,
  }) async {
    final t = text.trim();
    if (t.isEmpty) return;

    final url = (imageUrl ?? '').trim();
    if (url.isEmpty) {
      await Share.share(t);
      return;
    }

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 18),
          followRedirects: true,
        ),
      );

      final resp = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (s) => s != null && s >= 200 && s < 400,
        ),
      );

      final bytes = resp.data;
      if (bytes == null || bytes.isEmpty) {
        await Share.share(t);
        return;
      }

      final hasCardText =
          (cardTitle ?? '').trim().isNotEmpty ||
          (cardDescription ?? '').trim().isNotEmpty ||
          cardMetaLines.any((e) => e.trim().isNotEmpty) ||
          (badgeText ?? '').trim().isNotEmpty ||
          (ratingValue != null && ratingValue > 0) ||
          ((ratingCount ?? 0) > 0);

      final Uint8List finalBytes;
      String ext;
      String mime;

      final shouldUseCard = useDesignCard && hasCardText;

      if (shouldUseCard) {
        final link = _extractFirstUrl(t);
        String? host;
        if (link != null) {
          try {
            final u = Uri.parse(link);
            host = u.host.trim().isNotEmpty ? u.host.trim() : null;
          } catch (_) {}
        }
        finalBytes = await _buildShareCard(
          imageBytes: Uint8List.fromList(bytes),
          title: cardTitle,
          description: cardDescription,
          metaLines: cardMetaLines,
          badgeText: badgeText,
          ratingValue: ratingValue,
          ratingCount: ratingCount,
          linkHost: host,
        );
        ext = 'png';
        mime = 'image/png';
      } else {
        finalBytes = Uint8List.fromList(bytes);
        final contentType = resp.headers.value('content-type') ?? '';
        ext = _extFrom(contentType: contentType, url: url);
        mime = _mimeFromExt(ext);
      }

      final dir = Directory('${Directory.systemTemp.path}/tringo_share');
      if (!await dir.exists()) await dir.create(recursive: true);

      final file = File(
        '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );
      await file.writeAsBytes(finalBytes, flush: true);

      await Share.shareXFiles([XFile(file.path, mimeType: mime)], text: t);
    } catch (_) {
      await Share.share(t);
    }
  }

  static String _extFrom({required String contentType, required String url}) {
    final ct = contentType.toLowerCase();
    if (ct.contains('image/png')) return 'png';
    if (ct.contains('image/webp')) return 'webp';
    if (ct.contains('image/jpg') || ct.contains('image/jpeg')) return 'jpg';

    final lower = url.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpg';
    return 'jpg';
  }

  static String _mimeFromExt(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  static bool _containsIgnoreCase(String haystack, String needle) {
    return haystack.toLowerCase().contains(needle.toLowerCase());
  }

  static String? _extractFirstUrl(String text) {
    // Supports both web URLs and deep links.
    final exp = RegExp(r'(https?://\S+|tringo://\S+)', caseSensitive: false);
    final m = exp.firstMatch(text);
    if (m == null) return null;
    return m.group(0);
  }

  static String _cleanSingleLine(String s) {
    return s
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('\u0000', '')
        .trim();
  }

  static String _truncateAscii(String s, int max) {
    final t = s.trim();
    if (t.length <= max) return t;
    if (max <= 3) return t.substring(0, max);
    return '${t.substring(0, max - 3).trimRight()}...';
  }

  static String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max - 1).trimRight()}…';
  }

  static Future<Uint8List> _buildShareCard({
    required Uint8List imageBytes,
    String? title,
    String? description,
    List<String> metaLines = const [],
    String? badgeText,
    double? ratingValue,
    int? ratingCount,
    String? linkHost,
  }) async {
    final img = await _decodeUiImage(imageBytes);

    const int w = 1080;
    const int h = 1080;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // WhatsApp-like preview palette
    final bgPaint = Paint()..color = const Color(0xFFEAF6EA);
    canvas.drawRect(Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), bgPaint);

    final radius = 56.0;
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(36, 36, w - 72.0, h - 72.0),
      Radius.circular(radius),
    );

    // Card background
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFFFFFF));

    canvas.save();
    canvas.clipRRect(rrect);

    // Image area
    const double imageTop = 36;
    const double imageLeft = 36;
    const double imageW = w - 72.0;
    const double imageH = 620.0; // ~57%

    paintImage(
      canvas: canvas,
      rect: const Rect.fromLTWH(imageLeft, imageTop, imageW, imageH),
      image: img,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );

    // IMPORTANT: Keep the image area clean (no text/overlays) so it looks like a
    // standard link preview. Chips/ratings are rendered in the bottom panel.

    // Bottom panel
    const double panelTop = imageTop + imageH;
    final panelRect = Rect.fromLTWH(imageLeft, panelTop, imageW, (h - 72.0) - imageH);
    canvas.drawRect(panelRect, Paint()..color = const Color(0xFFDCF8C6));

    // Subtle divider
    canvas.drawRect(
      Rect.fromLTWH(imageLeft, panelTop, imageW, 2),
      Paint()..color = const Color(0xFFB7E6B7),
    );

    final padding = 46.0;
    final textLeft = imageLeft + padding;
    var cursorY = panelTop + 36;
    final textMaxW = imageW - (padding * 2);

    final titleText = (title ?? '').trim();
    final descText = _cleanSingleLine(description ?? '');
    final chip = (badgeText ?? '').trim();
    final meta = metaLines
        .map(_cleanSingleLine)
        .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
        .take(2)
        .toList();

    if (chip.isNotEmpty) {
      final chipPainter = TextPainter(
        text: TextSpan(
          text: _truncateAscii(chip, 26),
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: textMaxW);

      const double chipPadX = 18;
      const double chipPadY = 10;
      final chipW = chipPainter.width + chipPadX * 2;
      final chipH = chipPainter.height + chipPadY * 2;
      final chipRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(textLeft, cursorY, chipW, chipH),
        const Radius.circular(16),
      );
      canvas.drawRRect(chipRect, Paint()..color = const Color(0xFFE1192D));
      chipPainter.paint(canvas, Offset(textLeft + chipPadX, cursorY + chipPadY));
      cursorY += chipH + 18;
    }

    final rv = ratingValue;
    final rc = ratingCount ?? 0;
    if (rv != null && rv > 0) {
      final stars = _starsFor(rv);
      final countLabel = rc > 0 ? ' (${_formatCount(rc)})' : '';
      final ratingPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: rv.toStringAsFixed(1),
              style: const TextStyle(
                color: Color(0xFF0D3B2E),
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
            const TextSpan(text: '  '),
            TextSpan(
              text: stars,
              style: const TextStyle(
                color: Color(0xFFFF8A00),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            TextSpan(
              text: countLabel,
              style: const TextStyle(
                color: Color(0xFF2A4C43),
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: textMaxW);
      ratingPainter.paint(canvas, Offset(textLeft, cursorY));
      cursorY += ratingPainter.height + 18;
    }

    if (titleText.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: _truncateAscii(titleText, 60),
          style: const TextStyle(
            color: Color(0xFF0A2A22),
            fontSize: 48,
            fontWeight: FontWeight.w800,
            height: 1.05,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: textMaxW);
      tp.paint(canvas, Offset(textLeft, cursorY));
      cursorY += tp.height + 18;
    }

    if (meta.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: meta.join('  •  '),
          style: const TextStyle(
            color: Color(0xFF2A4C43),
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: textMaxW);
      tp.paint(canvas, Offset(textLeft, cursorY));
      cursorY += tp.height + 16;
    }

    if (descText.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: _truncateAscii(descText, 160),
          style: const TextStyle(
            color: Color(0xFF28433C),
            fontSize: 30,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
        ellipsis: '…',
      )..layout(maxWidth: textMaxW);
      tp.paint(canvas, Offset(textLeft, cursorY));
    }

    // Link host line (bottom)
    final host = (linkHost ?? '').trim();
    if (host.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: host,
          style: const TextStyle(
            color: Color(0xFF0A2A22),
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '...',
      )..layout(maxWidth: textMaxW);
      final bottomY = (imageTop + (h - 72.0)) - 52 - tp.height;
      tp.paint(canvas, Offset(textLeft, bottomY));
    }

    canvas.restore();

    final picture = recorder.endRecording();
    final out = await picture.toImage(w, h);
    final png = await out.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) return imageBytes;
    return png.buffer.asUint8List();
  }

  static Future<ui.Image> _decodeUiImage(Uint8List bytes) async {
    final c = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (img) => c.complete(img));
    return c.future;
  }

  static String _starsFor(double rating) {
    final r = rating.clamp(0, 5);
    final full = r.floor();
    final half = (r - full) >= 0.5 ? 1 : 0;
    final empty = 5 - full - half;
    return '${'★' * full}${half == 1 ? '☆' : ''}${'☆' * empty}';
  }

  static String _formatCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(',');
      }
    }
    return buf.toString();
  }
}
