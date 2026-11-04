import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/svg_toggle.dart';
import '../../widgets/task_card.dart';

class AddTaskScreen extends StatefulWidget {
  /// Có giá trị = đang Sửa, null = đang Thêm.
  final Task? initial;

  const AddTaskScreen({super.key, this.initial});

  /// Mở màn Thêm/Sửa. Trả về true nếu đã lưu.
  static Future<bool> open(BuildContext context, {Task? initial}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddTaskScreen(initial: initial)),
    );
    return saved == true;
  }

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  TaskPriority _priority = TaskPriority.low;

  bool _daily = true; // true: Hàng ngày, false: Tùy chỉnh
  final Set<int> _days = {}; // 1 = T2 ... 7 = CN

  bool _hasTime = false;
  DateTime _date = DateTime.now();
  TimeOfDay _from = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _to = const TimeOfDay(hour: 9, minute: 0);

  bool _hasLocation = false;
  bool _syncCalendar = false;

  bool get _isEditing => widget.initial != null;

  static const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  static const _priorities = [
    TaskPriority.high,
    TaskPriority.medium,
    TaskPriority.low,
    TaskPriority.special,
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t == null) return;

    _titleCtrl.text = t.title;
    _priority = t.priority;
    _hasTime = t.hasTime;
    _date = t.start;
    if (t.hasTime) {
      _from = TimeOfDay.fromDateTime(t.start);
      if (t.end != null) _to = TimeOfDay.fromDateTime(t.end!);
    }
    _hasLocation = t.location != null;
    _locationCtrl.text = t.location ?? '';
    _daily = t.repeatDays.isEmpty || t.repeatDays.length == 7;
    if (!_daily) _days.addAll(t.repeatDays);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime(bool isFrom) async {
    final t = await showTimePicker(
      context: context,
      initialTime: isFrom ? _from : _to,
    );
    if (t == null) return;
    setState(() => isFrom ? _from = t : _to = t);
  }

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _toast('Vui lòng nhập tên nhiệm vụ');
      return;
    }

    final base = _hasTime ? _date : (widget.initial?.start ?? DateTime.now());
    DateTime start = DateTime(base.year, base.month, base.day);
    DateTime? end;

    if (_hasTime) {
      start =
          DateTime(base.year, base.month, base.day, _from.hour, _from.minute);
      end = DateTime(base.year, base.month, base.day, _to.hour, _to.minute);
      if (!end.isAfter(start)) {
        _toast('Giờ kết thúc phải sau giờ bắt đầu');
        return;
      }
    }

    final repeat = _daily ? [1, 2, 3, 4, 5, 6, 7] : (_days.toList()..sort());
    final editing = widget.initial;

    final task = Task(
      id: editing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: editing?.description,
      start: start,
      end: end,
      hasTime: _hasTime,
      location: _hasLocation && _locationCtrl.text.trim().isNotEmpty
          ? _locationCtrl.text.trim()
          : null,
      priority: _priority,
      isDone: editing?.isDone ?? false,
      repeatDays: repeat,
    );

    // TODO: nếu _syncCalendar thì gọi dịch vụ Google Calendar (làm sau)
    final provider = context.read<TaskProvider>();
    if (editing == null) {
      await provider.add(task);
    } else {
      await provider.update(task);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Tiêu đề ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: SvgPicture.asset('assets/icons/arrow_back.svg',
                        width: 24, height: 24),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Text(_isEditing ? 'Sửa nhiệm vụ' : 'Thêm nhiệm vụ',
                      style: AppTextStyles.title.copyWith(fontSize: 22)),
                ],
              ),
            ),

            // ---------- Form ----------
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Tên nhiệm vụ'),
                      TextField(
                        controller: _titleCtrl,
                        textInputAction: TextInputAction.done,
                        decoration:
                        const InputDecoration(hintText: 'Đại diện'),
                      ),
                      const SizedBox(height: 20),

                      _label('Màu sắc'),
                      _colorPicker(),
                      const SizedBox(height: 20),

                      _label('Tần suất lặp lại'),
                      _repeatPicker(),
                      const SizedBox(height: 20),

                      _switchRow('Thời gian', _hasTime,
                              (v) => setState(() => _hasTime = v)),
                      if (_hasTime) ...[
                        const SizedBox(height: 12),
                        _pickerField(
                          label: 'Ngày',
                          value: _fmtDate(_date),
                          onTap: _pickDate,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _pickerField(
                                label: 'Từ',
                                value: _fmtTime(_from),
                                onTap: () => _pickTime(true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _pickerField(
                                label: 'Đến',
                                value: _fmtTime(_to),
                                onTap: () => _pickTime(false),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),

                      _switchRow('Địa điểm', _hasLocation,
                              (v) => setState(() => _hasLocation = v)),
                      if (_hasLocation) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _locationCtrl,
                          decoration: const InputDecoration(
                              hintText: 'VD: S515, Nguyễn Trãi'),
                        ),
                      ],
                      const SizedBox(height: 24),

                      _calendarCard(),
                    ],
                  ),
                ),
              ),
            ),

            // ---------- Nút Lưu ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: PrimaryButton(text: 'Lưu', onPressed: _save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= Các khối nhỏ =======================

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
  );

  Widget _colorPicker() {
    return Row(
      children: [
        for (final p in _priorities) ...[
          GestureDetector(
            onTap: () => setState(() => _priority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: TaskCard.colorOf(p),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _priority == p ? AppColors.green : Colors.transparent,
                  width: 2,
                ),
              ),
              child: _priority == p
                  ? const Icon(Icons.check, size: 18, color: AppColors.green)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
        ],
      ],
    );
  }

  Widget _repeatPicker() {
    Widget seg(String text, bool selected, VoidCallback onTap) => Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.green : AppColors.greenLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            seg('Hàng ngày', _daily, () => setState(() => _daily = true)),
            const SizedBox(width: 12),
            seg('Tùy chỉnh', !_daily, () => setState(() => _daily = false)),
          ],
        ),
        if (!_daily) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                GestureDetector(
                  onTap: () => setState(() {
                    final d = i + 1;
                    _days.contains(d) ? _days.remove(d) : _days.add(d);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _days.contains(i + 1)
                          ? AppColors.green
                          : AppColors.greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _dayLabels[i],
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _days.contains(i + 1)
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style:
              AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ),
        SvgToggle(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _pickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.caption),
            const SizedBox(width: 12),
            Expanded(child: Text(value, style: AppTextStyles.body)),
            const Icon(Icons.keyboard_arrow_down,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _calendarCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logocalen.png',
            width: 28,
            height: 28,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.event, size: 28, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Đồng bộ với Google Calendar',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Thêm nhiệm vụ vào lịch của bạn',
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
          SvgToggle(
            value: _syncCalendar,
            onChanged: (v) => setState(() => _syncCalendar = v),
          ),
        ],
      ),
    );
  }
}