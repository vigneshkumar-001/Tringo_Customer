import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../Login Screen/Controller/login_notifier.dart';
import '../Controller/enquiry_selection_notifier.dart';
import '../Controller/shop_contact_provider.dart';
import '../Model/enquiry_models.dart';
import '../Model/enquiry_submit_response.dart';
import '../Service/enquiry_sender.dart';

/// Opens the enquiry review + send bottom sheet for a given bucket.
Future<void> showEnquiryReviewSheet(
  BuildContext context, {
  required String bucketKey,
  required String shopId,
  required String shopName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EnquiryReviewSheet(
      bucketKey: bucketKey,
      shopId: shopId,
      shopName: shopName,
    ),
  );
}

class EnquiryReviewSheet extends ConsumerStatefulWidget {
  final String bucketKey;
  final String shopId;
  final String shopName;

  const EnquiryReviewSheet({
    super.key,
    required this.bucketKey,
    required this.shopId,
    required this.shopName,
  });

  @override
  ConsumerState<EnquiryReviewSheet> createState() => _EnquiryReviewSheetState();
}

class _EnquiryReviewSheetState extends ConsumerState<EnquiryReviewSheet> {
  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_IN');

  EnquiryCustomer _customer = EnquiryCustomer.empty;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    final c = await EnquirySender.loadCustomer();
    if (!mounted) return;
    setState(() => _customer = c);
  }

  String _shopName() =>
      widget.shopName.trim().isEmpty ? 'Shop' : widget.shopName.trim();

  @override
  Widget build(BuildContext context) {
    // Watch selection; auto-close when everything is deselected.
    final selection = ref.watch(enquirySelectionProvider(widget.bucketKey));
    ref.listen(enquirySelectionProvider(widget.bucketKey), (prev, next) {
      if (next.isEmpty && mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    final items = selection.items;
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height * 0.85;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _grabHandle(),
              _header(items.length),
              const Divider(height: 1),
              Flexible(
                child: items.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 18),
                        itemBuilder: (context, i) => _lineRow(items[i]),
                      ),
              ),
              if (items.isNotEmpty) _summaryAndActions(selection),
            ],
          ),
        ),
      ),
    );
  }

  Widget _grabHandle() => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        height: 4,
        width: 44,
        decoration: BoxDecoration(
          color: AppColor.lightGray2.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
      );

  Widget _header(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enquiry Summary',
                  style: GoogleFont.Mulish(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColor.darkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_shopName()}  •  $count item${count == 1 ? '' : 's'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFont.Mulish(
                    fontSize: 13,
                    color: AppColor.lightGray2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            color: AppColor.darkBlue,
            onPressed: _sending ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No items selected',
            style: GoogleFont.Mulish(
              fontSize: 14,
              color: AppColor.lightGray2,
            ),
          ),
        ),
      );

  Widget _lineRow(EnquiryLineItem item) {
    final notifier =
        ref.read(enquirySelectionProvider(widget.bucketKey).notifier);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFont.Mulish(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.darkBlue,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '₹${_money.format(item.effectiveUnitPrice)}',
                    style: GoogleFont.Mulish(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColor.blue,
                    ),
                  ),
                  if (item.unitLabel != null &&
                      item.unitLabel!.trim().isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        item.unitLabel!.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFont.Mulish(
                          fontSize: 11,
                          color: AppColor.lightGray2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _miniStepper(item, notifier),
        const SizedBox(width: 10),
        SizedBox(
          width: 74,
          child: Text(
            '₹${_money.format(item.lineTotal)}',
            textAlign: TextAlign.right,
            style: GoogleFont.Mulish(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColor.darkBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniStepper(EnquiryLineItem item, EnquirySelectionNotifier notifier) {
    Widget btn(IconData icon, VoidCallback onTap) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _sending ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(icon, size: 16, color: AppColor.green),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.green.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(
            item.quantity <= 1 ? Icons.delete_outline : Icons.remove,
            () => notifier.decrement(item.id),
          ),
          Text(
            '${item.quantity}',
            style: GoogleFont.Mulish(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColor.darkBlue,
            ),
          ),
          btn(Icons.add, () => notifier.increment(item.id)),
        ],
      ),
    );
  }

  Widget _summaryAndActions(EnquirySelection selection) {
    final contactAsync = ref.watch(shopContactProvider(widget.shopId));
    final hasPhone = contactAsync.maybeWhen(
      data: (c) => c.hasPhone,
      orElse: () => false,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_customer.hasAnyDetail) ...[
            _customerLine(),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Text(
                'Total (${selection.totalQuantity} qty)',
                style: GoogleFont.Mulish(
                  fontSize: 14,
                  color: AppColor.lightGray2,
                ),
              ),
              const Spacer(),
              Text(
                '₹${_money.format(selection.grandTotal)}',
                style: GoogleFont.Mulish(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColor.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _sendButton(selection),
          const SizedBox(height: 8),
          _secondaryAction(contactAsync, hasPhone, selection),
        ],
      ),
    );
  }

  Widget _customerLine() {
    final parts = <String>[
      if (_customer.name.trim().isNotEmpty) _customer.name.trim(),
      if (_customer.phone.trim().isNotEmpty) _customer.phone.trim(),
    ];
    return Row(
      children: [
        Icon(Icons.person_outline, size: 16, color: AppColor.lightGray2),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            parts.join('  •  '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFont.Mulish(
              fontSize: 12,
              color: AppColor.lightGray2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sendButton(EnquirySelection selection) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _sending ? null : () => _onSend(selection),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_sending)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Image.asset(
                    AppImages.whatsappImage,
                    height: 20,
                    width: 20,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.chat, color: Colors.white, size: 20),
                  ),
                const SizedBox(width: 10),
                Text(
                  _sending ? 'Preparing…' : 'Send Enquiry on WhatsApp',
                  style: GoogleFont.Mulish(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColor.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryAction(
    AsyncValue<ShopContact> contactAsync,
    bool hasPhone,
    EnquirySelection selection,
  ) {
    // Direct text-only chat to the shop number (fallback / quick option).
    if (!hasPhone) {
      return Text(
        'A PDF + message will open in your share sheet — pick WhatsApp to send.',
        textAlign: TextAlign.center,
        style: GoogleFont.Mulish(fontSize: 11, color: AppColor.lightGray2),
      );
    }
    return TextButton(
      onPressed: _sending ? null : () => _onDirectChat(selection),
      child: Text(
        'Send text-only to ${_shopName()}',
        style: GoogleFont.Mulish(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColor.blue,
        ),
      ),
    );
  }

  Future<void> _onSend(EnquirySelection selection) async {
    final items = selection.items;
    if (items.isEmpty) {
      AppSnackBar.info(context, 'Select at least one item');
      return;
    }
    setState(() => _sending = true);
    try {
      final message = EnquirySender.buildMessage(
        shopName: _shopName(),
        customer: _customer,
        items: items,
      );

      // 1) Preferred path: backend records the enquiry, then opens WhatsApp
      //    directly to this shop's WhatsApp number with the message.
      final delivered = await _trySendViaBackend(items, message);

      // 2) Fallback: open cached shop WhatsApp directly, or share if no number
      //    is available.
      if (!delivered) {
        await _directChatFallback(items, message);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, 'Could not send enquiry. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Returns true when the enquiry was recorded and WhatsApp was opened to the
  /// exact shop number returned by the backend.
  Future<bool> _trySendViaBackend(
    List<EnquiryLineItem> items,
    String message,
  ) async {
    try {
      final body = EnquirySender.buildEnquiryBody(
        items: items,
        customer: _customer,
        message: message,
      );
      final result = await ref
          .read(apiDataSourceProvider)
          .submitEnquiry(shopId: widget.shopId, body: body);

      final res = result.fold((_) => null, (r) => r);
      if (res == null) return false;

      final caption = res.message.isNotEmpty ? res.message : message;

      // Prefer the number the server routes to; else the cached shop contact.
      final contact =
          ref.read(shopContactProvider(widget.shopId)).asData?.value;
      final number = res.whatsappNumber.isNotEmpty
          ? res.whatsappNumber
          : (contact?.whatsappPhone ?? '');
      if (number.isEmpty) {
        if (res.hasPdfBytes) {
          await _shareServerPdfFallback(res, caption);
          return true;
        }
        return false;
      }

      final fullMessage = res.hasPdfLink
          ? EnquirySender.appendPdfLink(caption, res.pdfUrl)
          : caption;

      if (!mounted) return false;
      await EnquirySender.openShopChat(
        context: context,
        phone: number,
        message: fullMessage,
      );
      if (mounted) {
        AppSnackBar.success(context, 'Opening WhatsApp with your enquiry…');
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _shareServerPdfFallback(
    EnquirySubmitResponse res,
    String caption,
  ) async {
    final artifacts = await EnquirySender.prepareFromServerPdf(
      message: caption,
      pdfBase64: res.pdfBase64,
      fileName: res.pdfFileName,
    );
    if (!mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    final ok = await EnquirySender.shareWithPdf(
      artifacts: artifacts,
      shopName: _shopName(),
      sharePositionOrigin: origin,
    );

    if (mounted && ok) {
      AppSnackBar.success(
        context,
        'PDF ready - choose the shop chat in WhatsApp',
      );
    }
  }

  Future<void> _directChatFallback(
    List<EnquiryLineItem> items,
    String message,
  ) async {
    final contact = ref.read(shopContactProvider(widget.shopId)).asData?.value;
    if (contact != null && contact.hasPhone) {
      await EnquirySender.openShopChat(
        context: context,
        phone: contact.whatsappPhone,
        message: message,
      );
      return;
    }

    await _onDeviceFallback(items);
  }

  Future<void> _onDeviceFallback(List<EnquiryLineItem> items) async {
    final artifacts = await EnquirySender.prepare(
      shopName: _shopName(),
      customer: _customer,
      items: items,
    );
    if (!mounted) return;

    // iPad share popover anchor.
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? (box.localToGlobal(Offset.zero) & box.size) : null;

    final ok = await EnquirySender.shareWithPdf(
      artifacts: artifacts,
      shopName: _shopName(),
      sharePositionOrigin: origin,
    );

    if (!mounted) return;
    if (ok) {
      AppSnackBar.success(context, 'Enquiry ready — choose WhatsApp to send');
    } else {
      await _fallbackToChat(artifacts.message);
    }
  }

  Future<void> _fallbackToChat(
    String message, {
    String preferredPhone = '',
  }) async {
    final preferred = preferredPhone.trim();
    if (preferred.isNotEmpty) {
      await EnquirySender.openShopChat(
        context: context,
        phone: preferred,
        message: message,
      );
      return;
    }

    final contact = ref.read(shopContactProvider(widget.shopId)).asData?.value;
    if (contact != null && contact.hasPhone) {
      await EnquirySender.openShopChat(
        context: context,
        phone: contact.whatsappPhone,
        message: message,
      );
    } else if (mounted) {
      AppSnackBar.error(context, 'Sharing is unavailable on this device');
    }
  }

  Future<void> _onDirectChat(EnquirySelection selection) async {
    final items = selection.items;
    if (items.isEmpty) return;
    final contact = ref.read(shopContactProvider(widget.shopId)).asData?.value;
    if (contact == null || !contact.hasPhone) {
      AppSnackBar.info(context, 'Shop WhatsApp number not available');
      return;
    }
    setState(() => _sending = true);
    try {
      final message = await EnquirySender.prepare(
        shopName: _shopName(),
        customer: _customer,
        items: items,
      ).then((a) => a.message);
      if (!mounted) return;
      await EnquirySender.openShopChat(
        context: context,
        phone: contact.whatsappPhone,
        message: message,
      );
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, 'Could not open WhatsApp');
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
