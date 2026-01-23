import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class EnterReview extends StatefulWidget {
  const EnterReview({super.key});

  @override
  State<EnterReview> createState() => _EnterReviewState();
}

class _EnterReviewState extends State<EnterReview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _rating = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  borderRadius: BorderRadius.only(
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
                                  Image.asset(
                                    AppImages.shopContainer3,
                                    height: 130,
                                    width: 115,
                                  ),

                                  // ClipRRect(
                                  //   borderRadius: BorderRadius.circular(16),
                                  //   child:
                                  //   CachedNetworkImage(
                                  //     imageUrl: AppImages.shopContainer3,
                                  //     height: 100,
                                  //     width: 100,
                                  //     fit: BoxFit.cover,
                                  //
                                  //     placeholder: (context, url) =>
                                  //         const SizedBox(
                                  //           height: 100,
                                  //           width: 100,
                                  //           child: Center(
                                  //             child: CircularProgressIndicator(
                                  //               strokeWidth: 2,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //     errorWidget: (context, url, error) =>
                                  //         ClipRRect(
                                  //           borderRadius: BorderRadius.circular(
                                  //             16,
                                  //           ),
                                  //           child: Container(
                                  //             height: 100,
                                  //             width: 100,
                                  //             color: Colors
                                  //                 .grey
                                  //                 .shade300,
                                  //             child:   Icon(
                                  //               Icons.broken_image,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //   ),
                                  // ),
                                  SizedBox(width: 14),
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
                                            'Zam Zam Sweets',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFont.Mulish(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              color: AppColor.darkBlue,
                                            ),
                                          ),
                                          SizedBox(height: 6),

                                          Row(
                                            children: [
                                              Image.asset(
                                                AppImages.locationImage,
                                                height: 10,
                                                color: AppColor.lightGray2,
                                              ),
                                              SizedBox(width: 3),
                                              Flexible(
                                                child: Text(
                                                  '12, 2, Tirupparankunram Rd, kunram ',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFont.Mulish(
                                                    fontSize: 12,
                                                    color: AppColor.lightGray2,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '5Kms',
                                                style: GoogleFont.Mulish(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: AppColor.lightGray3,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),

                                          Row(
                                            children: [
                                              CommonContainer.greenStarRating(
                                                ratingStar: '4.5',
                                                ratingCount: '16',
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Opens Upto ',
                                                style: GoogleFont.Mulish(
                                                  fontSize: 9,
                                                  color: AppColor.lightGray2,
                                                ),
                                              ),
                                              Text(
                                                '9Pm',
                                                style: GoogleFont.Mulish(
                                                  fontSize: 9,
                                                  color: AppColor.lightGray2,
                                                  fontWeight: FontWeight.w800,
                                                ),
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
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ReceiveScreen(),
                        //   ),
                        // );
                      },
                      text: Text('Submit Review'),
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
