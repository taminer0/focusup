import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/task.dart';
import '../../providers/app_limit_provider.dart' show LoadStatus;
import '../../providers/task_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/confirm_delete_dialog.dart';
import '../../widgets/swipe_task_card.dart';
import 'add_task_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  static const _labels = {
    TaskFilter.all: 'Tất cả',
    TaskFilter.today: 'Hôm nay',
    TaskFilter.week: 'Tuần này',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TaskProvider>();
    final tasks = p.filtered;

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Tiêu đề ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text('Danh sách nhiệm vụ',
                      style: AppTextStyles.title.copyWith(fontSize: 22)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ---------- Bộ lọc ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final f in TaskFilter.values) ...[
                    Expanded(
                      child: _FilterChip(
                        label: _labels[f]!,
                        selected: p.filter == f,
                        onTap: () => p.setFilter(f),
                      ),
                    ),
                    if (f != TaskFilter.values.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------- Danh sách ----------
            Expanded(child: _buildBody(context, p, tasks)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await AddTaskScreen.open(context);
          // Lưu xong thì đóng danh sách và nhảy về tab Trang chủ (0)
          if (saved && context.mounted) Navigator.of(context).pop(0);
        },
        child: SvgPicture.asset(
          'assets/icons/add.svg',
          width: 22,
          height: 22,
          colorFilter:
          const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
        ),
      ),
      // currentIndex -1: không tab nào sáng. Bấm tab -> quay về và chuyển tab.
      bottomNavigationBar: AppBottomNav(
        currentIndex: -1,
        onTap: (i) => Navigator.of(context).pop(i),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaskProvider p, List<Task> tasks) {
    if (p.status == LoadStatus.loading && tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
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
    if (tasks.isEmpty) {
      // TODO: thay bằng hình minh họa trạng thái rỗng trong Figma
      return Center(
        child: Text('Chưa có nhiệm vụ nào', style: AppTextStyles.caption),
      );
    }
    return RefreshIndicator(
      onRefresh: p.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final t = tasks[i];
          return SwipeTaskCard(
            task: t,
            onToggle: () => p.toggleDone(t.id),
            onEdit: () async {
              await AddTaskScreen.open(context, initial: t);
            },
            onConfirmDelete: () => showConfirmDeleteDialog(context, t),
            onDeleted: () => p.remove(t.id),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.green : AppColors.greenLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}