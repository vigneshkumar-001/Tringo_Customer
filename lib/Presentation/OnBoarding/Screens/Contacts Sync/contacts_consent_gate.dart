import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/api_providers.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/Contacts Sync Helper/contacts_sync_helpers.dart';

class ContactsConsentGateArgs {
  final String nextRouteName;
  final bool forceShow;
  final bool popOnDone;
  final bool showTurnOffCallerIdPromptOnSkip;
  const ContactsConsentGateArgs({
    required this.nextRouteName,
    this.forceShow = false,
    this.popOnDone = false,
    this.showTurnOffCallerIdPromptOnSkip = true,
  });

  static ContactsConsentGateArgs? tryParse(Object? extra) {
    if (extra is ContactsConsentGateArgs) return extra;
    if (extra is Map) {
      final next = extra['nextRouteName'];
      final force = extra['forceShow'];
      final pop = extra['popOnDone'];
      final prompt = extra['showTurnOffCallerIdPromptOnSkip'];
      if (next is String && next.isNotEmpty) {
        return ContactsConsentGateArgs(
          nextRouteName: nextRouteNameFrom(next),
          forceShow: force == true,
          popOnDone: pop == true,
          showTurnOffCallerIdPromptOnSkip: prompt != false,
        );
      }
    }
    return null;
  }

  static String nextRouteNameFrom(String value) => value;
}

class ContactsConsentGate extends ConsumerStatefulWidget {
  final ContactsConsentGateArgs args;
  const ContactsConsentGate({super.key, required this.args});

  @override
  ConsumerState<ContactsConsentGate> createState() => _ContactsConsentGateState();
}

class _ContactsConsentGateState extends ConsumerState<ContactsConsentGate> {
  bool _isWorking = false;

  static const _prefContactsSynced = 'contacts_synced';
  static const _prefContactsSyncSkipped = 'contacts_sync_skipped';
  static const _prefContactsSyncInProgress = 'contacts_sync_in_progress';
  static const _prefContactsUploadConsent = 'contacts_upload_consent_v1';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSkipIfNeeded());
  }

  Future<void> _autoSkipIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySynced = prefs.getBool(_prefContactsSynced) ?? false;
    final skipped = prefs.getBool(_prefContactsSyncSkipped) ?? false;
    final inProgress = prefs.getBool(_prefContactsSyncInProgress) ?? false;

    if (!mounted) return;
    if (alreadySynced || (!widget.args.forceShow && (skipped || inProgress))) {
      if (widget.args.popOnDone) {
        Navigator.of(context).pop(true);
      } else {
        context.goNamed(widget.args.nextRouteName);
      }
    }
  }

  Future<void> _requestPermissionAndSync() async {
    if (_isWorking) return;
    setState(() {
      _isWorking = true;
    });

    try {
      var status = await Permission.contacts.status;
      if (!status.isGranted) {
        status = await Permission.contacts.request();
      }

      if (!status.isGranted) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefContactsSyncSkipped, true);
        await prefs.setBool(_prefContactsUploadConsent, false);
        if (!mounted) return;
        if (widget.args.popOnDone) {
          Navigator.of(context).pop(false);
        } else {
          context.goNamed(widget.args.nextRouteName);
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefContactsUploadConsent, true);

      // Allow -> fire-and-forget background sync -> go next screen immediately.
      final api = ref.read(apiDataSourceProvider);
      unawaited(ContactsSyncHelper.syncOnceInBackground(api, ignoreSkipped: true));
      if (!mounted) return;
      if (widget.args.popOnDone) {
        Navigator.of(context).pop(true);
      } else {
        context.goNamed(widget.args.nextRouteName);
      }
    } catch (_) {
      setState(() => _isWorking = false);
    }
  }

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Sync contacts',
                    style: GoogleFont.Mulish(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColor.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'If you continue and allow access, TringoBiz will upload your phone contacts to the TringoBiz server.\n\n'
                    '- Contacts are used only to help you find and connect with people you already know in TringoBiz\n'
                    '- Contacts are not sold, shared with third parties, or messaged without your action\n'
                    '- You can manage this permission in iOS Settings',
                    style: GoogleFont.Mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Spacer(),
                  CommonContainer.button(
                    buttonColor: AppColor.skyBlue,
                    onTap: _isWorking ? null : _requestPermissionAndSync,
                    text: Text(
                      'Continue',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
   
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
