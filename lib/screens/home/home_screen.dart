import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import '../../widgets/usage_ring.dart';
import '../tasks/add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  /// Bấm "Xem tất cả" -> MainShell mở màn Danh sách nhiệm vụ
  final VoidCallback onSeeAllTasks;

  const HomeScreen({super.key, required this.onSeeAllTasks});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: lấy từ ProfileProvider
  final String _userName = 'Mi';

  // TODO: lấy từ dữ liệu sử dụng thật (UsageStatsManager) sau này
  final Duration _usedToday = const Duration(hours: 2, minutes: 34);

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Chào buổi sáng,';
    if (h < 13) return 'Chào buổi trưa,';
    if (h < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }

  String _formatDuration(Duration d) =>
      '${d.inHours}h ${d.inMinutes.remainder(60)}m';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.todayTasks;
    final doneCount = tasks.where((t) => t.isDone).length;

    return Stack(
      children: [
        // ---------- Nền đồi kem dưới đáy ----------
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/Nennui4.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomRight,
            ),
          ),
        ),

        // ---------- Cành lá góc trên phải ----------
        Positioned(
          top: -size.height * 0.07,
          right: 0,
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/nhanh4.png',
              width: size.width * 0.38,
            ),
          ),
        ),

        // ---------- Mặt trời nhỏ ----------
        Positioned(
          top: size.height * 0.07,
          left: size.width * 0.55,
          child: IgnorePointer(
            child: SvgPicture.asset(
              'assets/images/Sunbe4.svg',
              width: size.width * 0.15,
            ),
          ),
        ),

        // ---------- Nội dung cuộn ----------
        RefreshIndicator(
          onRefresh: taskProvider.load,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting, style: AppTextStyles.body),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: AppTextStyles.title.copyWith(fontSize: 26),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: size.width * 0.55,
                  child: Text(
                    'Hôm nay bạn muốn dành\nthời gian cho điều gì?',
                    style: AppTextStyles.caption.copyWith(height: 1.4),
                  ),
                ),
                const SizedBox(height: 26),

                _usageCard(),

                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Nhiệm vụ hôm nay', style: AppTextStyles.heading),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onSeeAllTasks,
                      child: Text(
                        'Xem tất cả  >',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$doneCount/${tasks.length} hoàn thành',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('Hôm nay bạn chưa có nhiệm vụ nào',
                        style: AppTextStyles.caption),
                  )
                else
                  for (final task in tasks) ...[
                    TaskCard(
                      task: task,
                      onToggle: () => context
                          .read<TaskProvider>()
                          .toggleDone(task.id),
                    ),
                    const SizedBox(height: 14),
                  ],
              ],
            ),
          ),
        ),

        // ---------- Nút thêm ----------
        Positioned(
          right: 20,
          bottom: 20,
          child: Material(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap:() {
                AddTaskScreen.open(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: SvgPicture.asset(
                  'assets/icons/add.svg',
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(
                      AppColors.white, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Thẻ xanh đậm: chữ bên trái, vòng 24h bên phải.
  Widget _usageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian sử dụng điện thoại',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _formatDuration(_usedToday),
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'hôm nay',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          UsageRing(used: _usedToday),
        ],
      ),
    );
  }
}