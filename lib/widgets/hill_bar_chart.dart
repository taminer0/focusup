import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HillBarChart extends StatelessWidget {
  final List<int> values;
  final double height;
  final String imageAsset;

  const HillBarChart({
    super.key,
    required this.values,
    this.height = 260,
    this.imageAsset = 'assets/images/Nuidoi.png',
  });

  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
    final ratios = [for (final v in values) maxV == 0 ? 0.0 : v / maxV];

    return SizedBox(
      height: height,
      width: double.infinity,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(values.join(',')),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => ClipPath(
          clipper: _BarsClipper(ratios, t),
          child: child,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lớp nền gradient: lấp chỗ trong suốt của ảnh
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.hillGreenDark,
                    AppColors.hillGreenLight,
                    AppColors.yellowLight,
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
              ),
            ),
            // Ảnh quả đồi nằm đè lên để có hạt và đường cong
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ],
        ),
      ),
    );
  }
}

class _BarsClipper extends CustomClipper<Path> {
  final List<double> ratios;
  final double t;
  _BarsClipper(this.ratios, this.t);

  @override
  Path getClip(Size size) {
    final path = Path();
    final n = ratios.length;
    if (n == 0) return path;

    final gap = n > 8 ? 8.0 : 16.0;
    final barW = (size.width - gap * (n - 1)) / n;
    final radius = Radius.circular(barW * 0.3); // đầu cột tròn

    for (var i = 0; i < n; i++) {
      final h = (ratios[i] * (size.height - 8) * t).clamp(barW, size.height);
      final left = i * (barW + gap);
      path.addRRect(RRect.fromRectAndCorners(
        Rect.fromLTWH(left, size.height - h, barW, h),
        topLeft: radius,
        topRight: radius,
      ));
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _BarsClipper old) =>
      old.t != t || old.ratios != ratios;
}