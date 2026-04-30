// smart_connect_details.dart
//
// ✅ Single-file UI with:
// - Skeleton loader (skeletonizer package)
// - Nice error UI + Retry
// - Nice empty/no-data UI + Refresh
// - Safe null handling for images list
//
// 📦 Add this to pubspec.yaml:
// dependencies:
//   skeletonizer: ^1.4.3
//
// ⚠️ NOTE:
// This file assumes your Riverpod state has:
//   - bool isLoading
//   - String? errorMessage
//   - SmartConnectDetailsResponse? smartConnectDetailsResponse
// and your provider is:
//   smartConnectNotifierProvider
//
// If your state field names differ, just rename them in this file.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:tringo_app/Core/app_go_routes.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Utility/map_urls.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/service_and_shops_details.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/Widgets/full_screen_image_gallery.dart';

// Your provider
import '../Controller/smart_connect_notifier.dart';

class SmartConnectDetails extends ConsumerStatefulWidget {
  final String requestedId;
  const SmartConnectDetails({super.key, required this.requestedId});

  @override
  ConsumerState<SmartConnectDetails> createState() =>
      _SmartConnectDetailsState();
}

class _SmartConnectDetailsState extends ConsumerState<SmartConnectDetails> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(smartConnectNotifierProvider.notifier)
          .fetchSmartConnectDetails(requestId: widget.requestedId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(smartConnectNotifierProvider);

    final details = state.smartConnectDetailsResponse?.data;
    final responses = details?.responses ?? [];

    // One retry method for both error & empty
    void retry() {
      ref
          .read(smartConnectNotifierProvider.notifier)
          .fetchSmartConnectDetails(requestId: widget.requestedId);
    }

    void safeBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.homePath);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Skeletonizer(
          enabled: state.isLoading,
          child: Builder(
            builder: (_) {
              // ✅ ERROR UI
              if (!state.isLoading &&
                  (state.error != null && state.error!.trim().isNotEmpty)) {
                return _ErrorView(
                  message: state.error ?? '',
                  onRetry: retry,
                  onBack: safeBack,
                );
              }

              if (!state.isLoading && (details == null || responses.isEmpty)) {
                return _EmptyView(
                  title: "No replies yet",
                  subtitle: "When shops respond, you’ll see the replies here.",
                  onRetry: retry,
                  onBack: safeBack,
                );
              }

              // ✅ SUCCESS UI (or Skeleton UI)
              // When loading, pass dummy skeleton items (null) to render skeleton cards nicely
              final uiResponses = state.isLoading
                  ? List.filled(3, null)
                  : responses;

              return _SuccessBody(
                replyCountLabel: details?.replyCountLabel ?? "Replies",
                responses: uiResponses,
                onBack: safeBack,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// ----------------------
/// SUCCESS BODY (your UI)
/// ----------------------
class _SuccessBody extends StatelessWidget {
  final String replyCountLabel;
  final List<dynamic> responses; // real model objects OR nulls while loading
  final VoidCallback onBack;

  const _SuccessBody({
    required this.replyCountLabel,
    required this.responses,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Row(
              children: [
                CommonContainer.leftSideArrow(
                  Color: Colors.transparent,
                  onTap: onBack,
                ),
                const SizedBox(width: 20),
                Text(
                  replyCountLabel,
                  style: GoogleFont.Mulish(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColor.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final item = responses[index];

              // Skeleton placeholder card
              if (item == null) {
                return const _ResponseCardSkeleton();
              }

              // Your real model (response item)
              // NOTE: rename fields if your model differs
              final data = item;

              final images = (data.images ?? const <String>[]) as List<dynamic>;
              final imageUrls = images
                  .map((e) => e?.toString() ?? '')
                  .where((e) => e.trim().isNotEmpty)
                  .toList();
              final shop = data.shop;
              

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColor.blushPink,
                      AppColor.blushPink.withOpacity(0.9),
                      AppColor.white,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.productName ?? '',
                                    softWrap: true,
                                    style: GoogleFont.Mulish(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 19,
                                      color: AppColor.darkBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    data.description?.toString() ?? '',
                                    softWrap: true,
                                    style: GoogleFont.Mulish(
                                      fontSize: 10,
                                      color: AppColor.lightGray3,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          data.repliedLabel?.toString() ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10,
                                            color: AppColor.lightGray2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 35),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColor.yellow,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Price',
                                      style: GoogleFont.Mulish(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColor.darkBlue,
                                      ),
                                    ),
                                    Text(
                                      '₹ ${data.price ?? ''}',
                                      style: GoogleFont.Mulish(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColor.white,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 5),
                                            blurRadius: 10,
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ Images (safe null handling)
                      if (images.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "No images available",
                              style: GoogleFont.Mulish(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColor.lightGray2,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          height: 230,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: imageUrls.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, i) {
                              final imageUrl = imageUrls[i];
                              final heroTagPrefix = 'smart_connect_${index}_img';

                              return Container(
                                width: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () => FullScreenImageGallery.open(
                                      context,
                                      imageUrls: imageUrls,
                                      initialIndex: i,
                                      heroTagPrefix: heroTagPrefix,
                                    ),
                                    child: Hero(
                                      tag: '${heroTagPrefix}_$i',
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                              child: SizedBox(
                                                height: 18,
                                                width: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Colors.grey.shade300,
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 28,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 20),

                      Padding(
                        padding:   EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                           onTap: (){
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) =>
                                     ServiceAndShopsDetails(shopId: shop.id, initialIndex: 4),
                               ),
                             );
                             print(shop?.id?.toString() ?? '');
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CommonContainer.verifyTick(),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          shop?.name?.toString() ?? '',
                                          style: GoogleFont.Mulish(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColor.darkBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Image.asset(
                                          AppImages.rightArrow,
                                          height: 8,
                                          color: AppColor.lightBlueCont,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Image.asset(
                                          AppImages.locationImage,
                                          height: 10,
                                          color: AppColor.lightGray2,
                                        ),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            '${shop?.address ?? ''} ${shop?.city ?? ''}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFont.Mulish(
                                              fontSize: 12,
                                              color: AppColor.lightGray2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${shop?.distanceKm ?? ''}Km',
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: AppColor.lightGray3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColor.green,
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${shop?.averageRating ?? ''}',
                                                style: GoogleFont.Mulish(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppColor.white,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Image.asset(
                                                AppImages.starImage,
                                                height: 9,
                                              ),
                                              const SizedBox(width: 5),
                                              Container(
                                                width: 1.5,
                                                height: 11,
                                                color: AppColor.white
                                                    .withOpacity(0.4),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                '${shop?.reviewCount ?? ''}',
                                                style: GoogleFont.Mulish(
                                                  fontSize: 12,
                                                  color: AppColor.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${shop?.openLabel ?? ''}',
                                          style: GoogleFont.Mulish(
                                            fontSize: 10,
                                            color: AppColor.lightGray2,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 40),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  onTap: () {
                                    final url = shop?.imageUrl?.toString() ?? '';
                                    if (url.trim().isEmpty) return;
                                    FullScreenImageGallery.open(
                                      context,
                                      imageUrls: [url],
                                      initialIndex: 0,
                                      heroTagPrefix: 'smart_connect_${index}_shop',
                                    );
                                  },
                                  child: Hero(
                                    tag: 'smart_connect_${index}_shop_0',
                                    child: CachedNetworkImage(
                                      imageUrl: shop?.imageUrl?.toString() ?? '',
                                      height: 111,
                                      width: 99,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                            child: Icon(Icons.error, size: 20),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: GestureDetector(
                          onTap: () {
                            print('Hi');
                          },
                          child: CommonContainer.callNowButton(
                            callOnTap: () {
                              MapUrls.openDialer(context, shop?.phone);
                            },
                            callImage: AppImages.callImage,
                            callText: 'Call Now',
                            callIconSize: 16,
                            callTextSize: 16,
                            callNowPadding: const EdgeInsets.symmetric(
                              horizontal: 65,
                              vertical: 10,
                            ),
                            messageContainer: true,
                            MessageIcon: false,
                            whatsAppIcon: true,
                            messageOnTap: () {},
                            messagesIconSize: 25,
                            whatsAppIconSize: 25,
                            whatsAppOnTap: () {
                              MapUrls.openWhatsapp(
                                context: context,
                                phone: shop?.alternatePhone?.toString() ?? '',
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ----------------------
/// SKELETON CARD
/// ----------------------
class _ResponseCardSkeleton extends StatelessWidget {
  const _ResponseCardSkeleton();

  @override
  Widget build(BuildContext context) {
    BoxDecoration box() => BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(10),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 18, width: 180, decoration: box()),
          const SizedBox(height: 10),
          Container(height: 12, width: double.infinity, decoration: box()),
          const SizedBox(height: 6),
          Container(height: 12, width: 220, decoration: box()),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => Container(
                width: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(height: 36, width: 130, decoration: box()),
              const SizedBox(width: 12),
              Expanded(child: Container(height: 36, decoration: box())),
            ],
          ),
        ],
      ),
    );
  }
}

/// ----------------------
/// ERROR VIEW
/// ----------------------
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          child: Row(
            children: [
              CommonContainer.leftSideArrow(
                Color: Colors.transparent,
                onTap: onBack,
              ),
              const SizedBox(width: 20),
              Text(
                "Replies",
                style: GoogleFont.Mulish(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 46),
                  const SizedBox(height: 10),
                  Text(
                    "Something went wrong",
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFont.Mulish(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ----------------------
/// EMPTY VIEW
/// ----------------------
class _EmptyView extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const _EmptyView({
    required this.title,
    required this.subtitle,
    required this.onRetry,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          child: Row(
            children: [
              CommonContainer.leftSideArrow(
                Color: Colors.transparent,
                onTap: onBack,
              ),
              const SizedBox(width: 20),
              Text(
                "Replies",
                style: GoogleFont.Mulish(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined, size: 46),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: GoogleFont.Mulish(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFont.Mulish(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
