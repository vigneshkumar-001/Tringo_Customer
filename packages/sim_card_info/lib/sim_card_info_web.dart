// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'sim_card_info_platform_interface.dart';

/// A web implementation of the SimCardInfoPlatform of the SimCardInfo plugin.
class SimCardInfoWeb extends SimCardInfoPlatform {
  /// Constructs a SimCardInfoWeb
  SimCardInfoWeb();

  static void registerWith(Registrar registrar) {
    SimCardInfoPlatform.instance = SimCardInfoWeb();
  }

  /// get Sim Info Not Supported on Web
// @override
// Future<String?> getSimInfo() async {
//   final version = html.window.navigator.userAgent;
//   return "SimCardInfo for Web $version is not Supported";
// }
}
