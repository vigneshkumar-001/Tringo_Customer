import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../Core/Utility/app_color.dart';
import '../../../../Core/Utility/app_snackbar.dart';
import '../../../../Core/Utility/battery_optimization_guide.dart';
import '../../../../Core/Widgets/caller_id_role_helper.dart';

class CallerIdSetupScreen extends ConsumerStatefulWidget {
  const CallerIdSetupScreen({super.key});

  @override
  ConsumerState<CallerIdSetupScreen> createState() =>
      _CallerIdSetupScreenState();
}

class _CallerIdSetupScreenState extends ConsumerState<CallerIdSetupScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _phoneGranted = false;
  bool _overlayGranted = false;
  bool _isDefaultCallerId = false;
  bool _bgRestricted = false;
  bool _ignoringBatteryOpt = true;
  BatteryGuide? _batteryGuide;
  ({String manufacturer, String brand, String model})? _label;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final phone = await Permission.phone.status;
      final overlayOk = await CallerIdRoleHelper.isOverlayGranted();
      final roleOk = await CallerIdRoleHelper.isDefaultCallerIdApp();
      final restricted = await CallerIdRoleHelper.isBackgroundRestricted();
      final ignoring =
          await CallerIdRoleHelper.isIgnoringBatteryOptimizations();

      final label = await BatteryOptimizationGuide.deviceLabel();
      final guide = label == null
          ? null
          : BatteryOptimizationGuide.forAndroid(
              manufacturer: label.manufacturer,
              brand: label.brand,
              model: label.model,
            );

      if (!mounted) return;
      setState(() {
        _phoneGranted = phone.isGranted;
        _overlayGranted = overlayOk;
        _isDefaultCallerId = roleOk;
        _bgRestricted = restricted;
        _ignoringBatteryOpt = ignoring;
        _label = label;
        _batteryGuide = guide;
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestPhone() async {
    try {
      final res = await Permission.phone.request();
      if (!mounted) return;
      if (!res.isGranted) {
        AppSnackBar.info(
          context,
          'Phone permission needed for call end detection',
        );
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Could not request phone permission');
    } finally {
      _refresh();
    }
  }

  Future<void> _openOverlaySettings() async {
    try {
      await CallerIdRoleHelper.requestOverlayPermission();
      if (!mounted) return;
      AppSnackBar.info(context, 'Enable “Appear on top” and come back');
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Could not open overlay settings');
    }
  }

  Future<void> _requestCallerIdRole() async {
    try {
      await CallerIdRoleHelper.requestDefaultCallerIdApp();
    } catch (_) {
      // ignore
    } finally {
      _refresh();
    }
  }

  Future<void> _openBatterySettings() async {
    try {
      final opened = await CallerIdRoleHelper.openBatteryUnrestrictedSettings();
      if (!opened) await CallerIdRoleHelper.requestIgnoreBatteryOptimization();
      if (!mounted) return;
      AppSnackBar.info(
        context,
        'Set TringoBiz to Unrestricted / Never sleeping apps',
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Could not open battery settings');
    }
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required bool ok,
    required String okText,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ok ? Colors.green.shade50 : Colors.orange.shade50,
            ),
            child: Icon(
              ok ? Icons.check_circle : Icons.warning_rounded,
              color: ok ? Colors.green.shade700 : Colors.orange.shade700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: ok ? Colors.green.shade50 : Colors.grey.shade100,
                      ),
                      child: Text(
                        ok ? okText : 'Not enabled',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ok
                              ? Colors.green.shade800
                              : Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (!ok)
                      ElevatedButton(
                        onPressed: onAction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.darkBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(actionText),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Platform.isAndroid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caller ID Setup'),
        backgroundColor: AppColor.darkBlue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF6F7FB),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enable only what is needed',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'This is optional. Caller overlay needs Phone + Overlay permissions. Default Caller ID role improves integration on some phones.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                if (_label != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Device: ${_label!.manufacturer} ${_label!.model}',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _loading ? null : _refresh,
                  child: Text(_loading ? 'Checking…' : 'Refresh status'),
                ),
              ],
            ),
          ),

          if (!isAndroid)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                'Caller overlay setup is available on Android only.',
              ),
            ),

          if (isAndroid) ...[
            _tile(
              title: 'Phone permission',
              subtitle: 'Needed to detect call end (READ_PHONE_STATE).',
              ok: _phoneGranted,
              okText: 'Granted',
              actionText: 'Allow',
              onAction: _requestPhone,
            ),
            _tile(
              title: 'Overlay permission',
              subtitle: 'Needed to show “Appear on top” overlay.',
              ok: _overlayGranted,
              okText: 'Allowed',
              actionText: 'Open settings',
              onAction: _openOverlaySettings,
            ),
            _tile(
              title: 'Default Caller ID role (optional)',
              subtitle: 'Improves integration on some devices.',
              ok: _isDefaultCallerId,
              okText: 'Enabled',
              actionText: 'Enable',
              onAction: _requestCallerIdRole,
            ),

            // Don't show battery steps unless the OS says background is restricted.
            // This keeps onboarding friction low (Truecaller-style) while still providing
            // a fix path for devices that aggressively kill background work.
            if (_batteryGuide != null &&
                _bgRestricted &&
                !_ignoringBatteryOpt) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Battery optimization (only if needed)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _batteryGuide!.title,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._batteryGuide!.steps.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $s',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _openBatterySettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Open battery settings'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
