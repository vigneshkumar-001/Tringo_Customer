import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Controller/smart_connect_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Smart%20Connect/Screens/smart_connect_history.dart';

import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../../../../Core/Widgets/common_container.dart';

class CreateSmartConnect extends ConsumerStatefulWidget {
  final String? title;
  final String? listingId;
  final String? listingType;
  final String? shopId;

  const CreateSmartConnect({
    super.key,
    this.title,
    this.listingId,
    this.listingType,
    this.shopId,
  });

  @override
  ConsumerState<CreateSmartConnect> createState() => _CreateSmartConnectState();
}

class _CreateSmartConnectState extends ConsumerState<CreateSmartConnect> {
  final _productController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _focusNode = FocusNode();
  Timer? _debounce;
  List<_Suggest> _view = [];

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    setState(() {
      _view = const [];
    });
  }

  @override
  void dispose() {
    _productController.dispose();
    _descriptionController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _productController.text = widget.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(smartConnectNotifierProvider.notifier);
    final state = ref.watch(smartConnectNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Create Smart Connect',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text(
                  'Product',
                  style: GoogleFont.Mulish(
                    fontSize: 16,
                    color: AppColor.darkBlue,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white, // Background color
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColor.borderGray, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.05,
                        ), // subtle outer shadow
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        readOnly: true,
                        controller: _productController,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          hintText: 'Search...',
                          border: InputBorder.none,
                          hintStyle: GoogleFont.Mulish(
                            color: AppColor.lightGray,
                            fontSize: 16,
                          ),
                          // suffixIcon: _controller.text.isNotEmpty
                          //     ? IconButton(
                          //         icon: const Icon(Icons.clear, size: 18),
                          //         onPressed: () {
                          //           _controller.clear();
                          //           _onChanged('');
                          //           setState(() {});
                          //         },
                          //       )
                          //     : null,
                        ),
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.black,
                        ),
                      ),
                      // Optional: inner shadow overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColor.mediumBlue.withOpacity(0.05),
                                  Colors.transparent,
                                  AppColor.mediumBlue.withOpacity(0.05),
                                ],
                                stops: [0, 0.4, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /*            if (_view.isNotEmpty)
                  ..._view.map(
                    (s) => Column(
                      children: [
                        ListTile(
                          title: Text(
                            s.title,
                            style: GoogleFont.Mulish(fontSize: 16),
                          ),
                          onTap: () {},
                        ),
                        Divider(),
                      ],
                    ),
                  ),
                if (_view.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'No results',
                      style: GoogleFont.Mulish(color: AppColor.lightGray2),
                    ),
                  ),*/
                SizedBox(height: 30),

                Text(
                  'Description',
                  style: GoogleFont.Mulish(
                    fontSize: 16,
                    color: AppColor.darkBlue,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white, // Background color
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: AppColor.borderGray, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.05,
                        ), // subtle outer shadow
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _descriptionController,
                        focusNode: _focusNode,
                        onChanged: _onChanged,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.search,
                        maxLines: 7,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 25,
                            horizontal: 20,
                          ),

                          hintText: 'Enter Some Details',
                          border: InputBorder.none,
                          hintStyle: GoogleFont.Mulish(
                            color: AppColor.borderGray,
                            fontSize: 14,
                          ),
                          suffixIcon: _descriptionController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _descriptionController.clear();
                                    _onChanged('');
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        style: GoogleFont.Mulish(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColor.black,
                        ),
                      ),
                      // Optional: inner shadow overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(35),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColor.mediumBlue.withOpacity(0.05),
                                  Colors.transparent,
                                  AppColor.mediumBlue.withOpacity(0.05),
                                ],
                                stops: [0, 0.4, 1],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Text(
                      'Upload Images',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        color: AppColor.darkBlue,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '( Optional )',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        color: AppColor.borderGray,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),

                GestureDetector(
                  onTap: _selectedImage == null ? _pickImage : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: AppColor.borderGray,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 15,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedImage == null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      AppImages.galleryImage,
                                      height: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Add Image',
                                      style: GoogleFont.Mulish(
                                        color: AppColor.borderGray,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(
                                              0,
                                              3,
                                            ), // horizontal & vertical shadow offset
                                            blurRadius: 6, // softness of shadow
                                            color: AppColor
                                                .borderGray, // shadow color with opacity
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.file(
                                    _selectedImage!,
                                    height: 90,
                                    width: 190,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ❌ Remove icon (top right)
                        if (_selectedImage != null)
                          Positioned(
                            right: 30,
                            top: 20,
                            child: GestureDetector(
                              onTap: _removeImage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                        // Optional inner gradient overlay
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColor.mediumBlue.withOpacity(0.05),
                                    Colors.transparent,
                                    AppColor.mediumBlue.withOpacity(0.05),
                                  ],
                                  stops: [0, 0.3, 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),
                Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: state.isLoading
                        ? null
                        : () async {
                      final err = await notifier.createSmartConnect(

                        listingId: widget.listingId ?? '',
                        listingType: widget.listingType ?? '',
                        shopId: widget.shopId ?? '',
                        ownerImageFile: _selectedImage,   // ✅ PASS IMAGE
                        description: _descriptionController.text.trim(),
                      );

                      if (!context.mounted) return;
                      if (err == null) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SmartConnectHistory(),
                          ),
                              (route) => route.isFirst, // 👈 keeps only Home
                        );

                        _productController.clear();
                        _descriptionController.clear();

                        setState(() {
                          _selectedImage = null;
                          _view = const [];
                        });
                      }
                   else {
                        AppSnackBar.error(context, err);
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: state.isLoading ? 0 : 1.0, // 👈 value kammi
                          child: Image.asset(AppImages.aiButton, height: 50),
                        ),

                        if (state.isLoading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
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
      ),
    );
  }
}

class _Suggest {
  final String title;
  final String category; // "Mobile" / "Mobile Accessories"
  const _Suggest(this.title, this.category);
}
