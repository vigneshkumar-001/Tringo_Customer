import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tringo_app/Core/Utility/app_loader.dart';
import 'package:tringo_app/Core/Utility/app_snackbar.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Login%20Screen/Controller/login_notifier.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Model/surprise_offer_response.dart';
import 'package:tringo_app/Presentation/OnBoarding/Screens/Surprise_Screens/Screens/Opened_surprise_offer_screen.dart';

class SurpriseOfferDetailsFromPush extends ConsumerStatefulWidget {
  final String shopId;
  final String offerId;

  const SurpriseOfferDetailsFromPush({
    super.key,
    required this.shopId,
    required this.offerId,
  });

  @override
  ConsumerState<SurpriseOfferDetailsFromPush> createState() =>
      _SurpriseOfferDetailsFromPushState();
}

class _SurpriseOfferDetailsFromPushState
    extends ConsumerState<SurpriseOfferDetailsFromPush> {
  bool _loading = true;
  String _error = '';
  SurpriseStatusResponse? _response;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final shopId = widget.shopId.trim();
    final offerId = widget.offerId.trim();

    if (shopId.isEmpty || offerId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Invalid offer';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _response = null;
    });

    final api = ref.read(apiDataSourceProvider);
    final result = await api.surpriseOfferDetails(shopId: shopId, offerId: offerId);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _loading = false;
          _error = failure.message;
        });
        AppSnackBar.error(context, failure.message);
      },
      (resp) {
        setState(() {
          _loading = false;
          _error = '';
          _response = resp;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final resp = _response;
    if (resp != null) {
      return OpenedSurpriseOfferScreen(response: resp);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surprise Offer'),
      ),
      body: Center(
        child: _loading
            ? ThreeDotsLoader(dotColor: Colors.black)
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error.isNotEmpty ? _error : 'Unable to open offer',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _load,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

