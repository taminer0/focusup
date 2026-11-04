import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool detailed; // true: hiện ngày + địa điểm (màn Danh sách)
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.detailed = false,
    this.onTap,
  });

  static Color colorOf(TaskPriority p) => switch (p) {
    TaskPriority.high => AppColors.coralLight,
    TaskPriority.medium => AppColors.warningLight,
    TaskPriority.low => AppColors.greenLight,
    TaskPriority.special => AppColors.blocked.withValues(alpha: 0.55),
  };

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if (detailed)
        '${task.dateLabel}  ${task.timeRange}'
      else
        task.timeRange,
      if (detailed && task.location != null) task.location!,
    ];

    return Material(
      color: colorOf(task.priority),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        decoration:
                        task.isDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final l in lines)
                      Text(l, style: AppTextStyles.caption),
                  ],
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: task.isDone
                      ? Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        size: 15, color: AppColors.white),
                  )
                      : SvgPicture.asset('assets/icons/unchecked.svg',
                      width: 24, height: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}