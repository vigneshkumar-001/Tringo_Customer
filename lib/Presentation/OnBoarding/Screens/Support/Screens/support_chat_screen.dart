import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Support/controller/support_notifier.dart';

import '../../../../../Core/Utility/date_time_converter.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../Model/chat_message_response.dart'
    as api; // 👈 alias to avoid conflict

class SupportChatScreen extends ConsumerStatefulWidget {
  final String id;
  const SupportChatScreen({super.key, required this.id});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _formatTime(DateTime date) {
    return DateFormat('hh:mma').format(date).toLowerCase();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    setState(() => _pickedImage = picked);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportNotifier.notifier).getChatMessage(id: widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportNotifier);

    /// ✅ SAFELY READ API MESSAGES
    final List<api.Message> messages =
        state.chatMessageResponse?.data.messages ?? [];

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Skeletonizer(
          enabled: state.isLoading,
          child: Column(
            children: [
              /// 🔹 HEADER
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SizedBox(
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: CommonContainer.leftSideArrow(
                              onTap: () => Navigator.pop(context),
                            ),
                          ),
                          Text(
                            'Support Chat',
                            style: GoogleFont.Mulish(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColor.mildBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state
                                          .chatMessageResponse
                                          ?.data
                                          .ticket
                                          .status ??
                                      'OPEN',
                                  style: GoogleFont.Mulish(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.blue,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  state
                                          .chatMessageResponse
                                          ?.data
                                          .ticket
                                          .subject ??
                                      'Loading subject...',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFont.Mulish(
                                    color: AppColor.black,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  'Created on ${DateAndTimeConvert.formatDateTime(state.chatMessageResponse?.data.ticket.createdAt.toString() ?? '', showTime: false)}',
                                  style: GoogleFont.Mulish(
                                    fontSize: 12,
                                    color: AppColor.black.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.black,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Close",
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Ticket",
                                    style: GoogleFont.Mulish(
                                      fontSize: 12,
                                      color: Colors.white,
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
                ),
              ),

              /// 🔹 CHAT LIST
              Expanded(
                child: messages.isEmpty && !state.isLoading
                    ? const Center(child: Text("No messages found"))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: state.isLoading ? 6 : messages.length,
                        itemBuilder: (context, index) {
                          final bool isAdmin = state.isLoading
                              ? index.isEven
                              : messages[index].senderRole == "ADMIN";

                          return Align(
                            alignment: isAdmin
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.all(14),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.72,
                              ),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? AppColor.midnightBlue
                                    : AppColor.textWhite,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: isAdmin
                                      ? Radius.zero
                                      : const Radius.circular(20),
                                  bottomRight: isAdmin
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.isLoading
                                        ? 'Loading message...'
                                        : messages[index].message,
                                    style: GoogleFont.Mulish(
                                      color: isAdmin
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      state.isLoading
                                          ? '00:00'
                                          : _formatTime(
                                              messages[index].createdAt,
                                            ),
                                      style: GoogleFont.Mulish(
                                        fontSize: 10,
                                        color: isAdmin
                                            ? Colors.white.withOpacity(0.5)
                                            : AppColor.black.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              if (_pickedImage != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  height: 120,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                          width: 180,
                          height: 180,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: InkWell(
                          onTap: () => setState(() => _pickedImage = null),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black.withOpacity(0.6),
                            child: Icon(
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

              /// 🔹 INPUT BAR
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enabled: !state.isLoading,
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Type here",
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          // ✅ Add the icon inside the text field
                          suffixIcon: InkWell(
                            onTap: _pickImage, // your image picker function
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 20,
                              ), // adjust for size
                              child: Image.asset(
                                AppImages.galleryImage,
                                width: 20,
                                color: AppColor.darkBlue,
                              ),
                              // Icon(
                              //   Icons.image,
                              //   color: Colors.black54,
                              //   size: 22,
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColor.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Image.asset(AppImages.sendImage, height: 20),
                      ),
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

class Message {
  final String text;
  final String senderRole;
  final String time;

  Message({required this.text, required this.senderRole, required this.time});

  bool get isAdmin => senderRole == "ADMIN";
}
