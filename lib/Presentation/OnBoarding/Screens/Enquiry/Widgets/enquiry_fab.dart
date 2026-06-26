import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../Controller/enquiry_selection_notifier.dart';

/// Floating "Enquiry" pill shown when at least one item is selected.
///
/// Displays the live selected-item count and animates in/out as the selection
/// crosses zero. Designed to sit in a [Scaffold.floatingActionButton] slot.
class EnquiryFab extends ConsumerWidget {
  final String bucketKey;
  final VoidCallback onTap;

  const EnquiryFab({
    super.key,
    required this.bucketKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      enquirySelectionProvider(bucketKey).select((s) => s.count),
    );
    final visible = count > 0;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF128C7E).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _WhatsappGlyph(),
                      const SizedBox(width: 9),
                      Text(
                        'Enquiry',
                        style: GoogleFont.Mulish(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColor.white,
                        ),
                      ),
                      const SizedBox(width: 9),
                      _CountBadge(count: count),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhatsappGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use the bundled WhatsApp asset; gracefully fall back to a Material icon
    // if the asset is ever missing.
    return Image.asset(
      AppImages.whatsappImage,
      height: 22,
      width: 22,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.chat,
        size: 22,
        color: Colors.white,
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: GoogleFont.Mulish(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF128C7E),
        ),
      ),
    );
  }
}
