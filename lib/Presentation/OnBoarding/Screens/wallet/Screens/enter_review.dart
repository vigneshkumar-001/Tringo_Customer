import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../Core/Moderation/review_moderation.dart';
import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../../Shop Screen/Controller/shops_notifier.dart';
import '../Controller/wallet_notifier.dart';

class EnterReview extends ConsumerStatefulWidget {
  final String? shopId;
  const EnterReview({super.key, this.shopId});

  @override
  ConsumerState<EnterReview> createState() => _EnterReviewState();
}

class _EnterReviewState extends ConsumerState<EnterReview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(shopsNotifierProvider.notifier)
          .showSpecificShopDetails(shopId: widget.shopId ?? '');

      ref.listen<WalletState>(walletNotifier, (prev, next) {
        final res = next.reviewCreateResponse;

        if (res != null && res.status == true) {
          AppSnackBar.success(
            context,
            res.data.note == "ALREADY_REVIEWED_UPDATED_ONLY"
                ? "Review updated "
                : "Review submitted ",
          );

          _headingController.clear();
          _descriptionController.clear();
          setState(() => _rating = 0);

          Navigator.pop(context);
        }

        if (next.error != null && next.error!.isNotEmpty) {
          AppSnackBar.error(context, next.error!);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _headingController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _ensureReviewTermsAccepted() async {
    if (await ReviewModeration.hasAcceptedTerms()) return true;
    if (!mounted) return false;

    var checked = false;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Review Terms'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You must be 18+ to post reviews. TringoBiz does not tolerate objectionable content or abusive users.',
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Do not post abusive, hateful, threatening, sexually explicit, spam, fraudulent, illegal, or harassing content.',
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Users can report, hide, and block review authors. Reports are reviewed within 24 hours and offending content or users may be removed.',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Report inappropriate activity from ${ReviewModeration.supportContactLabel}.',
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: checked,
                      onChanged: (value) {
                        setDialogState(() => checked = value ?? false);
                      },
                      title: const Text('I agree to these review terms'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: checked
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  child: const Text('Agree'),
                ),
              ],
            );
          },
        );
      },
    );

    if (accepted == true) {
      await ReviewModeration.acceptTerms();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifier);

    final state = ref.watch(shopsNotifierProvider);
    final shopsData = state.shopDetailsResponse;
    final shop = shopsData?.data;
    final isShopLoading = state.isLoading && shop == null;

    final shopImageUrl = (shop?.media.isNotEmpty == true)
        ? shop!.media.first.url
        : "";

    final isSubmitting = walletState.isMsgSendingLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonContainer.leftSideArrow(
                        Color: AppColor.whiteSmoke,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Write Review',
                      style: GoogleFont.Mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
              ),
              if (isShopLoading) ...[
                const SizedBox(height: 30),
                ThreeDotsLoader(dotColor: AppColor.darkBlue),
                const SizedBox(height: 30),
              ] else ...[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppImages.walletBCImage),
                    ),
                    gradient: LinearGradient(
                      colors: [AppColor.white, AppColor.surfaceAqua],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: shopImageUrl,
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const SizedBox(
                                              height: 100,
                                              width: 100,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Container(
                                                height: 100,
                                                width: 100,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 50.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              shop?.englishName?.toString() ??
                                                  "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFont.Mulish(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: AppColor.darkBlue,
                                              ),
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
                                                Flexible(
                                                  child: Text(
                                                    "${shop?.addressEn ?? ""}",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFont.Mulish(
                                                      fontSize: 12,
                                                      color:
                                                          AppColor.lightGray2,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  shop?.distanceLabel
                                                          ?.toString() ??
                                                      "",
                                                  style: GoogleFont.Mulish(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: AppColor.lightGray3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 6,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                CommonContainer.greenStarRating(
                                                  ratingStar:
                                                      shop?.averageRating
                                                          ?.toString() ??
                                                      "0",
                                                  ratingCount:
                                                      shop?.reviewCount
                                                          ?.toString() ??
                                                      "0",
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Opens Upto ',
                                                      style: GoogleFont.Mulish(
                                                        fontSize: 9,
                                                        color:
                                                            AppColor.lightGray2,
                                                      ),
                                                    ),
                                                    Text(
                                                      shop?.closeTime ?? "",
                                                      style: GoogleFont.Mulish(
                                                        fontSize: 9,
                                                        color:
                                                            AppColor.lightGray2,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
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
              ],
              // Container(
              //   decoration: BoxDecoration(
              //     image: DecorationImage(
              //       image: AssetImage(AppImages.walletBCImage),
              //     ),
              //     gradient: LinearGradient(
              //       colors: [AppColor.white, AppColor.surfaceAqua],
              //       begin: Alignment.topCenter,
              //       end: Alignment.bottomCenter,
              //     ),
              //     borderRadius: BorderRadius.only(
              //       bottomLeft: Radius.circular(25),
              //       bottomRight: Radius.circular(25),
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       InkWell(
              //         borderRadius: BorderRadius.circular(24),
              //         onTap: () {},
              //         child: Padding(
              //           padding: const EdgeInsets.symmetric(
              //             horizontal: 20,
              //             vertical: 15,
              //           ),
              //           child: Column(
              //             children: [
              //               Padding(
              //                 padding: const EdgeInsets.symmetric(
              //                   vertical: 15.0,
              //                 ),
              //                 child: Row(
              //                   children: [
              //                     // Image.asset(
              //                     //   AppImages.shopContainer3,
              //                     //   height: 130,
              //                     //   width: 115,
              //                     // ),
              //                     ClipRRect(
              //                       borderRadius: BorderRadius.circular(16),
              //                       child: CachedNetworkImage(
              //                         imageUrl: shopImageUrl,
              //                         height: 100,
              //                         width: 100,
              //                         fit: BoxFit.cover,
              //
              //                         placeholder: (context, url) =>
              //                             const SizedBox(
              //                               height: 100,
              //                               width: 100,
              //                               child: Center(
              //                                 child: CircularProgressIndicator(
              //                                   strokeWidth: 2,
              //                                 ),
              //                               ),
              //                             ),
              //                         errorWidget: (context, url, error) =>
              //                             ClipRRect(
              //                               borderRadius: BorderRadius.circular(
              //                                 16,
              //                               ),
              //                               child: Container(
              //                                 height: 100,
              //                                 width: 100,
              //                                 color: Colors.grey.shade300,
              //                                 child: Icon(Icons.broken_image),
              //                               ),
              //                             ),
              //                       ),
              //                     ),
              //                     SizedBox(width: 14),
              //                     Expanded(
              //                       child: Padding(
              //                         padding: const EdgeInsets.only(
              //                           right: 50.0,
              //                         ),
              //                         child: Column(
              //                           crossAxisAlignment:
              //                               CrossAxisAlignment.start,
              //                           children: [
              //                             Text(
              //                               shop?.englishName?.toString() ?? "",
              //                               maxLines: 1,
              //                               overflow: TextOverflow.ellipsis,
              //                               style: GoogleFont.Mulish(
              //                                 fontWeight: FontWeight.w800,
              //                                 fontSize: 16,
              //                                 color: AppColor.darkBlue,
              //                               ),
              //                             ),
              //                             const SizedBox(height: 6),
              //
              //                             Row(
              //                               children: [
              //                                 Image.asset(
              //                                   AppImages.locationImage,
              //                                   height: 10,
              //                                   color: AppColor.lightGray2,
              //                                 ),
              //                                 const SizedBox(width: 3),
              //
              //                                 Flexible(
              //                                   child: Text(
              //                                     "${shop?.addressEn ?? ""}",
              //                                     maxLines: 1,
              //                                     overflow:
              //                                         TextOverflow.ellipsis,
              //                                     style: GoogleFont.Mulish(
              //                                       fontSize: 12,
              //                                       color: AppColor.lightGray2,
              //                                     ),
              //                                   ),
              //                                 ),
              //
              //                                 const SizedBox(width: 5),
              //                                 Text(
              //                                   shop?.distanceLabel
              //                                           ?.toString() ??
              //                                       "",
              //                                   style: GoogleFont.Mulish(
              //                                     fontWeight: FontWeight.bold,
              //                                     fontSize: 12,
              //                                     color: AppColor.lightGray3,
              //                                   ),
              //                                 ),
              //                               ],
              //                             ),
              //
              //                             const SizedBox(height: 10),
              //
              //                             Row(
              //                               children: [
              //                                 CommonContainer.greenStarRating(
              //                                   ratingStar:
              //                                       shop?.averageRating
              //                                           ?.toString() ??
              //                                       "0",
              //                                   ratingCount:
              //                                       shop?.reviewCount
              //                                           ?.toString() ??
              //                                       "0",
              //                                 ),
              //
              //                                 const SizedBox(width: 10),
              //
              //                                 Text(
              //                                   'Opens Upto ',
              //                                   style: GoogleFont.Mulish(
              //                                     fontSize: 9,
              //                                     color: AppColor.lightGray2,
              //                                   ),
              //                                 ),
              //                                 Text(
              //                                   shop?.closeTime ?? "",
              //                                   style: GoogleFont.Mulish(
              //                                     fontSize: 9,
              //                                     color: AppColor.lightGray2,
              //                                     fontWeight: FontWeight.w800,
              //                                   ),
              //                                 ),
              //                               ],
              //                             ),
              //                           ],
              //                         ),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 40),
              Text(
                'Give Stars',
                style: GoogleFont.Mulish(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColor.darkBlue,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final isSelected = index < _rating;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },

                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Image.asset(
                          AppImages.starImage,
                          height: 35,
                          color: isSelected
                              ? AppColor.green
                              : AppColor.borderGray,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Review Heading',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _headingController,
                      decoration: InputDecoration(
                        hintText: "",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 25),
                    Text(
                      'Review Description',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: "",
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 30,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

                    CommonContainer.button(
                      buttonColor: AppColor.darkBlue,
                      onTap: isSubmitting
                          ? null
                          : () async {
                              final heading = _headingController.text.trim();
                              final comment = _descriptionController.text
                                  .trim();

                              if (_rating == 0) {
                                AppSnackBar.error(
                                  context,
                                  "Please select rating ⭐",
                                );
                                return;
                              }

                              if (heading.isEmpty) {
                                AppSnackBar.error(context, "Enter heading");
                                return;
                              }

                              if (comment.isEmpty) {
                                AppSnackBar.error(context, "Enter description");
                                return;
                              }

                              if (ReviewModeration.containsObjectionableText(
                                '$heading $comment',
                              )) {
                                AppSnackBar.error(
                                  context,
                                  "Review contains objectionable or abusive content",
                                );
                                return;
                              }

                              final accepted =
                                  await _ensureReviewTermsAccepted();
                              if (!accepted) return;
                              if (!context.mounted) return;

                              await ref
                                  .read(walletNotifier.notifier)
                                  .reviewCreate(
                                    shopId: widget.shopId ?? "",
                                    rating: _rating,
                                    heading: heading,
                                    comment: comment,
                                  );
                            },
                      text: isSubmitting
                          ? const Text("Submitting...")
                          : const Text("Submit Review"),
                      imagePath: AppImages.rightSideArrow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
