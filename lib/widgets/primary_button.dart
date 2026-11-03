import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.white,
        ),
      )
          : Text(text),
    );
  }
}