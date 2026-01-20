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
import 'package:tringo_app/Core/Utility/date_time_converter.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Support/controller/support_notifier.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../Model/chat_message_response.dart' as api;

class SupportChatScreen extends ConsumerStatefulWidget {
  final String id;
  const SupportChatScreen({super.key, required this.id});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<LocalChatMessage> _localMessages = [];

  XFile? _pickedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(supportNotifier.notifier).getChatMessage(id: widget.id);
    });
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mma').format(date).toLowerCase();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted || picked == null) return;
    setState(() => _pickedImage = picked);
  }

  // ---------------------- BUILD ----------------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supportNotifier);
    final List<api.Message> apiMessages =
        (state.chatMessageResponse?.data.messages ?? []).reversed.toList();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Skeletonizer(
          enabled: state.isLoading,
          child: Column(
            children: [
              _buildHeader(state),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _localMessages.length + apiMessages.length,
                  itemBuilder: (context, index) {
                    if (index < _localMessages.length) {
                      return _buildLocalBubble(_localMessages[index]);
                    }

                    final apiIndex = index - _localMessages.length;
                    final msg = apiMessages[apiIndex];

                    return _buildApiBubble(msg);
                  },
                ),
              ),
              _buildInputBar(state),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------- HEADER ----------------------

  Widget _buildHeader(SupportState state) {
    final ticket = state.chatMessageResponse?.data.ticket;
    return Container(
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
                        ticket?.status ?? 'OPEN',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.blue,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        ticket?.subject ?? 'Loading subject...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFont.Mulish(color: AppColor.black),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Created on ${DateAndTimeConvert.formatDateTime(ticket?.createdAt.toString() ?? '', showTime: false)}',
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
                  onTap: () => Navigator.pop(context),
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
    );
  }

  // ---------------------- INPUT BAR ----------------------

  Widget _buildInputBar(SupportState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Column(
        children: [
          if (_pickedImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !state.isLoading,
                  decoration: InputDecoration(
                    hintText: "Type here",
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          AppImages.galleryImage,
                          width: 22,
                          color: AppColor.darkBlue,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _sendMessage,
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
        ],
      ),
    );
  }

  // ---------------------- SEND MESSAGE ----------------------

  Future<void> _sendMessage() async {
    final notifier = ref.read(supportNotifier.notifier);

    if (_messageController.text.trim().isEmpty && _pickedImage == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final localMessage = LocalChatMessage(
      id: tempId,
      message: _messageController.text.trim(),
      isMine: true,
      time: DateTime.now(),
      localImagePath: _pickedImage?.path,
      isSending: true,
    );

    setState(() => _localMessages.add(localMessage));

    final text = _messageController.text.trim();
    final File? imageFile = _pickedImage != null
        ? File(_pickedImage!.path)
        : null;

    _messageController.clear();
    setState(() => _pickedImage = null);

    try {
      await notifier.sendMessage(
        context: context,
        ticketId: widget.id,
        subject: text,
        ownerImageFile: imageFile, // ✅ SEND IMAGE
      );

      setState(() {
        final i = _localMessages.indexWhere((e) => e.id == tempId);
        if (i != -1)
          _localMessages[i] = _localMessages[i].copyWith(isSending: false);
      });
    } catch (e) {
      setState(() {
        final i = _localMessages.indexWhere((e) => e.id == tempId);
        if (i != -1)
          _localMessages[i] = _localMessages[i].copyWith(
            isSending: false,
            isFailed: true,
          );
      });
    }
  }

  // ---------------------- CHAT BUBBLES ----------------------

  Widget _buildLocalBubble(LocalChatMessage msg) {
    return _chatBubble(
      isMine: true,
      time: _formatTime(msg.time),
      text: msg.message.isEmpty ? null : msg.message,
      localImagePath: msg.localImagePath,
      isSending: msg.isSending,
      isFailed: msg.isFailed,
    );
  }

  Widget _buildApiBubble(api.Message msg) {
    final isAdmin = msg.senderRole == "ADMIN";
    String? imageUrl;
    if (msg.attachments.isNotEmpty && msg.attachments.first.url.isNotEmpty) {
      imageUrl = msg.attachments.first.url;
    }

    return _chatBubble(
      isMine: !isAdmin,
      time: _formatTime(msg.createdAt),
      text: msg.message,
      imageUrl: imageUrl,
    );
  }

  Widget _chatBubble({
    required bool isMine,
    required String time,
    String? text,
    String? imageUrl,
    String? localImagePath,
    bool isSending = false,
    bool isFailed = false,
  }) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColor.textWhite : AppColor.midnightBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (localImagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(localImagePath),
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if ((text ?? '').isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                text!,
                style: GoogleFont.Mulish(
                  color: isMine ? Colors.black : Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine
                        ? Colors.black.withOpacity(0.6)
                        : Colors.white.withOpacity(0.6),
                  ),
                ),
                if (isSending)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.schedule, size: 12),
                  ),
                if (isFailed)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.error, size: 12, color: Colors.red),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------- LOCAL CHAT MODEL ----------------------

class LocalChatMessage {
  final String id;
  final String message;
  final bool isMine;
  final DateTime time;
  final String? localImagePath;
  final bool isSending;
  final bool isFailed;

  LocalChatMessage({
    required this.id,
    required this.message,
    required this.isMine,
    required this.time,
    this.localImagePath,
    this.isSending = false,
    this.isFailed = false,
  });

  LocalChatMessage copyWith({bool? isSending, bool? isFailed}) {
    return LocalChatMessage(
      id: id,
      message: message,
      isMine: isMine,
      time: time,
      localImagePath: localImagePath,
      isSending: isSending ?? this.isSending,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}

/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Utility/date_time_converter.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Support/controller/support_notifier.dart';
import '../../../../../Core/Widgets/common_container.dart';
import '../Model/chat_message_response.dart' as api;

class SupportChatScreen extends ConsumerStatefulWidget {
  final String id;
  const SupportChatScreen({super.key, required this.id});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<LocalChatMessage> _localMessages = [];

  File? _selectedImage;

  String _formatTime(DateTime date) {
    return DateFormat('hh:mma').format(date).toLowerCase();
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

    final List<api.Message> apiMessages =
        (state.chatMessageResponse?.data.messages ?? []).reversed.toList();

    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Skeletonizer(
          enabled: state.isLoading,
          child: Column(
            children: [
              /// 🔹 HEADER
              _buildHeader(state),

              /// 🔹 CHAT LIST
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _localMessages.length + apiMessages.length,
                  itemBuilder: (context, index) {
                    if (index < _localMessages.length) {
                      return _buildLocalBubble(_localMessages[index]);
                    }

                    final apiIndex = index - _localMessages.length;
                    final msg = apiMessages[apiIndex];

                    return _buildApiBubble(msg);
                  },
                ),
              ),
              // Expanded(
              //   child: ListView.builder(
              //     reverse: true, // 👈 required
              //     controller: _scrollController,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 20,
              //       vertical: 10,
              //     ),
              //     itemCount: _localMessages.length + apiMessages.length,
              //     itemBuilder: (context, index) {
              //       /// 🔹 Local messages first
              //       if (index < _localMessages.length) {
              //         return _buildLocalBubble(_localMessages[index]);
              //       }
              //
              //       final msg = apiMessages[index - _localMessages.length];
              //       return _buildApiBubble(msg);
              //     },
              //   ),
              // ),

              /// 🔹 INPUT BAR
              _buildInputBar(state),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildHeader(SupportState state) {
    final ticket = state.chatMessageResponse?.data.ticket;

    return Container(
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
                        state.chatMessageResponse?.data.ticket.status ?? 'OPEN',
                        style: GoogleFont.Mulish(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColor.blue,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        state.chatMessageResponse?.data.ticket.subject ??
                            'Loading subject...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFont.Mulish(color: AppColor.black),
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
    );
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
  // ---------------- INPUT BAR ----------------

  Widget _buildInputBar(SupportState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Column(
        children: [
          if (_pickedImage != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !state.isLoading,
                  decoration: InputDecoration(
                    hintText: "Type here",
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          AppImages.galleryImage,
                          width: 22,
                          color: AppColor.darkBlue,
                        ),
                      ),
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _sendMessage,
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
        ],
      ),
    );
  }

  // ---------------- SEND MESSAGE (OPTIMISTIC) ----------------
  Future<void> _sendMessage() async {
    final notifier = ref.read(supportNotifier.notifier);

    if (_messageController.text.trim().isEmpty && _pickedImage == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();

    final localMessage = LocalChatMessage(
      id: tempId,
      message: _messageController.text.trim(),
      isMine: true,
      time: DateTime.now(),
      isSending: true,
    );

    setState(() {
      _localMessages.add(localMessage);
    });

    final text = _messageController.text.trim();
    final File? imageFile =
    _pickedImage != null ? File(_pickedImage!.path) : null;

    _messageController.clear();
    setState(() => _pickedImage = null);

    try {
      await notifier.sendMessage(
        context: context,
        ticketId: widget.id,
        subject: text,
        ownerImageFile: imageFile, // ✅ IMAGE PASSED HERE
      );

      setState(() {
        final i = _localMessages.indexWhere((e) => e.id == tempId);
        if (i != -1) {
          _localMessages[i] = _localMessages[i].copyWith(isSending: false);
        }
      });
    } catch (e) {
      setState(() {
        final i = _localMessages.indexWhere((e) => e.id == tempId);
        if (i != -1) {
          _localMessages[i] =
              _localMessages[i].copyWith(isSending: false, isFailed: true);
        }
      });
    }
  }

  // Future<void> _sendMessage() async {
  //   final notifier = ref.read(supportNotifier.notifier);
  //
  //   if (_messageController.text.trim().isEmpty) return;
  //
  //   final tempId = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //   final localMessage = LocalChatMessage(
  //     id: tempId,
  //     message: _messageController.text.trim(),
  //     isMine: true,
  //     time: DateTime.now(),
  //     isSending: true,
  //   );
  //
  //   setState(() {
  //     _localMessages.add(localMessage); // ✅ IMPORTANT FIX
  //   });
  //
  //   final text = _messageController.text.trim();
  //   _messageController.clear();
  //
  //   try {
  //     await notifier.sendMessage(
  //       context: context,
  //       ticketId: widget.id,
  //       subject: text,
  //     );
  //
  //     setState(() {
  //       final i = _localMessages.indexWhere((e) => e.id == tempId);
  //       if (i != -1) {
  //         _localMessages[i] = _localMessages[i].copyWith(isSending: false);
  //       }
  //     });
  //   } catch (e) {
  //     setState(() {
  //       final i = _localMessages.indexWhere((e) => e.id == tempId);
  //       if (i != -1) {
  //         _localMessages[i] = _localMessages[i].copyWith(
  //           isSending: false,
  //           isFailed: true,
  //         );
  //       }
  //     });
  //   }
  // }

  // ---------------- MESSAGE BUBBLES ----------------

  Widget _buildLocalBubble(LocalChatMessage msg) {
    return _chatBubble(
      text: msg.message,
      isMine: true,
      time: _formatTime(msg.time),
      isSending: msg.isSending,
      isFailed: msg.isFailed,
    );
  }

  Widget _buildApiBubble(api.Message msg) {
    final isAdmin = msg.senderRole == "ADMIN";
    return _chatBubble(
      text: msg.message,
      isMine: !isAdmin,
      time: _formatTime(msg.createdAt),
    );
  }

  Widget _chatBubble({
    required String text,
    required bool isMine,
    required String time,
    bool isSending = false,
    bool isFailed = false,
  }) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColor.textWhite : AppColor.midnightBlue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: GoogleFont.Mulish(
                color: isMine ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(time, style: const TextStyle(fontSize: 10)),
                // const SizedBox(width: 6),
                // if (isSending)
                //   const Icon(Icons.schedule, size: 12)
                // else if (isFailed)
                //   const Icon(Icons.error, size: 12, color: Colors.red)
                // else if (isMine)
                //   const Icon(Icons.done_all, size: 14, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class LocalChatMessage {
  final String id;
  final String message;
  final bool isMine;
  final DateTime time;
  final bool isSending;
  final bool isFailed;

  LocalChatMessage({
    required this.id,
    required this.message,
    required this.isMine,
    required this.time,
    this.isSending = false,
    this.isFailed = false,
  });

  LocalChatMessage copyWith({bool? isSending, bool? isFailed}) {
    return LocalChatMessage(
      id: id,
      message: message,
      isMine: isMine,
      time: time,
      isSending: isSending ?? this.isSending,
      isFailed: isFailed ?? this.isFailed,
    );
  }
}
*/

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import 'package:tringo_app/Core/Utility/app_Images.dart';
// import 'package:tringo_app/Core/Utility/app_color.dart';
// import 'package:tringo_app/Core/Utility/app_loader.dart';
// import 'package:tringo_app/Core/Utility/google_font.dart';
// import 'package:tringo_app/Presentation/OnBoarding/Screens/Support/controller/support_notifier.dart';
//
// import '../../../../../Core/Utility/date_time_converter.dart';
// import '../../../../../Core/Widgets/common_container.dart';
// import '../Model/chat_message_response.dart'
//     as api; // 👈 alias to avoid conflict
//
// class SupportChatScreen extends ConsumerStatefulWidget {
//   final String id;
//   const SupportChatScreen({super.key, required this.id});
//
//   @override
//   ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
// }
//
// class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
//   final TextEditingController _controller = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   String _formatTime(DateTime date) {
//     return DateFormat('hh:mma').format(date).toLowerCase();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(supportNotifier.notifier).getChatMessage(id: widget.id);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(supportNotifier);
//
//     /// ✅ SAFELY READ API MESSAGES
//     final List<api.Message> messages =
//         state.chatMessageResponse?.data.messages ?? [];
//
//     return Scaffold(
//       backgroundColor: AppColor.white,
//       body: SafeArea(
//         child: Skeletonizer(
//           enabled: state.isLoading,
//           child: Column(
//             children: [
//
//               /// 🔹 HEADER
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 12,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 56,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: CommonContainer.leftSideArrow(
//                               onTap: () => Navigator.pop(context),
//                             ),
//                           ),
//                           Text(
//                             'Support Chat',
//                             style: GoogleFont.Mulish(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w400,
//                               color: AppColor.mildBlack,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   state
//                                       .chatMessageResponse
//                                       ?.data
//                                       .ticket
//                                       .status ??
//                                       'OPEN',
//                                   style: GoogleFont.Mulish(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w600,
//                                     color: AppColor.blue,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 9),
//                                 Text(
//                                   state
//                                       .chatMessageResponse
//                                       ?.data
//                                       .ticket
//                                       .subject ??
//                                       'Loading subject...',
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: GoogleFont.Mulish(
//                                     color: AppColor.black,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 9),
//                                 Text(
//                                   'Created on ${DateAndTimeConvert
//                                       .formatDateTime(
//                                       state.chatMessageResponse?.data.ticket
//                                           .createdAt.toString() ?? '',
//                                       showTime: false)}',
//                                   style: GoogleFont.Mulish(
//                                     fontSize: 12,
//                                     color: AppColor.black.withOpacity(0.4),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(width: 40),
//                           GestureDetector(
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 18,
//                                 vertical: 14,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: AppColor.black,
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     "Close",
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Ticket",
//                                     style: GoogleFont.Mulish(
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               /// 🔹 CHAT LIST
//               Expanded(
//                 child: messages.isEmpty && !state.isLoading
//                     ? const Center(child: Text("No messages found"))
//                     : ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   itemCount: state.isLoading ? 6 : messages.length,
//                   itemBuilder: (context, index) {
//                     final bool isAdmin = state.isLoading
//                         ? index.isEven
//                         : messages[index].senderRole == "ADMIN";
//
//                     return Align(
//                       alignment: isAdmin
//                           ? Alignment.centerLeft
//                           : Alignment.centerRight,
//                       child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 8),
//                         padding: const EdgeInsets.all(14),
//                         constraints: BoxConstraints(
//                           maxWidth:
//                           MediaQuery
//                               .of(context)
//                               .size
//                               .width * 0.72,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isAdmin
//                               ? AppColor.midnightBlue
//                               : AppColor.textWhite,
//                           borderRadius: BorderRadius.only(
//                             topLeft: const Radius.circular(20),
//                             topRight: const Radius.circular(20),
//                             bottomLeft: isAdmin
//                                 ? Radius.zero
//                                 : const Radius.circular(20),
//                             bottomRight: isAdmin
//                                 ? const Radius.circular(20)
//                                 : Radius.zero,
//                           ),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               state.isLoading
//                                   ? 'Loading message...'
//                                   : messages[index].message,
//                               style: GoogleFont.Mulish(
//                                 color: isAdmin
//                                     ? Colors.white
//                                     : Colors.black,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Align(
//                               alignment: Alignment.bottomRight,
//                               child: Text(
//                                 state.isLoading
//                                     ? '00:00'
//                                     : _formatTime(
//                                   messages[index].createdAt,
//                                 ),
//                                 style: GoogleFont.Mulish(
//                                   fontSize: 10,
//                                   color: isAdmin
//                                       ? Colors.white.withOpacity(0.5)
//                                       : AppColor.black.withOpacity(0.5),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               /// 🔹 INPUT BAR
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 15,
//                 ),
//                 color: Colors.white,
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         enabled: !state.isLoading,
//                         controller: _controller,
//                         decoration: InputDecoration(
//                           hintText: "Type here",
//                           filled: true,
//                           fillColor: Colors.grey[200],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(15),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     InkWell(
//                       onTap: () {
//                         if (_controller.text
//                             .trim()
//                             .isEmpty) return;
//
//                         ref
//                             .read(supportNotifier.notifier)
//                             .sendMessage(
//                           context: context,
//                           ticketId: widget.id,
//                           subject: _controller.text.trim(),
//                         );
//
//                         _controller.clear();
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(18),
//                         decoration: BoxDecoration(
//                           color: AppColor.black,
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         child: Image.asset(AppImages.sendImage, height: 20),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// class Message {
//   final String text;
//   final String senderRole;
//   final String time;
//
//   Message({required this.text, required this.senderRole, required this.time});
//
//   bool get isAdmin => senderRole == "ADMIN";
// }
//
