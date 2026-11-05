import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/app_limit.dart';
import '../../providers/app_limit_provider.dart';
import '../../widgets/app_icon_view.dart';

/// Thời gian khóa hiển thị trên giao diện.
const int kLockMinutes = 30;

/// Demo: khóa thật chỉ 20 giây. Đặt null để khóa đủ kLockMinutes.
const int? kDemoLockSeconds = 20;

Duration get _lockDuration => kDemoLockSeconds != null
    ? Duration(seconds: kDemoLockSeconds!)
    : const Duration(minutes: kLockMinutes);

class BlockFlow {
  BlockFlow._();

  /// App vượt giới hạn -> mở màn chọn việc.
  static void start(BuildContext context, AppLimit app) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetoxChooseScreen(app: app)),
    );
  }

  /// Mở lại app đang bị khóa -> màn Tạm dừng.
  static void openPause(BuildContext context, AppLimit app) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PauseScreen(app: app)),
    );
  }
}

/// Bọc MainShell: nghe provider, khi có app vượt giới hạn thì mở màn Detox.
class BlockListener extends StatefulWidget {
  final Widget child;
  const BlockListener({super.key, required this.child});

  @override
  State<BlockListener> createState() => _BlockListenerState();
}

class _BlockListenerState extends State<BlockListener> {
  late final AppLimitProvider _p;

  @override
  void initState() {
    super.initState();
    _p = context.read<AppLimitProvider>()..addListener(_check);
  }

  void _check() {
    final id = _p.exceededId;
    if (id == null) return;
    final app = _p.limits.where((e) => e.id == id).firstOrNull;
    _p.clearExceeded();
    if (app != null && mounted) BlockFlow.start(context, app);
  }

  @override
  void dispose() {
    _p.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ======================= Trang trí dùng chung =======================
class _Deco extends StatelessWidget {
  final Widget child;
  const _Deco({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SvgPicture.asset('assets/images/Tren6.svg',
                  fit: BoxFit.fitWidth, alignment: Alignment.topCenter),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SvgPicture.asset('assets/images/Duoi6.svg',
                  fit: BoxFit.fitWidth, alignment: Alignment.bottomCenter),
            ),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

// ======================= Màn hình chặn: Detox Mode =======================
class DetoxChooseScreen extends StatelessWidget {
  final AppLimit app;
  const DetoxChooseScreen({super.key, required this.app});

  // TODO: lấy từ Task của người dùng / API
  static const _options = [
    'Dừng sử dụng ứng dụng',
    'Làm báo cáo',
    'Thể dục hoặc ngồi thiền',
  ];

  void _choose(BuildContext context) {
    context.read<AppLimitProvider>().lock(app.id, _lockDuration);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => PauseScreen(app: app)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: SvgPicture.asset('assets/images/Cumla2.svg',
                  width: size.width * 0.4),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: IgnorePointer(
              child: SvgPicture.asset('assets/images/Nuidoi.svg',
                  width: size.width * 0.95),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Text('Detox Mode',
                      style: AppTextStyles.title
                          .copyWith(fontSize: 34, color: AppColors.text)),
                  const SizedBox(height: 14),
                  Text(
                    'Tạm rời xa những ứng dụng gây xao nhãng.\nTập trung vào điều quan trọng',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  for (final o in _options) ...[
                    _OptionTile(text: o, onTap: () => _choose(context)),
                    const SizedBox(height: 14),
                  ],
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _OptionTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(text,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}

// ======================= Màn 1: Tạm dừng =======================
class PauseScreen extends StatefulWidget {
  final AppLimit app;
  const PauseScreen({super.key, required this.app});

  @override
  State<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends State<PauseScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final until =
    context.read<AppLimitProvider>().lockedUntil(widget.app.id);
    if (until == null) {
      _finish();
      return;
    }
    setState(() => _remaining = until.difference(DateTime.now()));
  }

  void _finish() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => DoneScreen(app: widget.app)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _mmss {
    final m = _remaining.inMinutes.toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return _Deco(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: [
            const Spacer(flex: 5),
            Text('Tạm dừng một\nchút nhé',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                    fontSize: 32, height: 1.25, color: AppColors.text)),
            const SizedBox(height: 36),
            Text(
              '“Hành trình vạn dặm bắt đầu từ một bước chân. Tập trung hôm nay để thấy sự khác biệt ngày mai”',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(height: 1.5),
            ),
            const SizedBox(height: 28),
            Text('Thời gian dự kiến', style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_outlined,
                    size: 22, color: AppColors.text),
                const SizedBox(width: 8),
                Text('$kLockMinutes phút',
                    style: AppTextStyles.title
                        .copyWith(fontSize: 20, color: AppColors.text)),
              ],
            ),
            const SizedBox(height: 10),
            Text('Còn $_mmss',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.green)),
            const Spacer(flex: 6),
          ],
        ),
      ),
    );
  }
}

// ======================= Màn 2: Tuyệt vời =======================
class DoneScreen extends StatefulWidget {
  final AppLimit app;
  const DoneScreen({super.key, required this.app});

  @override
  State<DoneScreen> createState() => _DoneScreenState();
}

class _DoneScreenState extends State<DoneScreen> {
  @override
  void initState() {
    super.initState();
    // Hết giờ khóa: mở lại app, thanh về 0 (sau khung hình đầu để tránh lỗi build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppLimitProvider>().unlock(widget.app.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return _Deco(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 3),
            // Dấu tick + pháo hoa
            SizedBox(
              height: 220,
              width: size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/Phaohoa.png',
                      width: size.width * 0.85,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox()),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.yellowLight,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.tick,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 48, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('Tuyệt vời',
                style: AppTextStyles.title
                    .copyWith(fontSize: 30, color: AppColors.text)),
            const SizedBox(height: 14),
            Text('Bạn đã tạo khoảng trống cho những điều\nquan trọng',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(height: 1.5)),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIconView(
                          packageName: widget.app.packageName, size: 20),
                      const SizedBox(width: 8),
                      Text('${widget.app.name} khả dụng trong',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${widget.app.sessionLimitMinutes} phút',
                      style: AppTextStyles.title
                          .copyWith(fontSize: 22, color: AppColors.text)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Xong',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
            ),
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}