import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_icons.dart';
import '../../core/app_text_styles.dart';
import '../../models/app_limit.dart';
import '../../providers/app_limit_provider.dart';
import '../../providers/detox_provider.dart';
import '../../widgets/svg_toggle.dart';
import '../../widgets/app_icon_view.dart';
import '../apps/app_select_screen.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  // TODO: lấy từ UserProvider sau khi đăng nhập
  static const String _userName = 'Mi';

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Chào buổi sáng,';
    if (h < 13) return 'Chào buổi trưa,';
    if (h < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final limitProvider = context.watch<AppLimitProvider>();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Nền đồi dưới đáy
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/Nen5.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),
        ),

        // Mặt trời góc phải
        Positioned(
          top: size.height * 0.02,
          right: size.width * 0.04,
          child: IgnorePointer(
            child: SvgPicture.asset(
              'assets/images/Sunnhat5.svg',
              width: size.width * 0.2,
            ),
          ),
        ),

        // Nội dung
        RefreshIndicator(
          onRefresh: limitProvider.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_greeting, style: AppTextStyles.heading),
                    const SizedBox(width: 6),
                    Text(_userName,
                        style: AppTextStyles.title.copyWith(fontSize: 26)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: size.width * 0.7,
                  child: Text(
                    'Giảm xao nhãng, tăng hiệu suất và tạo nên phiên bản tốt hơn của bạn',
                    style: AppTextStyles.caption.copyWith(height: 1.4),
                  ),
                ),
                const SizedBox(height: 26),

                const _DetoxCard(),

                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ứng dụng giới hạn', style: AppTextStyles.heading),
                    GestureDetector(
                      onTap: () {
                        // TODO: sang danh sách tất cả app giới hạn
                      },
                      child: Text('Xem tất cả  >',
                          style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _buildLimitList(limitProvider),

                const SizedBox(height: 12),
                const _AddAppCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLimitList(AppLimitProvider p) {
    switch (p.status) {
      case LoadStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      case LoadStatus.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text('Không tải được dữ liệu', style: AppTextStyles.caption),
              TextButton(onPressed: p.load, child: const Text('Thử lại')),
            ],
          ),
        );
      case LoadStatus.success:
        if (p.limits.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Bạn chưa giới hạn ứng dụng nào',
                style: AppTextStyles.caption),
          );
        }
        return Column(
          children: [
            for (final item in p.limits) ...[
              _LimitTile(item: item),
              const SizedBox(height: 14),
            ],
          ],
        );
    }
  }
}

// ======================= Thẻ Detox Mode =======================
class _DetoxCard extends StatelessWidget {
  const _DetoxCard();

  @override
  Widget build(BuildContext context) {
    final detox = context.watch<DetoxProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_outlined,
                color: AppColors.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detox Mode',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  'Chặn các ứng dụng gây xao nhãng và giúp bạn tập trung hơn.',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SvgToggle(value: detox.enabled, onChanged: detox.setEnabled),
        ],
      ),
    );
  }
}

// ======================= Một ứng dụng giới hạn =======================
class _LimitTile extends StatelessWidget {
  final AppLimit item;
  const _LimitTile({required this.item});

  String _fmtLimit(int m) {
    if (m >= 60 && m % 60 == 0) return '${m ~/ 60}h/lần dùng';
    return '${m}m/lần dùng';
  }

  String _fmtRemaining(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s còn lại';
    return '${m}m ${s.toString().padLeft(2, '0')}s còn lại';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: mở hộp thoại đặt thời gian giới hạn cho app này
      },
      onLongPress: () =>
          context.read<AppLimitProvider>().startDemoSession(item.id),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                AppIconView(packageName: item.packageName, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(_fmtLimit(item.sessionLimitMinutes),
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/arrow_forward_ios.svg',
                  width: 14,
                  height: 14,
                  colorFilter: const ColorFilter.mode(
                      AppColors.textTertiary, BlendMode.srcIn),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    size: 18, color: AppColors.coral),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(end: item.progress),
                      duration: const Duration(milliseconds: 400),
                      builder: (_, value, __) => LinearProgressIndicator(
                        value: value,
                        minHeight: 7,
                        color: AppColors.coral,
                        backgroundColor: AppColors.coralLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(_fmtRemaining(item.remainingSeconds),
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= Thẻ Thêm ứng dụng =======================
class _AddAppCard extends StatelessWidget {
  const _AddAppCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => AppSelectScreen.open(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thêm ứng dụng',
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    'Chọn ứng dụng bạn muốn giới hạn thời gian sử dụng',
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/arrow_forward_ios.svg',
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                  AppColors.textTertiary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}