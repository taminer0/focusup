import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/task.dart';
import 'task_card.dart';

class SwipeTaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final Future<void> Function() onEdit; // vuốt phải
  final Future<bool> Function() onConfirmDelete; // vuốt trái: true = xóa
  final VoidCallback onDeleted;

  const SwipeTaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onConfirmDelete,
    required this.onDeleted,
  });

  /// Nền phía sau: icon và màu đậm dần theo mức vuốt.
  Widget _bg({
    required Color color,
    required IconData icon,
    required Alignment align,
    required double threshold,
  }) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.white, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      dismissThresholds: const {
        DismissDirection.endToStart: 0.66, // vuốt trái ~2/3
        DismissDirection.startToEnd: 0.4, // vuốt phải ~40%
      },
      movementDuration: const Duration(milliseconds: 250),
      background: _bg(
        color: AppColors.green,
        icon: Icons.edit_outlined,
        align: Alignment.centerLeft,
        threshold: 0.4,
      ),
      secondaryBackground: _bg(
        color: AppColors.error,
        icon: Icons.delete_outline,
        align: Alignment.centerRight,
        threshold: 0.66,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await onEdit(); // mở màn Sửa
          return false; // luôn trượt thẻ về chỗ cũ
        }
        // Vuốt trái: hỏi trước, chỉ xóa khi người dùng bấm Xóa
        return await onConfirmDelete();
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) onDeleted();
      },
      child: TaskCard(task: task, detailed: true, onToggle: onToggle),
    );
  }
}