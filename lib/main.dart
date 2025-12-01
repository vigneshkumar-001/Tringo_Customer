import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'Core/Utility/app_color.dart';
import 'Core/app_go_routes.dart';
import 'Presentation/OnBoarding/Screens/Login Screen/login_mobile_number.dart';
import 'Presentation/OnBoarding/Screens/Splash_screen.dart';
import 'Presentation/OnBoarding/Screens/fill_profile/Screens/fill_profile.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp.router(
          routerConfig: goRouter,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(scaffoldBackgroundColor: AppColor.white),
        );
      },
    );
  }
}

// class SimInfoScreen extends StatefulWidget {
//   const SimInfoScreen({super.key});
//
//   @override
//   State<SimInfoScreen> createState() => _SimInfoScreenState();
// }
//
// class _SimInfoScreenState extends State<SimInfoScreen> {
//   static const _channel = MethodChannel('sim_info');
//
//   List<Map<String, dynamic>> _sims = [];
//   bool _loading = true;
//   String? _error;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSimInfo();
//   }
//
//   Future<void> _loadSimInfo() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//
//     // Request phone permission (READ_PHONE_STATE)
//     PermissionStatus status = await Permission.phone.status;
//     if (!status.isGranted) {
//       status = await Permission.phone.request();
//     }
//
//     if (!status.isGranted) {
//       setState(() {
//         _loading = false;
//         _error = 'Phone permission is required to read SIM info.';
//       });
//       return;
//     }
//
//     try {
//       final result = await _channel.invokeMethod<List<dynamic>>('getSimInfo');
//
//       final sims = (result ?? [])
//           .cast<Map<dynamic, dynamic>>()
//           .map((e) => e.map((key, value) => MapEntry(key.toString(), value)))
//           .toList();
//
//       debugPrint('SIMs from native: ${sims.length}');
//       for (var i = 0; i < sims.length; i++) {
//         debugPrint(
//             'SIM[$i] slot=${sims[i]["slotIndex"]}, carrier=${sims[i]["carrierName"]}, iso=${sims[i]["countryIso"]}, number=${sims[i]["number"]}');
//       }
//
//       setState(() {
//         _sims = sims;
//         _loading = false;
//       });
//     } on PlatformException catch (e, stack) {
//       debugPrint('NATIVE SIM ERROR (PlatformException): $e');
//       debugPrint('STACKTRACE: $stack');
//       setState(() {
//         _loading = false;
//         _error = 'Unable to read SIM details on this device.';
//       });
//     } catch (e, stack) {
//       debugPrint('NATIVE SIM ERROR: $e');
//       debugPrint('STACKTRACE: $stack');
//       setState(() {
//         _loading = false;
//         _error = 'Unexpected error: $e';
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     if (_error != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('SIM Details (native)')),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   _error!,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _loadSimInfo,
//                   child: const Text('Retry'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('SIM Details (native)')),
//       body: _sims.isEmpty
//           ? const Center(child: Text('No SIM detected'))
//           : ListView.builder(
//         itemCount: _sims.length,
//         itemBuilder: (context, index) {
//           final sim = _sims[index];
//           final number = (sim['number'] as String?) ?? '';
//           return Card(
//             margin: const EdgeInsets.all(12),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'SIM ${index + 1} (slot ${sim["slotIndex"]})',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text('Carrier: ${sim["carrierName"] ?? "Unknown"}'),
//                   Text('Country: ${sim["countryIso"] ?? "Unknown"}'),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Phone Number: ${number.isNotEmpty ? number : "Not available"}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
