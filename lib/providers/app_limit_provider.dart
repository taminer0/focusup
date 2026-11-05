import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/app_catalog.dart';
import '../models/app_limit.dart';
import '../services/app_limit_repository.dart';

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
    _replace(updated);
    try {
      await _repo.updateLimit(updated);
    } catch (_) {
      _replace(limit);
    }
  }

  Future<void> remove(String id) async {
    await _repo.deleteLimit(id);
    _limits = _limits.where((e) => e.id != id).toList();
    notifyListeners();
  }

  void _replace(AppLimit item) {
    _limits = [for (final e in _limits) e.id == item.id ? item : e];
    notifyListeners();
  }

  /// selected: package -> số phút giới hạn mỗi lần dùng.
  Future<void> applySelection(Map<String, int> selected) async {
    for (final e in List.of(_limits)) {
      if (!selected.containsKey(e.packageName)) await remove(e.id);
    }
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

  // ---------- Phiên dùng ----------
  void addSessionSeconds(String id, int seconds) {
    final item = _limits.firstWhere((e) => e.id == id);
    _replace(item.copyWith(
      sessionUsedSeconds: item.sessionUsedSeconds + seconds,
    ));
  }

  void resetSession(String id) {
    final item = _limits.firstWhere((e) => e.id == id);
    _replace(item.copyWith(sessionUsedSeconds: 0));
  }

  // ---------- Khóa app (Detox) ----------
  final Map<String, DateTime> _lockedUntil = {};
  String? _exceededId;

  String? get exceededId => _exceededId;
  void clearExceeded() => _exceededId = null;

  DateTime? lockedUntil(String id) {
    final t = _lockedUntil[id];
    if (t == null || DateTime.now().isAfter(t)) return null;
    return t;
  }

  bool isLocked(String id) => lockedUntil(id) != null;

  void lock(String id, Duration d) {
    _lockedUntil[id] = DateTime.now().add(d);
    _exceededId = null;
    notifyListeners();
  }

  /// Hết giờ khóa: mở lại app, thanh về 0.
  void unlock(String id) {
    _lockedUntil.remove(id);
    resetSession(id);
  }

  // ---------- Demo: thay bằng native sau ----------
  Timer? _demoTimer;

  void startDemoSession(String id) {
    if (isLocked(id)) return;
    _demoTimer?.cancel();
    _demoTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      addSessionSeconds(id, 30); // 1 giây thật = 30 giây dùng
      final now = _limits.firstWhere((e) => e.id == id);
      if (now.isExceeded) {
        t.cancel();
        _exceededId = id; // báo cho BlockListener mở màn Detox
        notifyListeners();
      }
    });
  }

  void stopDemo() => _demoTimer?.cancel();

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }
}