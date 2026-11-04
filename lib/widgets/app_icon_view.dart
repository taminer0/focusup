import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_icons.dart';

class AppIconView extends StatelessWidget {
  final String packageName;
  final double size;

  const AppIconView({super.key, required this.packageName, this.size = 48});

  Widget _fallback() => Container(
    color: AppColors.greenLight,
    child: const Icon(Icons.apps, color: AppColors.green),
  );

  @override
  Widget build(BuildContext context) {
    final path = AppIcons.of(packageName);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: SizedBox(
        width: size,
        height: size,
        child: path == null
            ? _fallback()
            : Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      ),
    );
  }
}