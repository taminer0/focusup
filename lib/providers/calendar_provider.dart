import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/calendar_repository.dart';

class CalendarProvider extends ChangeNotifier {
  final CalendarRepository _repo;
  CalendarProvider(this._repo);

  bool _connected = false;
  bool get connected => _connected;

  /// Kết nối và trả về các sự kiện 30 ngày tới.
  Future<List<Task>> connect() async {
    await _repo.connect();
    _connected = true;
    notifyListeners();
    return _repo.getEvents();
  }

  Future<List<Task>> refresh() => _repo.getEvents();
}