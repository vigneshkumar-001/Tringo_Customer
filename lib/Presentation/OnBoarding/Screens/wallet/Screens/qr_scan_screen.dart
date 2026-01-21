import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  final String? title;
  const QrScanScreen({super.key, this.title});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _handled = false;

  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;

    final String? value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _handled = true;

    // RETURN SCANNED VALUE
    Navigator.pop(context, value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double scanSize = 260;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CAMERA
          MobileScanner(controller: _controller, onDetect: _onDetect),

          /// DARK OVERLAY
          Positioned.fill(child: OverlayWithHole(scanSize: scanSize)),

          /// SCAN BORDER
          Center(
            child: Container(
              width: scanSize,
              height: scanSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2.5),
              ),
            ),
          ),

          /// TITLE
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                widget.title ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          /// BACK BUTTON
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Back', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// OVERLAY WITH TRANSPARENT CENTER
class OverlayWithHole extends StatelessWidget {
  final double scanSize;
  final double borderRadius;

  const OverlayWithHole({
    super.key,
    required this.scanSize,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final left = (width - scanSize) / 2;
        final top = (height - scanSize) / 2;

        return CustomPaint(
          size: Size(width, height),
          painter: _OverlayPainter(
            holeRect: Rect.fromLTWH(left, top, scanSize, scanSize),
            borderRadius: borderRadius,
          ),
        );
      },
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect holeRect;
  final double borderRadius;

  _OverlayPainter({required this.holeRect, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    final background = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(holeRect, Radius.circular(borderRadius)),
      );

    final path = Path.combine(PathOperation.difference, background, hole);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
