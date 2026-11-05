import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/svg_toggle.dart';
import '../../widgets/task_card.dart';
import '../../widgets/usage_ring.dart';
import '../calendar/calendar_flow.dart';
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
      fit: StackFit.expand, // luôn cao bằng màn hình
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

        // ---------- Nội dung: phần trên đứng yên, chỉ danh sách nhiệm vụ cuộn ----------
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
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

              const SizedBox(height: 16),
              const _CalendarSyncCard(),

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

              // Chiếm phần còn lại của màn hình, cuộn dọc riêng ở đây.
              Expanded(
                child: RefreshIndicator(
                  onRefresh: taskProvider.load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    // 96 ở đáy để thẻ cuối không bị nút + che
                    padding: const EdgeInsets.only(top: 16, bottom: 96),
                    children: [
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
            ],
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
              onTap: () {
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

// ======================= Hàng đồng bộ Google Calendar =======================
/// Bật -> mở luồng kết nối (bottom sheet rồi màn "Đã kết nối").
/// Tắt -> hỏi xác nhận rồi ngắt kết nối.
class _CalendarSyncCard extends StatelessWidget {
  const _CalendarSyncCard();

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _onToggle(BuildContext context, bool value) async {
    if (value) {
      try {
        // Công tắc tự bật khi CalendarProvider báo đã kết nối.
        // Bấm "Để sau" thì công tắc vẫn tắt.
        await CalendarFlow.ensureConnected(context);
      } catch (_) {
        if (context.mounted) {
          _toast(context, 'Không kết nối được, bạn thử lại nhé');
        }
      }
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ngắt kết nối Google Calendar?',
            style: AppTextStyles.heading),
        content: Text(
          'Nhiệm vụ đã đồng bộ vẫn được giữ lại trong FocusUp, nhưng sẽ không đồng bộ thêm nhiệm vụ mới.',
          style: AppTextStyles.caption.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ngắt kết nối'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    try {
      await context.read<CalendarProvider>().disconnect();
    } catch (_) {
      if (context.mounted) {
        _toast(context, 'Không ngắt được kết nối, bạn thử lại nhé');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connected = context.watch<CalendarProvider>().connected;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logocalen.png',
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.event, size: 36, color: AppColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đồng bộ với Google Calendar',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('Thêm nhiệm vụ vào lịch của bạn',
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SvgToggle(
            value: connected,
            onChanged: (v) => _onToggle(context, v),
          ),
        ],
      ),
    );
  }
}