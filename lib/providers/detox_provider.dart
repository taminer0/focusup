import 'package:flutter/foundation.dart';

class DetoxProvider extends ChangeNotifier {
  bool _enabled = false;
  bool get enabled => _enabled;

  void setEnabled(bool value) {
    _enabled = value;
    notifyListeners();
    // TODO: gọi API tạo/kết thúc phiên Detox (bảng detox_sessions)
  }
}