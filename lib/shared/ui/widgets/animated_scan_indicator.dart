import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Animated forensic scan indicator.
///
/// Displays a pulsing neon ring with a scanning line that moves
/// vertically — used during the "processing" state.
///
/// Uses explicit [AnimationController] as recommended by the
/// flutter-animations skill for full lifecycle control.
class AnimatedScanIndicator extends StatefulWidget {
  const AnimatedScanIndicator({
    super.key,
    this.size = 180.0,
    this.ringColor = AppColors.primary,
    this.lineColor = AppColors.secondary,
    this.label = 'Analizando evidencia...',
  });

  final double size;
  final Color ringColor;
  final Color lineColor;
  final String label;

  @override
  State<AnimatedScanIndicator> createState() => _AnimatedScanIndicatorState();
}

class _AnimatedScanIndicatorState extends State<AnimatedScanIndicator>
    with TickerProviderStateMixin {
  // Ring pulse animation
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  // Scan line animation
  late final AnimationController _scanController;
  late final Animation<double> _scanPosition;

  // Ring rotation animation
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // ─── Pulse (ring glow) ────────────────────────────────────────
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // ─── Scan line (up/down) ──────────────────────────────────────
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scanPosition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    // ─── Ring rotation ────────────────────────────────────────────
    _rotateController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _pulseController,
              _scanController,
              _rotateController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: _ScanIndicatorPainter(
                  ringColor: widget.ringColor,
                  lineColor: widget.lineColor,
                  pulseScale: _pulseScale.value,
                  pulseOpacity: _pulseOpacity.value,
                  scanPosition: _scanPosition.value,
                  rotationAngle: _rotateController.value * 2 * math.pi,
                ),
                size: Size(widget.size, widget.size),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.label,
          style: TextStyle(
            color: widget.ringColor.withValues(alpha: 0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the forensic scan indicator.
class _ScanIndicatorPainter extends CustomPainter {
  _ScanIndicatorPainter({
    required this.ringColor,
    required this.lineColor,
    required this.pulseScale,
    required this.pulseOpacity,
    required this.scanPosition,
    required this.rotationAngle,
  });

  final Color ringColor;
  final Color lineColor;
  final double pulseScale;
  final double pulseOpacity;
  final double scanPosition;
  final double rotationAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2 - 12;

    // ─── Outer glow ring (pulsing) ─────────────────────────────
    final glowPaint = Paint()
      ..color = ringColor.withValues(alpha: pulseOpacity * 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, baseRadius * pulseScale, glowPaint);

    // ─── Main ring ─────────────────────────────────────────────
    final ringPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, baseRadius, ringPaint);

    // ─── Inner ring (thinner) ──────────────────────────────────
    final innerRingPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, baseRadius * 0.72, innerRingPaint);

    // ─── Rotating arc segment ──────────────────────────────────
    final arcPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    final arcRect = Rect.fromCircle(center: center, radius: baseRadius);
    canvas.drawArc(arcRect, 0, math.pi * 0.5, false, arcPaint);
    canvas.drawArc(arcRect, math.pi, math.pi * 0.35, false, arcPaint);

    canvas.restore();

    // ─── Scan line (horizontal, moving vertically) ─────────────
    final scanY = center.dy - baseRadius * 0.6 +
        (baseRadius * 1.2 * scanPosition);

    final scanLinePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.0),
          lineColor.withValues(alpha: 0.8),
          lineColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(
        Rect.fromPoints(
          Offset(center.dx - baseRadius * 0.55, scanY),
          Offset(center.dx + baseRadius * 0.55, scanY),
        ),
      )
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - baseRadius * 0.55, scanY),
      Offset(center.dx + baseRadius * 0.55, scanY),
      scanLinePaint,
    );

    // ─── Scan line glow ────────────────────────────────────────
    final scanGlowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(
      Offset(center.dx - baseRadius * 0.5, scanY),
      Offset(center.dx + baseRadius * 0.5, scanY),
      scanGlowPaint..strokeWidth = 10,
    );

    // ─── Center dot ────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = ringColor.withValues(alpha: pulseOpacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 3, dotPaint);

    // ─── Crosshair lines ───────────────────────────────────────
    final crossPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(center.dx, center.dy - baseRadius * 0.3),
      Offset(center.dx, center.dy + baseRadius * 0.3),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx - baseRadius * 0.3, center.dy),
      Offset(center.dx + baseRadius * 0.3, center.dy),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanIndicatorPainter oldDelegate) => true;
}
