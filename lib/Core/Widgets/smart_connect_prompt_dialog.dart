import 'package:flutter/material.dart';

import '../Utility/app_color.dart';
import '../Utility/google_font.dart';

/// Shown right after a user taps a product/shop search suggestion, before
/// navigating to the results list — invites them to fan out a Smart Connect
/// request to nearby verified businesses in the same category.
///
/// Returns `true` when the user wants to send the request, `false`/`null`
/// otherwise (tapped "No" or dismissed).
Future<bool?> showSmartConnectPromptDialog(
  BuildContext context, {
  required int verifiedCount,
  String? categoryLabel,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColor.lowLightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColor.blue,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$verifiedCount',
                style: GoogleFont.Mulish(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColor.blue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nearby Verified Businesses\nReady to Assist You!',
                textAlign: TextAlign.center,
                style: GoogleFont.Mulish(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColor.black,
                  height: 1.3,
                ),
              ),
              if (categoryLabel != null && categoryLabel.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'in $categoryLabel',
                  textAlign: TextAlign.center,
                  style: GoogleFont.Mulish(
                    fontSize: 13,
                    color: AppColor.gray84,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Send one Smart Connect request and get quick replies from verified shops near you.',
                textAlign: TextAlign.center,
                style: GoogleFont.Mulish(
                  fontSize: 14,
                  color: AppColor.gray84,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          foregroundColor: Colors.grey.shade700,
                        ),
                        child: Text(
                          'No',
                          style: GoogleFont.Mulish(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.blue,
                          foregroundColor: AppColor.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Send Request',
                          style: GoogleFont.Mulish(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
