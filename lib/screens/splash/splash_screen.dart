import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/app_colors.dart';
import '../../core/app_theme.dart';
import '../auth/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../auth/register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // true: tự chuyển sau [delay]. false: đứng yên, bấm vào màn hình mới chuyển.
  static const bool autoNavigate = false;
  static const Duration delay = Duration(seconds: 10);

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (autoNavigate) {
      _timer = Timer(delay, _goNext);
    }
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundSecondary,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _goNext,
          child: Stack(
            children: [
              // Mặt trời
              // Mặt trời
              Positioned(
                top: size.height * 0.14,
                right: size.width * 0.18,
                child: SvgPicture.asset(
                  'assets/images/Sunto.svg',
                  width: size.width * 0.22,
                ),
              ),

              // Núi: dính đáy, rộng bằng màn hình
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/images/nui1.png',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),

              // Logo + khẩu hiệu
              Align(
                alignment: const Alignment(0, -0.3),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (context, value, child) => Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - value)),
                      child: child,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('FocusUp', style: AppTheme.logo(size: 48)),
                      const SizedBox(height: 14),
                      Text(
                        'Less distraction.\nMore you.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w300,
                          height: 1.35,
                          fontSize: 17,
                        ),
                      ),
                    ],
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