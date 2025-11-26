import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';

import '../../../../Core/Utility/app_Images.dart';
import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/google_font.dart';
import '../Home Screen/home_screen.dart';

class FillProfile extends StatefulWidget {
  const FillProfile({super.key});

  @override
  State<FillProfile> createState() => _FillProfileState();
}

class _FillProfileState extends State<FillProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController profilePhotoController = TextEditingController();

  XFile? selectedPhoto;

  @override
  Widget build(BuildContext context) {
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
                                context: context,
                                builder: (_) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text("Male"),
                                        onTap: () {
                                          genderController.text = "Male";
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text("Female"),
                                        onTap: () {
                                          genderController.text = "Female";
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        title: Text("Other"),
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
                              );

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
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );

                              if (image != null) {
                                setState(() {
                                  selectedPhoto = image;
                                  profilePhotoController.text =
                                      "Photo Selected";
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 35),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            },
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
                                  'Skip',
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
                            onTap: () async {
                              // VALIDATION
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  genderController.text.isEmpty ||
                                  dateOfBirthController.text.isEmpty ||
                                  selectedPhoto == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Please fill all fields"),
                                  ),
                                );
                                return;
                              }

                              // SAVE COMPLETED STATUS
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setBool("isProfileCompleted", true);

                              // NAVIGATE TO HOME
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              );
                            },

                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => HomeScreen(),
                            //     ),
                            //   );
                            // },
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
                                child: Text(
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
