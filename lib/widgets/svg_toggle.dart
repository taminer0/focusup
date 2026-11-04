import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;

  const SvgToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: SvgPicture.asset(
        value ? 'assets/icons/on.svg' : 'assets/icons/off.svg',
        width: width,
      ),
    );
  }
}