import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../core/app_catalog.dart';
import '../../core/app_colors.dart';
import '../../core/app_text_styles.dart';
import '../../providers/app_limit_provider.dart';
import '../../widgets/app_icon_view.dart';
import '../../widgets/limit_time_dialog.dart';

class AppSelectScreen extends StatefulWidget {
  const AppSelectScreen({super.key});

  /// Trả về true nếu đã lưu.
  static Future<bool> open(BuildContext context) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AppSelectScreen()),
    );
    return saved == true;
  }

  @override
  State<AppSelectScreen> createState() => _AppSelectScreenState();
}

class _AppSelectScreenState extends State<AppSelectScreen> {
  final _searchCtrl = TextEditingController();

  /// package -> phút giới hạn mỗi lần dùng
  late final Map<String, int> _selected = {
    for (final l in context.read<AppLimitProvider>().limits)
      l.packageName: l.sessionLimitMinutes,
  };

  String _query = '';
  bool _saving = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _fmt(int m) {
    if (m >= 60 && m % 60 == 0) return '${m ~/ 60} giờ/lần dùng';
    if (m < 60) return '$m phút/lần dùng';
    return '${m ~/ 60} giờ ${m % 60} phút/lần dùng';
  }

  Future<void> _edit(AppCatalogItem app) async {
    final m = await showLimitTimeDialog(
      context,
      app: app,
      initialMinutes: _selected[app.package] ?? 30,
    );
    if (m != null) setState(() => _selected[app.package] = m);
  }

  void _toggle(AppCatalogItem app) {
    if (_selected.containsKey(app.package)) {
      setState(() => _selected.remove(app.package));
    } else {
      _edit(app);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AppLimitProvider>().applySelection(_selected);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final apps = AppCatalog.items
        .where((a) => a.name.toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) {
        final sa = _selected.containsKey(a.package) ? 0 : 1;
        final sb = _selected.containsKey(b.package) ? 0 : 1;
        return sa.compareTo(sb); // app đã chọn lên trước, giữ nguyên thứ tự còn lại
      });

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
                  Text('Chọn ứng dụng giới hạn',
                      style: AppTextStyles.title
                          .copyWith(fontSize: 20, color: AppColors.green)),
                ],
              ),
            ),

            // ---------- Tìm kiếm ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Tìm ứng dụng...',
                  prefixIcon: Icon(Icons.search,
                      color: AppColors.textTertiary, size: 20),
                ),
              ),
            ),

            // ---------- Danh sách ----------
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: apps.isEmpty
                      ? Center(
                      child: Text('Không tìm thấy ứng dụng',
                          style: AppTextStyles.caption))
                      : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: apps.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (_, i) => _row(apps[i]),
                  ),
                ),
              ),
            ),

            // ---------- Nút Lưu ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: AppColors.white))
                      : const Text('Lưu'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(AppCatalogItem app) {
    final minutes = _selected[app.package];
    final checked = minutes != null;

    return InkWell(
      onTap: () => _edit(app),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AppIconView(packageName: app.package, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(app.name, style: AppTextStyles.body),
                  if (checked)
                    Text(_fmt(minutes),
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 11, color: AppColors.green)),
                ],
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _toggle(app),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: checked
                    ? SvgPicture.asset('assets/icons/checkvuong.svg',
                    width: 22, height: 22)
                    : Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: AppColors.textTertiary, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}