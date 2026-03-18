import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sim_card_info/sim_info.dart';

import 'sim_card_info_platform_interface.dart';

/// An implementation of [SimCardInfoPlatform] that uses method channels.
class MethodChannelSimCardInfo extends SimCardInfoPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sim_card_info');

  @override
  Future<List<SimInfo>?> getSimInfo() async {
    final info = await methodChannel.invokeMethod<String>('getSimInfo');
    List<SimInfo>? simInfoList;
    if (info != null) {
      simInfoList = [];

      /// convert json to list
      final infoJson = json.decode(info);
      infoJson.forEach((element) {
        simInfoList?.add(SimInfo.fromJson(element));
      });
    }
    return simInfoList;
  }
}
