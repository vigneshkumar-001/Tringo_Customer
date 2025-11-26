import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Utility/app_color.dart';

class CurrentLocationWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final String? locationIcon;
  final String? dropDownIcon;
  final TextStyle? textStyle;
  final Color? iconColor;

  const CurrentLocationWidget({
    super.key,
    this.onTap,
    this.locationIcon,
    this.dropDownIcon,
    this.textStyle,
    this.iconColor,
  });

  @override
  State<CurrentLocationWidget> createState() => _CurrentLocationWidgetState();
}

class _CurrentLocationWidgetState extends State<CurrentLocationWidget> {
  String? _currentAddress;
  bool _loading = true;
  StreamSubscription<ServiceStatus>? _serviceSub;

  @override
  void initState() {
    super.initState();
    _initLocationFlow();
    _listenServiceChanges();
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    super.dispose();
  }

  Future<void> _initLocationFlow() async {
    setState(() => _loading = true);

    try {
      // 1) Service enabled?
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services disabled';
          _loading = false;
        });
        return;
      }

      // 2) Permission check
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        setState(() {
          _currentAddress = 'Permission denied';
          _loading = false;
        });
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Permission permanently denied';
          _loading = false;
        });
        return;
      }

      // 3) Get current position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4) Reverse geocode
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isNotEmpty) {
        final p = marks.first;
        final parts = <String>[
          if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
          if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          if ((p.administrativeArea ?? '').trim().isNotEmpty)
            p.administrativeArea!.trim(),
        ];
        _currentAddress = parts.join(', ');
      } else {
        _currentAddress = 'Unknown location';
      }
    } catch (e) {
      _currentAddress = 'Unable to fetch location';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _listenServiceChanges() {
    _serviceSub = Geolocator.getServiceStatusStream().listen((status) {
      if (status == ServiceStatus.enabled) {
        _initLocationFlow(); // GPS turned on → refresh
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.lowLightBlue,
              AppColor.lowLightBlue.withOpacity(0.5),
              AppColor.white.withOpacity(0.3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.locationIcon != null)
              Image.asset(
                widget.locationIcon!,
                height: 18,
                color: AppColor.blue,
              ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _loading
                    ? 'Fetching location...'
                    : (_currentAddress ?? 'Unknown location'),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style:
                    widget.textStyle ??
                    GoogleFonts.mulish(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(width: 6),
            if (widget.dropDownIcon != null)
              Image.asset(
                widget.dropDownIcon!,
                height: 11,
                color: AppColor.darkBlue,
              ),
          ],
        ),
      ),
    );
  }
}
