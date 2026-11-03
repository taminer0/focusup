import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    this.hint = '',
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.body),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscure,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon,
                color: AppColors.textTertiary, size: 20),
            suffixIcon: widget.isPassword
                ? IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textTertiary,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
                : null,
          ),
        ),
      ],
    );
  }
}