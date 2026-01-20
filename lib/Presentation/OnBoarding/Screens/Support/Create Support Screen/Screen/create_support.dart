import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../Core/Utility/app_Images.dart';
import '../../../../../../Core/Utility/app_color.dart';
import '../../../../../../Core/Utility/google_font.dart';
import '../../../../../../Core/Widgets/common_container.dart';
import '../../Support Chat Screen/Screen/support_chat_screen.dart';

class CreateSupport extends StatefulWidget {
  const CreateSupport({super.key});

  @override
  State<CreateSupport> createState() => _CreateSupportState();
}

class _CreateSupportState extends State<CreateSupport>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _subjectCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  final _picker = ImagePicker();
  XFile? _picked;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    setState(() => _picked = x);
  }

  InputDecoration _fieldDeco() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF2F2F2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _showPickOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text('Camera', style: GoogleFont.Mulish()),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromCamera();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: Text('Gallery', style: GoogleFont.Mulish()),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickFromGallery();
                  },
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _picked = x);
  }

  Future<void> _pickFromGallery() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted) return;
    setState(() => _picked = x);
  }

  void _removeImage() {
    setState(() => _picked = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
          
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CommonContainer.leftSideArrow(
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    Text(
                      'Create Support',
                      style: GoogleFont.Mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.mildBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Text(
                  'Subject',
                  style: GoogleFont.Mulish(color: AppColor.mildBlack),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _subjectCtrl,
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                  decoration: _fieldDeco(),
                ),
                SizedBox(height: 25),
                Text(
                  'Description',
                  style: GoogleFont.Mulish(color: AppColor.mildBlack),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descCtrl,
                  maxLines: 8,
                  decoration: _fieldDeco(),
                ),
          
                SizedBox(height: 25),
          
                CommonContainer.containerTitle(
                  context: context,
                  title: 'Upload Photo',
                  image: AppImages.iImage,
                  infoMessage:
                      'Please upload a clear photo of your shop signboard.',
                ),
                SizedBox(height: 10),
          
                InkWell(
                  onTap: _showPickOptions,
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    height: _picked == null ? 70 : 200, // ✅ auto height change
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: (_picked == null)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(AppImages.galleryImage, height: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Upload Image',
                                style: GoogleFont.Mulish(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(_picked!.path),
                                  width: double.infinity,
                                  height: double.infinity, // ✅ fill the container
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: InkWell(
                                  onTap: _removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
          
                SizedBox(height: 40),
          
                CommonContainer.button(
                  buttonColor: AppColor.darkBlue,
                  imagePath: AppImages.rightSideArrow,
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => SupportChatScreen()),
                    // );
                  },
                  text: Text('Create Ticket'),
                ),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}
