import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/app_go_routes.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/fill_profile/Controller/profile_notifier.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Utility/app_color.dart';
import '../../../../../Core/Utility/app_loader.dart';
import '../../../../../Core/Utility/app_snackbar.dart';
import '../../../../../Core/Utility/google_font.dart';
import '../../Home Screen/Screens/home_screen.dart';

class FillProfile extends ConsumerStatefulWidget {
  const FillProfile({super.key});

  @override
  ConsumerState<FillProfile> createState() => _FillProfileState();
}

class _FillProfileState extends ConsumerState<FillProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController profilePhotoController = TextEditingController();

  XFile? selectedPhoto;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _checkProfileStatus();
  }

  Future<void> _checkProfileStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool("isProfileCompleted") ?? false;

    if (isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.homePath);
      });
    }
  }

  final ImagePicker _picker = ImagePicker();
  List<File?> _pickedImages = List<File?>.filled(4, null);
  List<bool> _hasError = List<bool>.filled(4, false);

  void _showImageSourcePicker(int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromSource(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(int index, ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _pickedImages[index] = File(pickedFile.path);
      _hasError[index] = false;
    });
  }

  void _showProfileImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      selectedPhoto = pickedFile;
                      profilePhotoController.text = "Photo Selected";
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      selectedPhoto = pickedFile;
                      profilePhotoController.text = "Photo Selected";
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset(
              AppImages.loginBCImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 50),
                      child: Image.asset(AppImages.logo, height: 88, width: 85),
                    ),

                    SizedBox(height: 50),

                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Fill',
                                style: GoogleFont.Mulish(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'your additional',
                                style: GoogleFont.Mulish(
                                  fontSize: 24,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'details in this form',
                            style: GoogleFont.Mulish(
                              fontSize: 24,
                              color: AppColor.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Column(
                        children: [
                          CommonContainer.fillProfileContainer(
                            controller: nameController,
                            hint: 'Enter Name',
                            rightLabel: 'Name',
                          ),
                          SizedBox(height: 15),
                          CommonContainer.fillProfileContainer(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            hint: 'Enter Email Id',
                            rightLabel: 'Email Id',
                          ),
                          SizedBox(height: 20),
                          CommonContainer.fillProfileContainer(
                            controller: genderController,
                            hint: 'Select Gender',
                            rightIcon: AppImages.drapDownImage,
                            rightLabel: 'Gender',
                            onTap: () {
                              showModalBottomSheet(
                                backgroundColor: AppColor.white,
                                context: context,
                                builder: (_) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          "Male",
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onTap: () {
                                          genderController.text = "Male";
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text(
                                          "Female",
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onTap: () {
                                          genderController.text = "Female";
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text(
                                          "Other",
                                          style: GoogleFont.Mulish(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onTap: () {
                                          genderController.text = "Other";
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                          SizedBox(height: 15),
                          CommonContainer.fillProfileContainer(
                            controller: dateOfBirthController,
                            hint: 'Enter D.O.B',
                            rightIcon: AppImages.dateOfBirth,
                            iconHeight: 20,
                            rightLabel: 'Date Of Birth',
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(2000),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors
                                            .blue, // Header background (month/year)
                                        onPrimary:
                                            Colors.white, // Header text color
                                        surface:
                                            Colors.white, // Calendar background
                                        onSurface:
                                            Colors.black, // Calendar text color
                                      ),
                                      dialogBackgroundColor:
                                          Colors.white, // Popup background
                                    ),
                                    child: child!,
                                  );
                                },
                              );

                              // final picked = await showDatePicker(
                              //   context: context,
                              //   initialDate: DateTime(2000),
                              //   firstDate: DateTime(1950),
                              //   lastDate: DateTime.now(),
                              // );

                              if (picked != null) {
                                dateOfBirthController.text =
                                    "${picked.day}-${picked.month}-${picked.year}";
                              }
                            },
                          ),

                          SizedBox(height: 15),
                          CommonContainer.fillProfileContainer(
                            controller: profilePhotoController,
                            hint: 'Upload Profile Pic',
                            rightLabel: 'Profile Photo',
                            selectedImage: selectedPhoto?.path,
                            onTap: () {
                              _showProfileImageSourcePicker();
                            },
                            // onTap: () async {
                            //   final ImagePicker picker = ImagePicker();
                            //
                            //   final XFile? image = await picker.pickImage(
                            //     source: ImageSource.gallery,
                            //   );
                            //
                            //   if (image != null) {
                            //     setState(() {
                            //       selectedPhoto = image;
                            //       profilePhotoController.text =
                            //           "Photo Selected";
                            //     });
                            //   }
                            // },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        children: [
                          // InkWell(
                          //   borderRadius: BorderRadius.circular(15),
                          //   onTap: () {
                          //     if (_navigated) return;
                          //     Navigator.pushReplacement(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => HomeScreen(),
                          //       ),
                          //     );
                          //   },
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //       color: AppColor.textWhite,
                          //       borderRadius: BorderRadius.circular(15),
                          //     ),
                          //     child: Padding(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 34,
                          //         vertical: 20,
                          //       ),
                          //       child: Text(
                          //         'Skip',
                          //         style: GoogleFont.Mulish(
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.w800,
                          //           color: AppColor.darkBlue,
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              if (_navigated) return;
                              _navigated = true;

                              context.go(AppRoutes.homePath);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.textWhite,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 34,
                                vertical: 20,
                              ),
                              child: Text(
                                'Skip',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15),

                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () async {
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  genderController.text.isEmpty ||
                                  dateOfBirthController.text.isEmpty ||
                                  selectedPhoto == null) {
                                AppSnackBar.info(
                                  context,
                                  'Please fill all fields',
                                );

                                return;
                              }

                              String dobForApi = '';
                              try {
                                final parsedDate = DateFormat('dd-MM-yyyy')
                                    .parseStrict(
                                      dateOfBirthController.text.trim(),
                                    );
                                dobForApi = DateFormat(
                                  'yyyy-MM-dd',
                                ).format(parsedDate);
                              } catch (e) {
                                AppSnackBar.error(context, "Invalid DOB");
                                return;
                              }

                              final response = await ref
                                  .read(profileNotifierProvider.notifier)
                                  .fetchProfile(
                                    displayName: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    gender: genderController.text.trim(),
                                    dateOfBirth: dobForApi,
                                    ownerImageFile: File(selectedPhoto!.path),
                                  );
                              final notifier = ref.read(
                                profileNotifierProvider.notifier,
                              );
                              if (response != null) {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setBool("isProfileCompleted", true);

                                context.go(AppRoutes.homePath);
                                // final prefs =
                                //     await SharedPreferences.getInstance();
                                await prefs.setBool("isProfileCompleted", true);
                              } else if (state.error != null) {
                                AppSnackBar.error(context, state.error ?? '');
                              }
                            },

                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.blue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 65,
                                  vertical: 20,
                                ),
                                child: state.isLoading
                                    ? ThreeDotsLoader()
                                    : Text(
                                        'Continue',
                                        style: GoogleFont.Mulish(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: AppColor.white,
                                        ),
                                      ),
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
    );
  }
}
