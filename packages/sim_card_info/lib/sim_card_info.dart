import 'package:sim_card_info/sim_info.dart';

import 'sim_card_info_platform_interface.dart';

/// An implementation of [SimCardInfoPlatform] that uses method channels.
class SimCardInfo {
  Future<List<SimInfo>?> getSimInfo() async {
    return SimCardInfoPlatform.instance.getSimInfo();
  }
}
