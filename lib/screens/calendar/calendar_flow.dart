import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/task_provider.dart';

class CalendarFlow {
  CalendarFlow._();

  /// Trả về true nếu đã kết nối (hoặc đã kết nối từ trước).
  static Future<bool> ensureConnected(BuildContext context) async {
    final cal = context.read<CalendarProvider>();
    if (cal.connected) return true;

    // Màn 1: bottom sheet
    final go = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const _ConnectSheet(),
    );
    if (go != true || !context.mounted) return false;

    // Kết nối + nhập sự kiện vào danh sách nhiệm vụ
    final events = await cal.connect();
    if (!context.mounted) return false;
    context.read<TaskProvider>().importExternal(events);

    // Màn 2: đã kết nối
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _ConnectedScreen()),
    );
    return true;
  }
}

Widget _calendarLogo(double size) => Image.asset(
  'assets/images/logocalen.png',
  width: size,
  height: size,
  errorBuilder: (_, __, ___) =>
      Icon(Icons.event, size: size, color: AppColors.green),
);

// ======================= Màn 1 =======================
class _ConnectSheet extends StatefulWidget {
  const _ConnectSheet();

  @override
  State<_ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends State<_ConnectSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _calendarLogo(100),
                  const Positioned(
                    left: 30,
                    top: 0,
                    child: Icon(Icons.auto_awesome,
                        size: 18, color: AppColors.yellow),
                  ),
                  const Positioned(
                    right: 30,
                    bottom: 10,
                    child: Icon(Icons.auto_awesome,
                        size: 22, color: Color(0xFF4F7CE8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Kết nối Google Calendar',
                style: AppTextStyles.title.copyWith(fontSize: 22)),
            const SizedBox(height: 10),
            Text(
              'Đồng bộ nhiệm vụ của bạn với lịch Google Calendar để không bỏ lỡ bất kỳ kế hoạch nào',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _connect,
                icon: _loading
                    ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white))
                    : CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.white,
                  child: Image.asset('assets/images/google.png',
                      height: 16,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.g_mobiledata,
                          color: AppColors.green)),
                ),
                label: const Text('Kết nối với Google Calendar'),
              ),
            ),
            TextButton(
              onPressed: _loading ? null : () => Navigator.pop(context, false),
              child: Text('Để sau',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  void _connect() {
    setState(() => _loading = true);
    // Đóng sheet, phần kết nối thật chạy ở CalendarFlow
    Navigator.pop(context, true);
  }
}

// ======================= Màn 2 =======================
class _ConnectedScreen extends StatelessWidget {
  const _ConnectedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 190,
                    height: 190,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.greenLight,
                      shape: BoxShape.circle,
                    ),
                    child: _calendarLogo(100),
                  ),
                  Positioned(
                    right: 22,
                    bottom: 22,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          size: 20, color: AppColors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Đã kết nối Google Calendar',
                  style: AppTextStyles.title.copyWith(fontSize: 22)),
              const SizedBox(height: 10),
              Text(
                'Nhiệm vụ của bạn sẽ được đồng bộ tự động với Google Calendar',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(height: 1.5),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Quay lại'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}