import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../Controller/enquiry_selection_notifier.dart';
import '../Model/enquiry_models.dart';

/// Wraps a product/service list card with multi-select + quantity controls.
///
/// The [child] (an existing `CommonContainer.foodList`/`serviceDetails` card)
/// keeps its normal tap-to-open behaviour; a trailing rail handles selection
/// and quantity so the two gestures never collide.
class EnquirySelectableTile extends ConsumerWidget {
  final String bucketKey;
  final EnquiryLineItem item;
  final Widget child;

  /// Whether quantity stepping is offered for this item once selected.
  final bool allowQuantity;

  const EnquirySelectableTile({
    super.key,
    required this.bucketKey,
    required this.item,
    required this.child,
    this.allowQuantity = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(enquirySelectionProvider(bucketKey).notifier);
    // Scope each tile to only its own item so toggling one row never rebuilds
    // the rest of the list — keeps large catalogues smooth.
    final selected = ref.watch(
      enquirySelectionProvider(bucketKey).select((s) => s.contains(item.id)),
    );
    final qty = ref.watch(
      enquirySelectionProvider(bucketKey)
          .select((s) => s.itemFor(item.id)?.quantity ?? 0),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: child),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CheckCircle(
                selected: selected,
                onTap: () => notifier.toggle(item),
              ),
              if (selected && allowQuantity) ...[
                const SizedBox(height: 10),
                _QtyStepper(
                  quantity: qty,
                  onIncrement: () => notifier.increment(item.id),
                  onDecrement: () => notifier.decrement(item.id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckCircle extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _CheckCircle({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: selected,
      label: 'Select for enquiry',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: selected ? AppColor.green : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColor.green : AppColor.lightGray2,
              width: 1.8,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QtyStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.green.withOpacity(0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.add, onIncrement),
          Text(
            '$quantity',
            style: GoogleFont.Mulish(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColor.darkBlue,
            ),
          ),
          _btn(quantity <= 1 ? Icons.delete_outline : Icons.remove, onDecrement),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
        child: Icon(icon, size: 16, color: AppColor.green),
      ),
    );
  }
}
