import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:installed_apps/installed_apps.dart';

/// Lấy icon thật của app theo package name, có cache để không tải lại.
class AppIconService {
  AppIconService._();

  // Chỉ lưu icon lấy thành công
  static final Map<String, Uint8List> _cache = {};
  // Các lần gọi đang chạy dở (tránh gọi trùng)
  static final Map<String, Future<Uint8List?>> _pending = {};

  static Future<Uint8List?> getIcon(String packageName) {
    final cached = _cache[packageName];
    if (cached != null) return Future.value(cached);

    return _pending.putIfAbsent(packageName, () async {
      try {
        final info = await InstalledApps.getAppInfo(packageName);
        final icon = info?.icon;
        debugPrint('ICON $packageName -> ${icon?.length}');
        if (icon != null && icon.isNotEmpty) {
          _cache[packageName] = icon;
          return icon;
        }
        return null; // không cache null, lần sau sẽ thử lại
      } catch (e) {
        debugPrint('ICON ERROR $packageName: $e');
        return null;
      } finally {
        _pending.remove(packageName);
      }
    });
  }
}