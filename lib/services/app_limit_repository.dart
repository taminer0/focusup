import '../models/app_limit.dart';

abstract class AppLimitRepository {
  Future<List<AppLimit>> getLimits(); // GET    /app-limits
  Future<AppLimit> addLimit(AppLimit limit); // POST   /app-limits
  Future<AppLimit> updateLimit(AppLimit limit); // PUT    /app-limits/:id
  Future<void> deleteLimit(String id); // DELETE /app-limits/:id
}

/// Dữ liệu giả để dựng giao diện. Thay bằng ApiAppLimitRepository khi có backend.
class MockAppLimitRepository implements AppLimitRepository {
  final List<AppLimit> _data = [
    const AppLimit(
      id: '1',
      packageName: 'com.zhiliaoapp.musically',
      name: 'Tiktok',
      sessionLimitMinutes: 30,
      sessionUsedSeconds: 29 * 60, // demo: gần đầy để thấy màn chặn nhanh
    ),
  ];

  Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: 400));

  @override
  Future<List<AppLimit>> getLimits() async {
    await _fakeDelay();
    return List.of(_data);
  }

  @override
  Future<AppLimit> addLimit(AppLimit limit) async {
    await _fakeDelay();
    _data.add(limit);
    return limit;
  }

  @override
  Future<AppLimit> updateLimit(AppLimit limit) async {
    await _fakeDelay();
    final i = _data.indexWhere((e) => e.id == limit.id);
    if (i != -1) _data[i] = limit;
    return limit;
  }

  @override
  Future<void> deleteLimit(String id) async {
    await _fakeDelay();
    _data.removeWhere((e) => e.id == id);
  }
}