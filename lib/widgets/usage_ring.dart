import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Vòng tròn 24h: cung vàng là thời gian đã dùng điện thoại.
class UsageRing extends StatelessWidget {
  final Duration used;
  final double size;
  final double strokeWidth;

  const UsageRing({
    super.key,
    required this.used,
    this.size = 84,
    this.strokeWidth = 9,
  });

  @override
  Widget build(BuildContext context) {
    // 24h = 1440 phút
    final progress = (used.inMinutes / 1440).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _RingPainter({required this.progress, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);

    // Vòng nền (24h)
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = AppColors.white.withValues(alpha: 0.12);
    canvas.drawArc(rect, 0, 2 * math.pi, false, track);

    // Cung vàng (đã dùng), bắt đầu từ 12 giờ
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.yellow;
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth;
}