import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart'; // needed by CommonContainer if used there
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/Widgets/owner_verify_feild.dart';

import '../../Home Screen/Screens/home_screen.dart';
import '../Controller/edit_profile_notifier.dart';

class EditProfile extends ConsumerStatefulWidget {
  final String? name;
  final String? phone;
  final String? email;
  final String? gender;
  final String? url;
  final String? dob;

  const EditProfile({
    super.key,
    this.name,
    this.phone,
    this.email,
    this.gender,
    this.dob,
    this.url,
  });

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController mobileController;
  late final TextEditingController genderController;
  late final TextEditingController dateOfBirthController;
  late final TextEditingController profilePhotoController;

  XFile? selectedPhoto;
  final ImagePicker _picker = ImagePicker();

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

  /// ✅ Converts "1-1-2000" or "01-1-2000" -> "2000-01-01"
  /// Keeps "1995-08-15" as is.
  String normalizeDob(String? dob) {
    if (dob == null || dob.trim().isEmpty) return '';
    final s = dob.trim();

    // already ISO yyyy-MM-dd
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) return s;

    // if backend sends ISO datetime: 2000-01-01T00:00:00Z
    final isoDateTimeMatch = RegExp(r'^(\d{4}-\d{2}-\d{2})').firstMatch(s);
    if (isoDateTimeMatch != null) return isoDateTimeMatch.group(1)!;

    // dd-MM-yyyy or d-M-yyyy etc
    final parts = s.split(RegExp(r'[-/]'));
    if (parts.length == 3) {
      final d = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      final y = parts[2].padLeft(4, '0');
      if (y.length == 4) return "$y-$m-$d";
    }

    return s; // fallback
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
  void initState() {
    super.initState();

    AppLogger.log.i("EditProfile url => ${widget.url}");
    AppLogger.log.i("EditProfile dob => ${widget.dob}");

    nameController = TextEditingController(text: widget.name ?? '');
    mobileController = TextEditingController(text: widget.phone ?? '');
    emailController = TextEditingController(text: widget.email ?? '');
    genderController = TextEditingController(text: widget.gender ?? '');

    // ✅ normalize incoming dob to yyyy-MM-dd
    dateOfBirthController = TextEditingController(
      text: normalizeDob(widget.dob),
    );

    profilePhotoController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    profilePhotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileNotifierProvider);
    final editNotifier = ref.watch(editProfileNotifierProvider.notifier);

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
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 20),
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
                const SizedBox(height: 30),

                CommonContainer.fillProfileContainer(
                  controller: nameController,
                  hint: 'Enter Name',
                  rightLabel: 'Name',
                ),
                const SizedBox(height: 20),

                CommonContainer.fillProfileContainer(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  hint: 'Enter Email Id',
                  rightLabel: 'Email Id',
                ),
                const SizedBox(height: 20),

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
                          .read(editProfileNotifierProvider.notifier)
                          .changeNumberRequest(
                            type: "CUSTOMER_PHONE_CHANGE",
                            phoneNumber: phone10,
                          );
                    },
                    onVerifyOtp: (mobile, otp) {
                      final phone10 = _normalizeIndianPhone10(mobile);
                      return ref
                          .read(editProfileNotifierProvider.notifier)
                          .changeOtpRequest(
                            phoneNumber: phone10,
                            type: "CUSTOMER_PHONE_CHANGE",
                            code: otp,
                          );
                    },
                  ),
                ),
                const SizedBox(height: 20),

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
                                genderController.text = "MALE"; // ✅ send MALE
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
                                genderController.text =
                                    "FEMALE"; // ✅ send FEMALE
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
                                genderController.text = "OTHER";
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                CommonContainer.fillProfileContainer(
                  controller: dateOfBirthController,
                  hint: 'YYYY-MM-DD',
                  rightIcon: AppImages.dateOfBirth,
                  iconHeight: 20,
                  rightLabel: 'Date Of Birth',
                  readOnly: true,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (picked != null) {
                      final y = picked.year.toString().padLeft(4, '0');
                      final m = picked.month.toString().padLeft(2, '0');
                      final d = picked.day.toString().padLeft(2, '0');
                      dateOfBirthController.text = "$y-$m-$d"; // ✅ ISO format
                    }
                  },
                ),
                const SizedBox(height: 20),

                // ✅ Preview inside this field (local OR network)
                CommonContainer.fillProfileContainer(
                  controller: profilePhotoController,
                  hint: 'Change Photo',
                  rightIcon: AppImages.uploadPhoto,
                  rightLabel: 'Profile Photo',
                  selectedImage: selectedPhoto?.path,
                  networkImageUrl: widget.url,
                  onTap: _showProfileImageSourcePicker,
                ),

                const SizedBox(height: 35),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColor.textWhite,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
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
                    const SizedBox(width: 15),

                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: state.isLoading
                            ? null
                            : () async {
                                // ✅ validate DOB format before API
                                final dob = dateOfBirthController.text.trim();
                                final isIso = RegExp(
                                  r'^\d{4}-\d{2}-\d{2}$',
                                ).hasMatch(dob);
                                if (!isIso) {
                                  AppSnackBar.error(
                                    context,
                                    "DOB must be YYYY-MM-DD",
                                  );
                                  return;
                                }

                                final File? imageFile =
                                    (selectedPhoto != null &&
                                        selectedPhoto!.path.isNotEmpty)
                                    ? File(selectedPhoto!.path)
                                    : null;

                                final ok = await editNotifier.editProfile(
                                  displayName: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  gender: genderController.text.trim(),
                                  dateOfBirth: dob,
                                  ownerImageFile: imageFile,
                                  phoneNumber: mobileController.text.trim(),
                                );

                                if (!context.mounted) return;

                                if (ok) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HomeScreen(),
                                    ),
                                  );
                                } else {
                                  CustomSnackBar.error(
                                    message: state.error.toString() ?? '',
                                  );
                                }
                              },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColor.blue,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Opacity(
                                opacity: state.isLoading ? 0 : 1,
                                child: Text(
                                  'Save Changes',
                                  style: GoogleFont.Mulish(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColor.white,
                                  ),
                                ),
                              ),
                              if (state.isLoading)
                                const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
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

