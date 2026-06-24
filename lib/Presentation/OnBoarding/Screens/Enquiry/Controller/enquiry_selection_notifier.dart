import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Model/enquiry_models.dart';

/// Immutable selection state for one bucket (a single shop + kind).
///
/// Backed by an insertion-ordered map keyed by item id so toggling/looking up
/// an item is O(1) even for very large catalogues, while iteration preserves
/// the order the user selected things in.
@immutable
class EnquirySelection {
  final Map<String, EnquiryLineItem> _items;

  const EnquirySelection._(this._items);

  static const empty = EnquirySelection._({});

  int get count => _items.length;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  bool contains(String id) => _items.containsKey(id);

  /// True when every id in [ids] is currently selected (and [ids] is non-empty).
  bool containsAll(Iterable<String> ids) {
    var any = false;
    for (final id in ids) {
      any = true;
      if (!_items.containsKey(id)) return false;
    }
    return any;
  }

  /// How many of [ids] are currently selected.
  int countAmong(Iterable<String> ids) {
    var n = 0;
    for (final id in ids) {
      if (_items.containsKey(id)) n++;
    }
    return n;
  }

  EnquiryLineItem? itemFor(String id) => _items[id];

  /// Selected lines, in selection order.
  List<EnquiryLineItem> get items => List.unmodifiable(_items.values);

  int get totalQuantity =>
      _items.values.fold(0, (sum, e) => sum + e.quantity);

  double get grandTotal =>
      _items.values.fold(0.0, (sum, e) => sum + e.lineTotal);
}

/// Holds the user's multi-select / single-select state for one bucket.
///
/// One provider instance exists per [bucketKey] (see [enquiryBucketKey]), so a
/// shop's product list and service list keep independent selections and never
/// leak into one another.
class EnquirySelectionNotifier extends Notifier<EnquirySelection> {
  EnquirySelectionNotifier(this.bucketKey);

  /// The shop+kind bucket this selection belongs to (see [enquiryBucketKey]).
  final String bucketKey;

  @override
  EnquirySelection build() => EnquirySelection.empty;

  Map<String, EnquiryLineItem> get _current =>
      // Defensive copy so we never mutate the live state map in place.
      Map<String, EnquiryLineItem>.from(state._items);

  /// Add the item if absent, remove it if already selected.
  void toggle(EnquiryLineItem item) {
    final next = _current;
    if (next.containsKey(item.id)) {
      next.remove(item.id);
    } else {
      // Always (re)start at the item's own quantity (>=1).
      next[item.id] = item.copyWith(quantity: item.quantity.clamp(1, 9999));
    }
    state = EnquirySelection._(next);
  }

  void select(EnquiryLineItem item) {
    if (state.contains(item.id)) return;
    final next = _current;
    next[item.id] = item.copyWith(quantity: item.quantity.clamp(1, 9999));
    state = EnquirySelection._(next);
  }

  void remove(String id) {
    if (!state.contains(id)) return;
    final next = _current..remove(id);
    state = EnquirySelection._(next);
  }

  void increment(String id) {
    final existing = state.itemFor(id);
    if (existing == null) return;
    final next = _current;
    next[id] = existing.copyWith(
      quantity: (existing.quantity + 1).clamp(1, 9999),
    );
    state = EnquirySelection._(next);
  }

  /// Decrement quantity; removes the line entirely if it would drop below 1.
  void decrement(String id) {
    final existing = state.itemFor(id);
    if (existing == null) return;
    final next = _current;
    if (existing.quantity <= 1) {
      next.remove(id);
    } else {
      next[id] = existing.copyWith(quantity: existing.quantity - 1);
    }
    state = EnquirySelection._(next);
  }

  void setQuantity(String id, int quantity) {
    final existing = state.itemFor(id);
    if (existing == null) return;
    final next = _current;
    if (quantity <= 0) {
      next.remove(id);
    } else {
      next[id] = existing.copyWith(quantity: quantity.clamp(1, 9999));
    }
    state = EnquirySelection._(next);
  }

  /// Selects every item in [items], preserving the quantity of any that were
  /// already selected. Used by the "Select all" control.
  void selectAll(Iterable<EnquiryLineItem> items) {
    final next = _current;
    var changed = false;
    for (final item in items) {
      if (!next.containsKey(item.id)) {
        next[item.id] = item.copyWith(quantity: item.quantity.clamp(1, 9999));
        changed = true;
      }
    }
    if (changed) state = EnquirySelection._(next);
  }

  /// Removes only the given [ids] from the selection (deselect-all within a
  /// filtered category, without touching items in other categories).
  void deselectAll(Iterable<String> ids) {
    final next = _current;
    var changed = false;
    for (final id in ids) {
      if (next.remove(id) != null) changed = true;
    }
    if (changed) state = EnquirySelection._(next);
  }

  void clear() {
    if (state.isEmpty) return;
    state = EnquirySelection.empty;
  }
}

/// Builds the stable bucket key for a shop's catalogue of a given [kind].
String enquiryBucketKey(String? shopId, EnquiryKind kind) =>
    '${shopId ?? ''}::${kind.name}';

final enquirySelectionProvider =
    NotifierProvider.family<EnquirySelectionNotifier, EnquirySelection, String>(
  EnquirySelectionNotifier.new,
);
