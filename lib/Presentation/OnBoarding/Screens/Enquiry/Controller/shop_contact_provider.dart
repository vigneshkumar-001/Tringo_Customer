import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Login Screen/Controller/login_notifier.dart';

/// Contact details needed to route an enquiry to a shop.
@immutable
class ShopContact {
  final String englishName;
  final String primaryPhone;
  final String alternatePhone;

  const ShopContact({
    this.englishName = '',
    this.primaryPhone = '',
    this.alternatePhone = '',
  });

  /// Best phone number to use for WhatsApp (alternate, falling back to primary).
  String get whatsappPhone {
    final alternate = alternatePhone.trim();
    if (alternate.isNotEmpty) return alternate;
    return primaryPhone.trim();
  }

  bool get hasPhone => whatsappPhone.isNotEmpty;
}

/// Normalises backend strings that may arrive as the literal text "null".
String _clean(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty || v.toLowerCase() == 'null') return '';
  return v;
}

/// Lazily fetches a shop's contact info (used to deliver the enquiry).
///
/// The product/service list screens only receive a [shopId]; the WhatsApp
/// number lives on the full shop-details payload, so we fetch it on demand and
/// let Riverpod cache the result for the lifetime of the screen.
final shopContactProvider =
    FutureProvider.family<ShopContact, String>((ref, String shopId) async {
  if (shopId.trim().isEmpty) return const ShopContact();

  final api = ref.watch(apiDataSourceProvider);
  final result = await api.getSpecificDetails(shopId: shopId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (response) {
      final data = response.data;
      if (data == null) return const ShopContact();
      return ShopContact(
        englishName: _clean(data.englishName),
        primaryPhone: _clean(data.primaryPhone),
        alternatePhone: _clean(data.alternatePhone),
      );
    },
  );
});
