import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Controller/wallet_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/enter_review.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/qr_scan_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/wallet/Screens/send_screen.dart';

enum QrScanFlowMode { payOrReview, reviewOnly }

class QrScanFlow {
  QrScanFlow._();

  static Future<void> openQrAndAskAction({
    required BuildContext context,
    required WidgetRef ref,
    String title = 'Scan QR Code',
    QrScanFlowMode mode = QrScanFlowMode.payOrReview,
  }) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => QrScanScreen(title: title),
      ),
    );

    if (result == null || result.trim().isEmpty) return;
    if (!context.mounted) return;

    final payload = QrScanPayload.fromScanValue(result);
    final toUid = (payload.toUid ?? '').trim();
    final shopId = (payload.shopId ?? '').trim();

    final hasUid = toUid.isNotEmpty;
    final hasShop = shopId.isNotEmpty;

    if (!hasUid && !hasShop) {
      AppSnackBar.error(context, "Invalid QR");
      return;
    }

    if (mode == QrScanFlowMode.reviewOnly) {
      if (!hasShop) {
        AppSnackBar.info(context, "Scan shop QR to review");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EnterReview(shopId: shopId)),
      );
      return;
    }

    await _ensureWalletReady(ref);

    final walletState = ref.read(walletNotifier);
    final wallet = walletState.walletHistoryResponse?.data.wallet;

    final myUid = (wallet?.uid ?? '').toString();
    final myBal = (wallet?.tcoinBalance ?? 0).toString();

    if (!context.mounted) return;

    if (hasUid && !hasShop) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              SendScreen(tCoinBalance: myBal, uid: myUid, initialToUid: toUid),
        ),
      );
      return;
    }

    await _showActionSheet(
      context,
      showPay: hasUid,
      showReview: hasShop,
      onPay: hasUid
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SendScreen(
                    tCoinBalance: myBal,
                    uid: myUid,
                    initialToUid: toUid,
                  ),
                ),
              );
            }
          : null,
      onReview: hasShop
          ? () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EnterReview(shopId: shopId)),
              );
            }
          : null,
    );
  }

  static Future<void> _ensureWalletReady(WidgetRef ref) async {
    final st = ref.read(walletNotifier);
    if (st.walletHistoryResponse != null) return;
    await ref.read(walletNotifier.notifier).walletHistory(type: "ALL");
  }

  static Future<void> _showActionSheet(
    BuildContext context, {
    required bool showPay,
    required bool showReview,
    VoidCallback? onPay,
    VoidCallback? onReview,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 14,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 54,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Choose Action",
                  style: GoogleFont.Mulish(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 14),
                if (showPay)
                  _ActionTile(
                    title: "Pay",
                    subtitle: "Send Tcoins securely",
                    icon: Icons.account_balance_wallet_rounded,
                    onTap: onPay,
                  ),
                if (showPay && showReview) const SizedBox(height: 10),
                if (showReview)
                  _ActionTile(
                    title: "Review",
                    subtitle: "Write a review & earn rewards",
                    icon: Icons.rate_review_rounded,
                    onTap: onReview,
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.whiteSmoke,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.brightGray, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: AppColor.darkBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColor.darkBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFont.Mulish(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColor.lightGray3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right, color: AppColor.darkBlue),
          ],
        ),
      ),
    );
  }
}

class QrScanPayload {
  final String? toUid;
  final String? shopId;
  final String? action;
  final List<String> options;

  const QrScanPayload({
    this.toUid,
    this.shopId,
    this.action,
    this.options = const [],
  });

  bool get hasUid => (toUid ?? '').trim().isNotEmpty;
  bool get hasShop => (shopId ?? '').trim().isNotEmpty;

  bool get canPay => options.contains('SEND_TCOIN') || hasUid;
  bool get canReview => options.contains('REVIEW') || hasShop;

  static QrScanPayload fromScanValue(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return const QrScanPayload();

    final uri = Uri.tryParse(v);

    final payloadParam = uri?.queryParameters['payload'];
    if (payloadParam != null && payloadParam.trim().isNotEmpty) {
      final jsonMap = _tryDecodePayloadToJson(payloadParam.trim());
      if (jsonMap != null) return _fromJsonMap(jsonMap);
    }

    if (uri != null && uri.queryParameters.isNotEmpty) {
      final qp = uri.queryParameters;
      final toUid = _pick(qp, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
      final shopId = _pick(qp, ['shopId', 'shopID', 'shop_id', 'shop']);
      if ((toUid ?? '').trim().isNotEmpty || (shopId ?? '').trim().isNotEmpty) {
        return QrScanPayload(
          toUid: toUid?.trim(),
          shopId: shopId?.trim(),
          action: _pick(qp, ['action'])?.trim(),
          options: const [],
        );
      }
    }

    final jsonMapDirect = _tryJsonDecode(v);
    if (jsonMapDirect != null) return _fromJsonMap(jsonMapDirect);

    final onlyUid = _extractUid(v);
    if (onlyUid != null) {
      return QrScanPayload(toUid: onlyUid, options: const ['SEND_TCOIN']);
    }

    return const QrScanPayload();
  }

  static QrScanPayload _fromJsonMap(Map<String, dynamic> m) {
    final toUid = _pick(m, ['toUid', 'toUID', 'uid', 'to_uid', 'to']);
    final shopId = _pick(m, ['shopId', 'shopID', 'shop_id', 'shop']);
    final action = _pick(m, ['action', 'act']);

    return QrScanPayload(
      toUid: toUid?.toString().trim(),
      shopId: shopId?.toString().trim(),
      action: action?.toString().trim(),
      options: _readOptions(m),
    );
  }

  static Map<String, dynamic>? _tryDecodePayloadToJson(String b64url) {
    try {
      var s = b64url.replaceAll('-', '+').replaceAll('_', '/');
      while (s.length % 4 != 0) {
        s += '=';
      }
      final bytes = base64Decode(s);
      final decoded = utf8.decode(bytes);
      final map = jsonDecode(decoded);
      return (map as Map).cast<String, dynamic>();
    } catch (_) {
      try {
        final bytes = base64Decode(b64url);
        final decoded = utf8.decode(bytes);
        final map = jsonDecode(decoded);
        return (map as Map).cast<String, dynamic>();
      } catch (_) {
        return null;
      }
    }
  }

  static Map<String, dynamic>? _tryJsonDecode(String v) {
    try {
      final map = jsonDecode(v);
      if (map is Map) return map.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? _extractUid(String v) {
    final m = RegExp(r'(UID[A-Za-z0-9]+)', caseSensitive: false).firstMatch(v);
    return m?.group(1)?.toUpperCase();
  }

  static String? _pick(Map m, List<String> keys) {
    for (final k in keys) {
      if (m.containsKey(k) && (m[k]?.toString().trim().isNotEmpty ?? false)) {
        return m[k].toString();
      }
    }
    return null;
  }

  static List<String> _readOptions(Map<String, dynamic> jsonMap) {
    final opts = jsonMap['options'];
    if (opts is List) {
      return opts
          .map((e) {
            if (e is Map) {
              return (e['key'] ?? e['code'] ?? e['name'])?.toString();
            }
            return e?.toString();
          })
          .whereType<String>()
          .map((e) => e.trim().toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
