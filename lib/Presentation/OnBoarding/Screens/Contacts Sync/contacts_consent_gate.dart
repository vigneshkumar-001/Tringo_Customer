import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Api/api_providers.dart';
import 'package:tringo_app/Core/Const/app_logger.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Core/Utility/google_font.dart';
import 'package:tringo_app/Core/Widgets/common_container.dart';
import 'package:tringo_app/Core/contacts/contacts_service.dart';

class ContactsConsentGateArgs {
  final String nextRouteName;
  const ContactsConsentGateArgs({required this.nextRouteName});

  static ContactsConsentGateArgs? tryParse(Object? extra) {
    if (extra is ContactsConsentGateArgs) return extra;
    if (extra is Map) {
      final next = extra['nextRouteName'];
      if (next is String && next.isNotEmpty) {
        return ContactsConsentGateArgs(nextRouteName: next);
      }
    }
    return null;
  }
}

class ContactsConsentGate extends ConsumerStatefulWidget {
  final ContactsConsentGateArgs args;
  const ContactsConsentGate({super.key, required this.args});

  @override
  ConsumerState<ContactsConsentGate> createState() => _ContactsConsentGateState();
}

class _ContactsConsentGateState extends ConsumerState<ContactsConsentGate> {
  bool _isWorking = false;
  int _syncedCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSkipIfNeeded());
  }

  Future<void> _autoSkipIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySynced = prefs.getBool('contacts_synced') ?? false;
    final skipped = prefs.getBool('contacts_sync_skipped') ?? false;

    if (!mounted) return;
    if (alreadySynced || skipped) {
      context.goNamed(widget.args.nextRouteName);
    }
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('contacts_sync_skipped', true);
    if (!mounted) return;
    context.goNamed(widget.args.nextRouteName);
  }

  Future<void> _requestPermissionAndSync() async {
    if (_isWorking) return;
    setState(() {
      _isWorking = true;
      _syncedCount = 0;
      _totalCount = 0;
    });

    try {
      var status = await Permission.contacts.status;
      if (!status.isGranted) {
        status = await Permission.contacts.request();
      }

      if (!status.isGranted) {
        if (!mounted) return;
        AppSnackBar.info(
          context,
          'Contacts permission is required to sync. You can skip for now.',
        );
        setState(() => _isWorking = false);
        return;
      }

      final contacts = await ContactsService.getAllContacts();
      final limited = contacts.take(500).toList();
      _totalCount = limited.length;

      if (limited.isEmpty) {
        if (!mounted) return;
        AppSnackBar.info(context, 'No contacts found to sync.');
        setState(() => _isWorking = false);
        return;
      }

      final api = ref.read(apiDataSourceProvider);
      final items =
          limited.map((c) => {"name": c.name, "phone": "+91${c.phone}"}).toList();

      const chunkSize = 200;
      for (var i = 0; i < items.length; i += chunkSize) {
        final chunk = items.sublist(
          i,
          (i + chunkSize > items.length) ? items.length : i + chunkSize,
        );

        final res = await api.syncContacts(items: chunk);
        res.fold(
          (l) {
            throw Exception(l.message);
          },
          (r) {
            AppLogger.log.i(
              "✅ contacts sync batch ok total=${r.data.total} inserted=${r.data.inserted} touched=${r.data.touched} skipped=${r.data.skipped}",
            );
          },
        );

        if (!mounted) return;
        setState(() => _syncedCount = (i + chunk.length));
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('contacts_synced', true);
      await prefs.remove('contacts_sync_skipped');

      if (!mounted) return;
      AppSnackBar.success(context, 'Contacts synced successfully!');
      context.goNamed(widget.args.nextRouteName);
    } catch (e) {
      AppLogger.log.e("❌ contacts sync failed: $e");
      if (mounted) {
        AppSnackBar.error(context, 'Contact sync failed. You can try later.');
        setState(() => _isWorking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalCount == 0 ? null : (_syncedCount / _totalCount).clamp(0.0, 1.0);

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
                    'We will upload your phone contacts to help you find and connect faster.\n\n'
                    '• We only use contacts for app features\n'
                    '• You can skip now and sync later\n'
                    '• We never message anyone without your action',
                    style: GoogleFont.Mulish(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isWorking) ...[
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.6),
                      color: AppColor.skyBlue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _totalCount == 0
                          ? 'Preparing…'
                          : 'Synced $_syncedCount / $_totalCount',
                      style: GoogleFont.Mulish(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColor.darkBlue,
                      ),
                    ),
                  ],
                  const Spacer(),
                  CommonContainer.button(
                    buttonColor: AppColor.skyBlue,
                    onTap: _isWorking ? null : _requestPermissionAndSync,
                    text: Text(
                      _isWorking ? 'Syncing…' : 'Allow & Sync',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CommonContainer.button(
                    hasBorder: true,
                    buttonColor: Colors.white,
                    borderColor: AppColor.skyBlue,
                    onTap: _isWorking ? null : _skip,
                    text: Text(
                      'Skip for now',
                      style: GoogleFont.Mulish(
                        fontWeight: FontWeight.w800,
                        color: AppColor.skyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
