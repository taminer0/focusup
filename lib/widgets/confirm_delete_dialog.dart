import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/task.dart';
import 'task_card.dart';

/// Trả về true nếu người dùng bấm Xóa.
Future<bool> showConfirmDeleteDialog(BuildContext context, Task task) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.backgroundSecondary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textTertiary),
                onPressed: () => Navigator.pop(ctx, false),
              ),
            ),
            Center(
              child: Image.asset(
                'assets/images/Thungrac.png',
                height: 120,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.delete_outline,
                    size: 80,
                    color: AppColors.green),
              ),
            ),
            const SizedBox(height: 12),
            Text('Bạn có chắc muốn xóa nhiệm vụ này?',
                style: AppTextStyles.heading),
            const SizedBox(height: 6),
            Text(
              'Hành động này không thể hoàn tác. Nhiệm vụ sẽ bị xóa khỏi danh sách của bạn.',
              style: AppTextStyles.caption.copyWith(height: 1.4),
            ),
            const SizedBox(height: 14),
            // Thẻ xem trước nhiệm vụ sắp xóa
            TaskCard(task: task, detailed: true, onToggle: () {}),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return ok == true;
}