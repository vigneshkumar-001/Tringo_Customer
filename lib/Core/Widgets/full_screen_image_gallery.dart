import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTagPrefix;

  const FullScreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTagPrefix,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();

  static Future<void> open(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    String? heroTagPrefix,
  }) async {
    final urls = imageUrls.where((e) => e.trim().isNotEmpty).toList();
    if (urls.isEmpty) return;

    final safeIndex = initialIndex.clamp(0, urls.length - 1);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenImageGallery(
          imageUrls: urls,
          initialIndex: safeIndex,
          heroTagPrefix: heroTagPrefix,
        ),
      ),
    );
  }
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late final PageController _controller;
  late int _index;
  bool _interacting = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              physics: _interacting
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              itemCount: total,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final url = widget.imageUrls[i];
                final heroTag =
                    widget.heroTagPrefix == null ? null : '${widget.heroTagPrefix}_$i';

                final image = InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  panEnabled: true,
                  scaleEnabled: true,
                  clipBehavior: Clip.none,
                  boundaryMargin: const EdgeInsets.all(80),
                  onInteractionStart: (_) => setState(() => _interacting = true),
                  onInteractionEnd: (_) => setState(() => _interacting = false),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const SizedBox(
                        height: 32,
                        width: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                        size: 40,
                      ),
                    ),
                  ),
                );

                if (heroTag == null) return image;

                return Hero(
                  tag: heroTag,
                  child: image,
                );
              },
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close),
                color: Colors.white,
              ),
            ),
            if (total > 1)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${_index + 1}/$total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
