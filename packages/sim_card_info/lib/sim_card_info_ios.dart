// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sim_card_info/sim_info.dart';

import 'sim_card_info_platform_interface.dart';

/// A web implementation of the SimCardInfoPlatform of the SimCardInfo plugin.
class SimCardInfoIos extends SimCardInfoPlatform {
  /// Constructs a SimCardInfoWeb
  SimCardInfoIos();

  static void registerWith(Registrar registrar) {
    SimCardInfoPlatform.instance = SimCardInfoIos();
  }

  /// get Sim Info Not Supported on iOS
  @override
  Future<List<SimInfo>?> getSimInfo() async {
    throw PlatformException(
        code: '404', message: 'getSimInfo() has not been implemented.');
  }
}
