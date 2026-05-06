import 'dart:convert';
import 'package:crypto/crypto.dart';

// NOTE:
// Never hardcode secrets in the client. If this token is still required by the
// backend, pass it at build time (e.g. --dart-define=SIM_SECRET=...)
// and keep it out of source control.
const _simSecret = String.fromEnvironment('SIM_SECRET', defaultValue: '');

String generateSimToken(String contact) {
  if (_simSecret.isEmpty) return '';
  final normalized = contact.trim(); // e.g., +91XXXXXXXXXX
  final input = '$normalized:$_simSecret';
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes); // Correct usage
  return digest.toString();
}
