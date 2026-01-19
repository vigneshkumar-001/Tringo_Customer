import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';

import '../../../../../Core/Utility/app_Images.dart';
import '../../../../../Core/Widgets/owner_verify_feild.dart';
import '../Controller/edit_profile_notifier.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController profilePhotoController = TextEditingController();

  XFile? selectedPhoto;
  bool _navigated = false;

  final ImagePicker _picker = ImagePicker();
  List<File?> _pickedImages = List<File?>.filled(4, null);
  List<bool> _hasError = List<bool>.filled(4, false);

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

  String _normalizeIndianPhone10(String input) {
    var p = input.trim();
    p = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (p.startsWith('91') && p.length == 12) {
      p = p.substring(2);
    }
    if (p.length > 10) {
      p = p.substring(p.length - 10);
    }
    return p;
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
    final state = ref.watch(shopCategoryNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CommonContainer.leftSideArrow(
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Edit Profile',
                      style: GoogleFont.Mulish(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColor.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Column(
                  children: [
                    CommonContainer.fillProfileContainer(
                      controller: nameController,
                      hint: 'Enter Name',
                      rightLabel: 'Name',
                    ),
                    SizedBox(height: 20),
                    CommonContainer.fillProfileContainer(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      hint: 'Enter Email Id',
                      rightLabel: 'Email Id',
                    ),
                    SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: OwnerVerifyField(
                        controller: mobileController,
                        isLoading: state.isSendingOtp,
                        isOtpVerifying: state.isVerifyingOtp,
                        onSendOtp: (mobile) {
                          final phone10 = _normalizeIndianPhone10(mobile);
                          return ref
                              .read(shopCategoryNotifierProvider.notifier)
                              .changeNumberRequest(
                                type: "CUSTOMER_PHONE_CHANGE",
                                phoneNumber: phone10,
                              );
                        },
                        onVerifyOtp: (mobile, otp) {
                          final phone10 = _normalizeIndianPhone10(mobile);
                          return ref
                              .read(shopCategoryNotifierProvider.notifier)
                              .changeOtpRequest(
                                phoneNumber: phone10,
                                type: "CUSTOMER_PHONE_CHANGE",
                                code: otp,
                              );
                        },
                      ),
                    ),

                    // AnimatedSwitcher(
                    //   duration: const Duration(milliseconds: 400),
                    //   transitionBuilder: (child, animation) =>
                    //       FadeTransition(opacity: animation, child: child),
                    //   child: OwnerVerifyField(
                    //     controller: mobileController,
                    //     // isLoading: state.isSendingOtp,
                    //     // isOtpVerifying: state.isVerifyingOtp,
                    //     // onSendOtp: (mobile) {
                    //     //   return ref
                    //     //       .read(addEmployeeNotifier.notifier)
                    //     //       .employeeAddNumberRequest(
                    //     //     phoneNumber: mobile,
                    //     //   );
                    //     // },
                    //     // onVerifyOtp: (mobile, otp) {
                    //     //   return ref
                    //     //       .read(addEmployeeNotifier.notifier)
                    //     //       .employeeAddOtpRequest(
                    //     //     phoneNumber: mobile,
                    //     //     code: otp,
                    //     //   );
                    //     // },
                    //   ),
                    // ),
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

                    SizedBox(height: 20),
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
                                  onPrimary: Colors.white, // Header text color
                                  surface: Colors.white, // Calendar background
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

                    SizedBox(height: 20),
                    CommonContainer.fillProfileContainer(
                      controller: profilePhotoController,
                      hint: 'Change Photo',
                      rightIcon: AppImages.uploadPhoto,
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
                    SizedBox(height: 35),
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {},
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.textWhite,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 34,
                                vertical: 20,
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFont.Mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColor.darkBlue,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 15),

                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => HomeScreen(),
                            //   ),
                            // );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.blue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 55,
                                vertical: 20,
                              ),
                              child: Text(
                                'Save Changes',
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
