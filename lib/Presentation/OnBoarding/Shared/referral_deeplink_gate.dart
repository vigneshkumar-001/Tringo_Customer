import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tringo_app/Core/Utility/app_prefs.dart';
import 'package:tringo_app/Core/app_go_routes.dart';

class ReferralDeeplinkGate extends StatefulWidget {
  final String referralCode;

  const ReferralDeeplinkGate({
    super.key,
    required this.referralCode,
  });

  @override
  State<ReferralDeeplinkGate> createState() => _ReferralDeeplinkGateState();
}

class _ReferralDeeplinkGateState extends State<ReferralDeeplinkGate> {
  bool _didRun = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    if (_didRun) return;
    _didRun = true;

    await AppPrefs.setPendingReferralCode(widget.referralCode);

    // Follow the same navigation rules as Splash:
    // - not logged in -> Login
    // - profile incomplete -> Fill profile
    // - else -> continue (Home). OTP flow will route to Referral screen if needed.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isProfileCompleted = prefs.getBool('isProfileCompleted') ?? false;

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      context.go(AppRoutes.loginPath);
    } else if (!isProfileCompleted) {
      context.go(AppRoutes.fillProfilePath);
    } else {
      context.go(AppRoutes.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

