import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/user_repository.dart';
import 'app_limit_provider.dart' show LoadStatus;

class ProfileProvider extends ChangeNotifier {
  final UserRepository _repo;
  ProfileProvider(this._repo);

  UserProfile? _profile;
  LoadStatus _status = LoadStatus.loading;
  String _theme = 'Light';
  String _language = 'Tiếng Việt';

  UserProfile? get profile => _profile;
  LoadStatus get status => _status;
  String get theme => _theme;
  String get language => _language;

  Future<void> load() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _profile = await _repo.getProfile();
      _status = LoadStatus.success;
    } catch (_) {
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  // Mới chỉ lưu lựa chọn. Dark theme và đa ngôn ngữ chưa có trong thiết kế.
  void setTheme(String v) {
    _theme = v;
    notifyListeners();
  }

  void setLanguage(String v) {
    _language = v;
    notifyListeners();
  }

  Future<void> logout() => _repo.logout();
}