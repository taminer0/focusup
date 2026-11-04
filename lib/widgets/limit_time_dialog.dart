import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_catalog.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'app_icon_view.dart';

/// Trả về số phút người dùng chọn, hoặc null nếu đóng hộp thoại.
Future<int?> showLimitTimeDialog(
    BuildContext context, {
      required AppCatalogItem app,
      required int initialMinutes,
    }) {
  return showDialog<int>(
    context: context,
    builder: (_) => _LimitTimeDialog(app: app, initialMinutes: initialMinutes),
  );
}

class _LimitTimeDialog extends StatefulWidget {
  final AppCatalogItem app;
  final int initialMinutes;
  const _LimitTimeDialog({required this.app, required this.initialMinutes});

  @override
  State<_LimitTimeDialog> createState() => _LimitTimeDialogState();
}

class _LimitTimeDialogState extends State<_LimitTimeDialog> {
  static const _minuteStep = 5;
  static const _maxTotal = 23 * 60 + 55; // tối đa 23 giờ 55 phút

  static const _quick = [
    (30, '30 phút'),
    (60, '1 giờ'),
    (120, '2 giờ'),
    (180, '3 giờ'),
    (240, '4 giờ'),
    (300, '5 giờ'),
  ];

  // Chỉ lưu tổng số phút, giờ và phút tự suy ra từ đó
  late int _total = widget.initialMinutes.clamp(0, _maxTotal);

  int get _hours => _total ~/ 60;
  int get _mins => _total % 60;

  void _change(int delta) =>
      setState(() => _total = (_total + delta).clamp(0, _maxTotal));

  void _setQuick(int total) => setState(() => _total = total);

  /// Nút tròn viền mảnh, giống Figma
  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textSecondary, width: 1.4),
        ),
        child: Icon(icon, size: 16, color: AppColors.textPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quickWidth = (MediaQuery.of(context).size.width - 48 - 40 - 24) / 3;

    return Dialog(
      backgroundColor: AppColors.backgroundSecondary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIconView(packageName: widget.app.package, size: 52),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(widget.app.name,
                      style: AppTextStyles.title.copyWith(fontSize: 20)),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: SvgPicture.asset(
                    'assets/icons/close.svg',
                    width: 22,
                    height: 22,
                    placeholderBuilder: (_) => const Icon(Icons.close),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Đặt giới hạn thời gian sử dụng',
                style: AppTextStyles.caption),
            const SizedBox(height: 24),

            // ---------- Một bộ - / + cho cả giờ và phút ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _circleBtn(
                      icon: Icons.remove, onTap: () => _change(-_minuteStep)),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown, // chật thì tự thu nhỏ, không tràn
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: '$_hours',
                              style:
                              AppTextStyles.title.copyWith(fontSize: 22)),
                          TextSpan(text: ' giờ  ', style: AppTextStyles.body),
                          TextSpan(
                              text: '$_mins',
                              style:
                              AppTextStyles.title.copyWith(fontSize: 22)),
                          TextSpan(text: ' phút', style: AppTextStyles.body),
                        ])),
                      ),
                    ),
                  ),
                  _circleBtn(
                      icon: Icons.add, onTap: () => _change(_minuteStep)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------- Chọn nhanh ----------
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final q in _quick)
                  GestureDetector(
                    onTap: () => _setQuick(q.$1),
                    child: Container(
                      width: quickWidth,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _total == q.$1
                            ? AppColors.green
                            : AppColors.hillGrayLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        q.$2,
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _total == q.$1
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
                // Không cho lưu 0 phút
                onPressed:
                _total == 0 ? null : () => Navigator.pop(context, _total),
                child: const Text('Lưu'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}