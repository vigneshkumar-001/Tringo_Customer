import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class BatteryGuide {
  final String title;
  final List<String> steps;

  const BatteryGuide({
    required this.title,
    required this.steps,
  });
}

class BatteryOptimizationGuide {
  static Future<({String manufacturer, String brand, String model})?> deviceLabel() async {
    if (!Platform.isAndroid) return null;
    final info = await DeviceInfoPlugin().androidInfo;
    return (
      manufacturer: (info.manufacturer).trim(),
      brand: (info.brand).trim(),
      model: (info.model).trim(),
    );
  }

  static BatteryGuide? forAndroid({
    required String manufacturer,
    required String brand,
    required String model,
  }) {
    final m = manufacturer.toLowerCase();
    final b = brand.toLowerCase();
    final combined = '$m $b ${model.toLowerCase()}';

    if (combined.contains('xiaomi') || combined.contains('redmi') || combined.contains('poco')) {
      return const BatteryGuide(
        title: 'Xiaomi / Redmi / POCO (MIUI/HyperOS)',
        steps: [
          'Settings → Apps → Manage apps → TringoBiz → Battery saver → No restrictions',
          'Settings → Battery → (or) App battery saver → set TringoBiz to Unrestricted',
          'Security app → Permissions → Autostart → enable for TringoBiz (if available)',
        ],
      );
    }

    if (combined.contains('vivo') || combined.contains('iqoo')) {
      return const BatteryGuide(
        title: 'Vivo / iQOO (Funtouch OS)',
        steps: [
          'Settings → Battery → Background power consumption management → TringoBiz → Allow',
          'Settings → Apps → TringoBiz → Battery → Unrestricted (if available)',
          'iManager → App manager → AutoStart → enable for TringoBiz (if available)',
        ],
      );
    }

    if (combined.contains('oppo') || combined.contains('realme') || combined.contains('oneplus')) {
      return const BatteryGuide(
        title: 'Oppo / Realme / OnePlus (ColorOS/OxygenOS)',
        steps: [
          'Settings → Battery → More settings → App battery management → TringoBiz → Allow',
          'Settings → Apps → TringoBiz → Battery usage → Unrestricted/Don’t optimize',
          'Security/Phone Manager → Auto launch → enable for TringoBiz (if available)',
        ],
      );
    }

    if (combined.contains('samsung')) {
      return const BatteryGuide(
        title: 'Samsung (One UI)',
        steps: [
          'Settings → Battery and device care → Battery → Background usage limits',
          'Put unused apps to sleep → OFF for TringoBiz (or add to Never sleeping apps)',
          'Settings → Apps → TringoBiz → Battery → Allow background activity',
        ],
      );
    }

    return const BatteryGuide(
      title: 'Android (General)',
      steps: [
        'Settings → Apps → TringoBiz → Battery → set to Unrestricted/Don’t optimize (if available)',
        'Settings → Battery → Battery optimization → find TringoBiz → Don’t optimize',
      ],
    );
  }
}

