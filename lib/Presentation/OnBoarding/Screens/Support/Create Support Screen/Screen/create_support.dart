import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../Core/Utility/app_color.dart';
import '../../../../../../Core/Utility/google_font.dart';
import '../../../../../../Core/Widgets/common_container.dart';

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
      fillColor: const Color(0xFFF2F2F2), // light grey like screenshot
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                textInputAction: TextInputAction.next,
                decoration: _fieldDeco(),
              ),
                SizedBox(height: 18),
                Text(
                'Description',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
                SizedBox(height: 10),
              TextField(
                controller: _descCtrl,
                maxLines: 6,
                decoration: _fieldDeco(),
              ),

                SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
