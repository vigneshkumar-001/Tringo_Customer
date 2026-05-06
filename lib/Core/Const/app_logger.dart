import 'package:logger/logger.dart';

class AppLogger {
  static final Logger log = Logger();

  static String redact(String? value, {int showLast = 4}) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return '';
    if (v.length <= showLast) return '***';
    return '***${v.substring(v.length - showLast)}';
  }
}