/*
class EditProfile extends ConsumerStatefulWidget {
  final String? name;
  final String? phone;
  final String? email;
  final String? gender;
  final String? url;
  final String? dob;
  const EditProfile({
    super.key,
    this.name,
    this.phone,
    this.email,
    this.gender,
    this.dob,
    this.url,
  });

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
  void initState() {
    super.initState();
    AppLogger.log.i(widget.name);
    nameController = TextEditingController(text: widget.name ?? '');
    mobileController = TextEditingController(text: widget.phone ?? '');
    emailController = TextEditingController(text: widget.email ?? '');
    genderController = TextEditingController(text: widget.gender ?? '');
    dateOfBirthController = TextEditingController(text: widget.dob ?? '');
    profilePhotoController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    genderController.dispose();
    dateOfBirthController.dispose();
    profilePhotoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileNotifierProvider);
    final editNotifier = ref.watch(editProfileNotifierProvider.notifier);
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
                              .read(editProfileNotifierProvider.notifier)
                              .changeNumberRequest(
                                type: "CUSTOMER_PHONE_CHANGE",
                                phoneNumber: phone10,
                              );
                        },
                        onVerifyOtp: (mobile, otp) {
                          final phone10 = _normalizeIndianPhone10(mobile);
                          return ref
                              .read(editProfileNotifierProvider.notifier)
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
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 34,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.textWhite,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
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
                        ),

                        SizedBox(width: 15),

                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: state.isLoading
                                ? null
                                : () async {
                                    final File? imageFile =
                                        (selectedPhoto != null)
                                        ? File(selectedPhoto!.path)
                                        : null;

                                    final ok = await editNotifier.editProfile(
                                      displayName: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      gender: genderController.text.trim(),
                                      dateOfBirth: dateOfBirthController.text
                                          .trim(),
                                      ownerImageFile: imageFile,
                                      phoneNumber: mobileController.text.trim(),
                                    );

                                    if (!context.mounted) return;

                                    if (ok) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => HomeScreen(),
                                        ),
                                      );
                                    } else {
                                      // optional: show error
                                      AppSnackBar.error(
                                        context,
                                        state.error ?? '',
                                      );
                                    }
                                  },

                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.blue,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: state.isLoading
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: AppLoader.circularLoader(),
                                    )
                                  : Text(
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
*/
