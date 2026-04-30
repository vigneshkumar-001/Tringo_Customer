import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Controller/subscription_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Screens/ccavenue_checkout_screen.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Subscription/Model/subscription_plans_response.dart';


class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final _businessProfileCtrl = TextEditingController();
  final _shopIdCtrl = TextEditingController();

  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(subscriptionNotifierProvider.notifier);
      await notifier.loadLocalContext();
      await notifier.fetchPlans();
      await notifier.fetchCurrent();
    });
  }

  @override
  void dispose() {
    _businessProfileCtrl.dispose();
    _shopIdCtrl.dispose();
    super.dispose();
  }

  void _prefillOnce(SubscriptionState state) {
    if (_prefilled) return;
    _prefilled = true;
    _businessProfileCtrl.text = state.businessProfileId;
    _shopIdCtrl.text = state.shopId;
  }

  Future<void> _startPayment(SubscriptionPlan plan) async {
    final notifier = ref.read(subscriptionNotifierProvider.notifier);

    // Persist current input.
    await notifier.setBusinessProfileId(_businessProfileCtrl.text);
    await notifier.setShopId(_shopIdCtrl.text);

    final initData = await notifier.startCheckout(planId: plan.id);
    if (!mounted) return;

    if (initData == null) {
      final err = ref.read(subscriptionNotifierProvider).error;
      if (err != null && err.trim().isNotEmpty) {
        AppSnackBar.error(context, err);
      }
      return;
    }

    final form = initData.form;
    if (form == null ||
        form.action.trim().isEmpty ||
        form.encRequest.trim().isEmpty ||
        form.accessCode.trim().isEmpty) {
      AppSnackBar.error(context, 'Payment form missing from backend response');
      return;
    }

    final result = await Navigator.of(context).push<CcavenueCheckoutResult>(
      MaterialPageRoute(
        builder: (_) => CcavenueCheckoutScreen(data: initData),
      ),
    );

    if (!mounted) return;

    if (result == null || result.cancelled) {
      AppSnackBar.info(context, 'Payment cancelled');
      return;
    }

    // Best-effort: confirm if we captured encResp; otherwise just refresh current.
    if ((result.encResp ?? '').trim().isNotEmpty) {
      final confirm = await notifier.confirmPayment(result.encResp!.trim());
      if (!mounted) return;
      final paymentStatus =
          (confirm?.paymentStatus ?? confirm?.data?.payment?.status ?? '')
              .trim()
              .toUpperCase();

      if (paymentStatus == 'SUCCESS') {
        AppSnackBar.success(context, confirm?.message ?? 'Subscription activated');
      } else if (paymentStatus == 'PENDING') {
        AppSnackBar.info(context, confirm?.message ?? 'Payment pending');
      } else if (paymentStatus == 'CANCELLED' || paymentStatus == 'ABORTED') {
        AppSnackBar.info(context, confirm?.message ?? 'Payment cancelled');
      } else if (paymentStatus == 'FAILED') {
        AppSnackBar.error(context, confirm?.message ?? 'Payment failed');
      }
    }

    await notifier.fetchCurrent();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionNotifierProvider);
    _prefillOnce(state);

    final plans = state.plans?.data ?? const <SubscriptionPlan>[];
    final current = state.current?.data;
    final paymentStatus = (current?.payment?.status ?? '').trim();

    final showEmployeeHint = state.role.trim().toUpperCase() == 'EMPLOYEE';

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        surfaceTintColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: AppColor.darkBlue),
        ),
        title: Text(
          'Subscription',
          style: GoogleFont.Mulish(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColor.darkBlue,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final notifier = ref.read(subscriptionNotifierProvider.notifier);
            await notifier.fetchPlans();
            await notifier.fetchCurrent();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (current != null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.brightGray,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current.isFreemium
                            ? 'Freemium'
                            : (current.plan?.title ?? 'Premium'),
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColor.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          current.status,
                          if (paymentStatus.isNotEmpty) 'PAYMENT: $paymentStatus',
                          if ((current.period?.endsAtLabel ?? '').trim().isNotEmpty)
                            'ENDS: ${current.period!.endsAtLabel}',
                        ].join('  •  '),
                        style: GoogleFont.Mulish(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.lightGray2,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 14),

              // IDs (kept minimal; backend uses them for employee / scoped subscriptions)
              if (showEmployeeHint)
                Text(
                  'Employee accounts require Business Profile ID',
                  style: GoogleFont.Mulish(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColor.lightRed,
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _businessProfileCtrl,
                decoration: InputDecoration(
                  labelText: 'Business Profile ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _shopIdCtrl,
                decoration: InputDecoration(
                  labelText: 'Shop ID (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Plans',
                    style: GoogleFont.Mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  if (state.isLoadingPlans || state.isLoadingCurrent)
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (state.error != null && state.error!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    state.error!,
                    style: GoogleFont.Mulish(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColor.lightRed,
                    ),
                  ),
                ),

              if (plans.isEmpty && !state.isLoadingPlans)
                Text(
                  'No plans available',
                  style: GoogleFont.Mulish(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColor.lightGray2,
                  ),
                ),

              ...plans.map(
                (p) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColor.brightGray),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: GoogleFont.Mulish(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColor.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.typeLabel,
                              style: GoogleFont.Mulish(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColor.lightGray2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹${p.price}',
                              style: GoogleFont.Mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColor.darkBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: state.isProcessing
                              ? null
                              : () => _startPayment(p),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.darkBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.isProcessing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  ref
                                          .read(subscriptionNotifierProvider.notifier)
                                          .hasPaidSubscription
                                      ? 'Extend'
                                      : 'Buy',
                                  style: GoogleFont.Mulish(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
