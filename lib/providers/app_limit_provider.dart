import 'package:flutter/foundation.dart';
import '../models/app_limit.dart';
import '../services/app_limit_repository.dart';
import 'dart:async';
import '../core/app_catalog.dart';

enum LoadStatus { loading, success, error }

class AppLimitProvider extends ChangeNotifier {
  final AppLimitRepository _repo;
  AppLimitProvider(this._repo);

  List<AppLimit> _limits = [];
  LoadStatus _status = LoadStatus.loading;

  List<AppLimit> get limits => List.unmodifiable(_limits);
  LoadStatus get status => _status;

  Future<void> load() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _limits = await _repo.getLimits();
      _status = LoadStatus.success;
    } catch (_) {
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> add(AppLimit limit) async {
    final saved = await _repo.addLimit(limit);
    _limits = [..._limits, saved];
    notifyListeners();
  }

  Future<void> toggle(AppLimit limit, bool enabled) async {
    final updated = limit.copyWith(enabled: enabled);
    _replace(updated); // cập nhật giao diện trước cho mượt
    try {
      await _repo.updateLimit(updated);
    } catch (_) {
      _replace(limit); // lỗi thì trả về như cũ
    }
  }

  Future<void> remove(String id) async {
    await _repo.deleteLimit(id);
    _limits = _limits.where((e) => e.id != id).toList();
    notifyListeners();
  }
  /// selected: package -> số phút giới hạn mỗi lần dùng.
  Future<void> applySelection(Map<String, int> selected) async {
    // Xóa app bị bỏ tick
    for (final e in List.of(_limits)) {
      if (!selected.containsKey(e.packageName)) await remove(e.id);
    }
    // Thêm mới hoặc cập nhật thời gian
    for (final entry in selected.entries) {
      final idx = _limits.indexWhere((e) => e.packageName == entry.key);
      if (idx == -1) {
        await add(AppLimit(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          packageName: entry.key,
          name: AppCatalog.nameOf(entry.key),
          sessionLimitMinutes: entry.value,
        ));
      } else if (_limits[idx].sessionLimitMinutes != entry.value) {
        final old = _limits[idx];
        final updated = old.copyWith(sessionLimitMinutes: entry.value);
        _replace(updated);
        try {
          await _repo.updateLimit(updated);
        } catch (_) {
          _replace(old);
        }
      }
    }
  }


  void _replace(AppLimit item) {
    _limits = [for (final e in _limits) e.id == item.id ? item : e];
    notifyListeners();
  }/// Cộng thêm thời gian vào phiên hiện tại. Native sẽ gọi hàm này mỗi giây/phút.
  void addSessionSeconds(String id, int seconds) {
    final item = _limits.firstWhere((e) => e.id == id);
    _replace(item.copyWith(
      sessionUsedSeconds: item.sessionUsedSeconds + seconds,
    ));
  }

  /// Kết thúc phiên (người dùng thoát app) -> thanh về 0.
  void resetSession(String id) {
    final item = _limits.firstWhere((e) => e.id == id);
    _replace(item.copyWith(sessionUsedSeconds: 0));
  }

// ---- Chỉ để demo giao diện, xóa khi có native ----
  Timer? _demoTimer;

  void startDemoSession(String id) {
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final item = _limits.firstWhere((e) => e.id == id);
      if (item.isExceeded) {
        t.cancel();
        resetSession(id); // hết phiên -> reset
      } else {
        addSessionSeconds(id, 30); // demo: 1 giây thật = 30 giây dùng
      }
    });
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }

}