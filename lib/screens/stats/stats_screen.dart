import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/usage_stats.dart';
import '../../providers/app_limit_provider.dart' show LoadStatus;
import '../../providers/stats_provider.dart';
import '../../widgets/app_icon_view.dart';
import '../../widgets/hill_bar_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static String fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StatsProvider>();
    final summary = p.summary;

    return RefreshIndicator(
      onRefresh: () => p.load(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PeriodTabs(
              current: p.period,
              onChanged: (v) => p.load(v),
            ),
            const SizedBox(height: 28),
            Text('Thời gian sử dụng',
                style: AppTextStyles.title
                    .copyWith(fontSize: 20, color: AppColors.green)),
            const SizedBox(height: 4),
            Text(
              summary == null ? '--' : fmt(summary.totalMinutes),
              style: AppTextStyles.title
                  .copyWith(fontSize: 30, color: AppColors.green),
            ),
            const SizedBox(height: 28),

            if (p.status == LoadStatus.error)
              _ErrorBox(onRetry: () => p.load())
            else if (summary == null)
              const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              HillBarChart(values: summary.bars),

            const Divider(height: 1),
            const SizedBox(height: 24),
            Text('Ứng dụng nhiều nhất',
                style: AppTextStyles.title
                    .copyWith(fontSize: 20, color: AppColors.green)),
            const SizedBox(height: 14),

            if (summary != null)
              for (var i = 0; i < summary.topApps.length; i++) ...[
                _AppRow(item: summary.topApps[i]),
                if (i != summary.topApps.length - 1) const Divider(height: 1),
              ],
          ],
        ),
      ),
    );
  }
}

// ---------- Tab Tuần / Tháng / Năm ----------
class _PeriodTabs extends StatelessWidget {
  final StatsPeriod current;
  final ValueChanged<StatsPeriod> onChanged;

  const _PeriodTabs({required this.current, required this.onChanged});

  static const _labels = {
    StatsPeriod.week: 'Tuần',
    StatsPeriod.month: 'Tháng',
    StatsPeriod.year: 'Năm',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final period in StatsPeriod.values)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(period),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: period == current
                        ? AppColors.yellowLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _labels[period]!,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: period == current
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- Một dòng ứng dụng ----------
class _AppRow extends StatelessWidget {
  final AppUsageItem item;
  const _AppRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          AppIconView(packageName: item.packageName, size: 40),
          const SizedBox(width: 16),
          Expanded(child: Text(item.name, style: AppTextStyles.body)),
          Text(StatsScreen.fmt(item.minutes),
              style: AppTextStyles.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBox({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Không tải được dữ liệu', style: AppTextStyles.caption),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}