import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_color.dart';
import 'package:tringo_app/Core/Widgets/Common%20Bottom%20Navigation%20bar/service_and_shops_details.dart';
import 'package:tringo_app/api/Repository/api_url.dart';

class PublicQrShopResolver extends StatefulWidget {
  const PublicQrShopResolver({super.key, required this.publicQrToken});

  final String publicQrToken;

  @override
  State<PublicQrShopResolver> createState() => _PublicQrShopResolverState();
}

class _PublicQrShopResolverState extends State<PublicQrShopResolver> {
  late Future<String> _shopIdFuture;

  @override
  void initState() {
    super.initState();
    _shopIdFuture = _resolveShopId();
  }

  Future<String> _resolveShopId() async {
    final token = widget.publicQrToken.trim();
    if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)) {
      throw const FormatException('This shop QR link is invalid.');
    }

    final response = await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    ).get<dynamic>(ApiUrl.publicQrShop(publicQrToken: token));

    final envelope = response.data;
    final payload = envelope is Map ? (envelope['data'] ?? envelope) : null;
    final shop = payload is Map ? payload['shop'] : null;
    final appTarget = shop is Map ? shop['appTarget'] : null;
    final shopId = appTarget is Map
        ? (appTarget['shopId'] ?? '').toString().trim()
        : '';
    if (shopId.isEmpty) {
      throw const FormatException('This shop QR link is unavailable.');
    }
    return shopId;
  }

  void _retry() {
    setState(() => _shopIdFuture = _resolveShopId());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _shopIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColor.white,
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(color: AppColor.darkBlue),
              ),
            ),
          );
        }

        final shopId = snapshot.data ?? '';
        if (snapshot.hasError || shopId.isEmpty) {
          return Scaffold(
            backgroundColor: AppColor.white,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.link_off_rounded,
                        size: 52,
                        color: AppColor.darkBlue,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Shop QR unavailable',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This link may be invalid, disabled, or temporarily unavailable.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _retry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return ServiceAndShopsDetails(shopId: shopId, initialIndex: 4);
      },
    );
  }
}
