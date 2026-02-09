import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tringo_app/Core/Utility/app_Images.dart';

class DismissibleAdBanner extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onClosed;

  const DismissibleAdBanner({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.onClosed,
  });

  @override
  State<DismissibleAdBanner> createState() => _DismissibleAdBannerState();
}

class _DismissibleAdBannerState extends State<DismissibleAdBanner>
    with SingleTickerProviderStateMixin {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black12, // ✅ prevents white flash
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ✅ Cached Ad image
              CachedNetworkImage(

                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Image.asset(AppImages.addImage, fit: BoxFit.cover),
                errorWidget: (context, url, error) =>
                    Image.asset(AppImages.addImage, fit: BoxFit.cover),
              ),

              // ✅ Soft overlay (doesn't whiten image)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ Close button
              /*Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () {
                    setState(() => _visible = false);
                    widget.onClosed?.call();
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),*/

              // ✅ Label bottom-right
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "T-Ads",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
