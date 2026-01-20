import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';

import '../../../../../Core/Widgets/common_container.dart';

class SupportChatScreen extends StatefulWidget {
  @override
  _SupportChatScreenState createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final time = _getCurrentTime();

    setState(() {
      messages.add(
        Message(text: _controller.text.trim(), isSender: true, time: time),
      );
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
  }

  final List<Message> messages = [
    Message(
      text: "Transaction Failed due to some reason, I don't …",
      isSender: false,
      time: "11:10pm",
    ),
    Message(
      text:
          "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac",
      isSender: true,
      time: "11:10pm",
    ),
    Message(
      text: "Pellentesque habitant morbi tristique",
      isSender: false,
      time: "11:10pm",
    ),
    Message(
      text:
          "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac",
      isSender: true,
      time: "11:10pm",
    ),
  ];

  String _getCurrentTime() {
    return DateFormat('hh:mma').format(DateTime.now()).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: Column(
          children: [
            /// ✅ FIXED TOP HEADER
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6), // 👈 shadow only at bottom
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
                                "Opened",
                                style: GoogleFont.Mulish(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.blue,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'Transaction Failed due to some reason, i don’t ...',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFont.Mulish(color: AppColor.black),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'Created on 15.02.25',
                                style: GoogleFont.Mulish(
                                  fontSize: 12,
                                  color: AppColor.black.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        InkWell(
                          onTap: () {},
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

            /// ✅ CHAT LIST (SCROLLS)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return GestureDetector(
                    onLongPress: () {
                      // only sender can delete
                      if (!message.isSender) return;

                      showModalBottomSheet(
                        backgroundColor: AppColor.white,
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) {
                          return SafeArea(
                            child: ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: const Text(
                                "Delete message",
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _deleteMessage(index);
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Align(
                      alignment: message.isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(14),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.72,
                          ),
                          decoration: BoxDecoration(
                            color: message.isSender
                                ? AppColor.textWhite
                                : AppColor.midnightBlue,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: message.isSender
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                              bottomRight: message.isSender
                                  ? Radius.zero
                                  : const Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: GoogleFont.Mulish(
                                  color: message.isSender
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  message.time,
                                  style: GoogleFont.Mulish(
                                    fontSize: 10,
                                    color: message.isSender
                                        ? AppColor.black.withOpacity(0.5)
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            /// ✅ FIXED INPUT BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type here",
                        filled: true,
                        fillColor: Colors.grey[200],
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
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final bool isSender;
  final String time;

  Message({required this.text, required this.isSender, required this.time});
}
