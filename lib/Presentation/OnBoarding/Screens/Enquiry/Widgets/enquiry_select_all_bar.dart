import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../Controller/enquiry_selection_notifier.dart';
import '../Model/enquiry_models.dart';

/// "Select all / Deselect all" control shown above a product/service list.
///
/// Operates only on the currently visible [items] (i.e. the selected category),
/// so switching categories never silently selects hidden rows.
class EnquirySelectAllBar extends ConsumerWidget {
  final String bucketKey;
  final List<EnquiryLineItem> items;
  final EdgeInsetsGeometry padding;

  const EnquirySelectAllBar({
    super.key,
    required this.bucketKey,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) return const SizedBox.shrink();

    final ids = items.map((e) => e.id).toList(growable: false);

    // Watch just the count among these ids so the bar updates without
    // rebuilding on unrelated selection changes.
    final selectedHere = ref.watch(
      enquirySelectionProvider(bucketKey).select((s) => s.countAmong(ids)),
    );
    final allSelected = selectedHere == ids.length;
    final notifier = ref.read(enquirySelectionProvider(bucketKey).notifier);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          Text(
            selectedHere > 0
                ? '$selectedHere of ${ids.length} selected'
                : 'Select items to enquire',
            style: GoogleFont.Mulish(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.lightGray2,
            ),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (allSelected) {
                notifier.deselectAll(ids);
              } else {
                notifier.selectAll(items);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: allSelected
                    ? AppColor.green.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: allSelected ? AppColor.green : AppColor.brightGray,
                  width: 1.4,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    allSelected
                        ? Icons.check_circle
                        : Icons.done_all_rounded,
                    size: 16,
                    color: allSelected ? AppColor.green : AppColor.lightGray2,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    allSelected ? 'Deselect all' : 'Select all',
                    style: GoogleFont.Mulish(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: allSelected ? AppColor.green : AppColor.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
