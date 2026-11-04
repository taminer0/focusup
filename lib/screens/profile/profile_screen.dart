import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/app_limit_provider.dart' show LoadStatus;
import '../../providers/profile_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  /// Chuyển tab ở MainShell: 0 Trang chủ, 1 Tập trung, 2 Thống kê, 3 Hồ sơ
  final ValueChanged<int> onGoToTab;
  final VoidCallback onOpenTasks;
  const ProfileScreen({super.key, required this.onGoToTab, required this.onOpenTasks });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final profile = p.profile;

    if (p.status == LoadStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Không tải được dữ liệu', style: AppTextStyles.caption),
            TextButton(onPressed: p.load, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: p.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          children: [
            // ---------- Avatar ----------
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(6),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.yellowLight,
                    child: const Icon(Icons.person,
                        size: 64, color: AppColors.green),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(profile.name,
                style: AppTextStyles.title
                    .copyWith(fontSize: 24, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(profile.email, style: AppTextStyles.caption),
            const SizedBox(height: 20),

            // ---------- Số liệu nhanh ----------
            Row(
              children: [
                Expanded(child: _stat('${profile.taskCount}', 'Nhiệm vụ')),
                Expanded(child: _stat('${profile.streak}', 'Chuỗi')),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),

            // ---------- Menu chính ----------
            _menuItem(
              icon: 'assets/icons/ballot.svg',
              label: 'Nhiệm vụ của tôi',
              onTap: onOpenTasks,
            ),
            _menuItem(
              icon: 'assets/icons/thongke.svg',
              label: 'Thống kê',
              onTap: () => onGoToTab(2),
            ),
            _menuItem(
              icon: 'assets/icons/clock.svg',
              label: 'Giới hạn thời gian',
              onTap: () => onGoToTab(1),
            ),
            _menuItem(
              icon: 'assets/icons/settings.svg',
              label: 'Đăng xuất',
              onTap: () => _confirmLogout(context),
            ),

            const Divider(),
            const SizedBox(height: 8),

            // ---------- Tổng quan ----------
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Tổng quan',
                  style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ),
            _menuItem(
              icon: 'assets/icons/brightness.svg',
              label: 'Giao diện',
              value: p.theme,
              compact: true,
              onTap: () => _pickOption(
                context,
                title: 'Giao diện',
                options: const ['Light'],
                current: p.theme,
                onSelected: p.setTheme,
              ),
            ),
            _menuItem(
              icon: 'assets/icons/brand.svg',
              label: 'Ngôn ngữ',
              value: p.language,
              compact: true,
              onTap: () => _pickOption(
                context,
                title: 'Ngôn ngữ',
                options: const ['Tiếng Việt', 'English'],
                current: p.language,
                onSelected: p.setLanguage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String number, String label) {
    return Column(
      children: [
        Text(number,
            style: AppTextStyles.title
                .copyWith(fontSize: 30, color: AppColors.text)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _menuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    String? value,
    bool compact = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: compact ? 12 : 18, horizontal: 4),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary, BlendMode.srcIn),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.body.copyWith(
                      fontSize: compact ? 14 : 15,
                      color: AppColors.textSecondary)),
            ),
            if (value != null) ...[
              Text(value,
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
              const SizedBox(width: 6),
            ],
            SvgPicture.asset(
              'assets/icons/arrow_forward_ios.svg',
              width: 13,
              height: 13,
              colorFilter: const ColorFilter.mode(
                  AppColors.textTertiary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Đăng xuất')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    await context.read<ProfileProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _pickOption(
      BuildContext context, {
        required String title,
        required List<String> options,
        required String current,
        required ValueChanged<String> onSelected,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.heading),
            for (final o in options)
              ListTile(
                title: Text(o),
                trailing: o == current
                    ? const Icon(Icons.check, color: AppColors.green)
                    : null,
                onTap: () {
                  onSelected(o);
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}