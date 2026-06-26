import 'package:flutter/foundation.dart';

/// Kind of catalogue entry being enquired about.
enum EnquiryKind { product, service }

/// A single selected product/service line in an enquiry.
///
/// Immutable value object so it can live safely inside Riverpod state and be
/// compared cheaply. [quantity] is always >= 1 while the item is selected.
@immutable
class EnquiryLineItem {
  final String id;
  final String name;
  final String? imageUrl;

  /// Original / list price (may be 0 when the shop did not provide one).
  final double price;

  /// Selling / offer price. When null or <= 0 we fall back to [price].
  final double? offerPrice;

  /// e.g. "per kg", "1 plate". Optional.
  final String? unitLabel;

  final EnquiryKind kind;
  final int quantity;

  const EnquiryLineItem({
    required this.id,
    required this.name,
    required this.kind,
    this.imageUrl,
    this.price = 0,
    this.offerPrice,
    this.unitLabel,
    this.quantity = 1,
  });

  /// Price the customer actually pays per unit.
  double get effectiveUnitPrice {
    final offer = offerPrice;
    if (offer != null && offer > 0) return offer;
    return price;
  }

  /// True when an offer price genuinely discounts the list price.
  bool get hasDiscount {
    final offer = offerPrice;
    return offer != null && offer > 0 && price > 0 && offer < price;
  }

  double get lineTotal => effectiveUnitPrice * quantity;

  EnquiryLineItem copyWith({int? quantity}) {
    return EnquiryLineItem(
      id: id,
      name: name,
      kind: kind,
      imageUrl: imageUrl,
      price: price,
      offerPrice: offerPrice,
      unitLabel: unitLabel,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EnquiryLineItem &&
      other.id == id &&
      other.quantity == quantity &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(id, quantity, kind);
}

/// Lightweight snapshot of the logged-in customer for the enquiry header.
@immutable
class EnquiryCustomer {
  final String name;
  final String phone;

  const EnquiryCustomer({this.name = '', this.phone = ''});

  bool get hasAnyDetail => name.trim().isNotEmpty || phone.trim().isNotEmpty;

  static const empty = EnquiryCustomer();
}
