import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_repository.dart';
import 'app_limit_provider.dart' show LoadStatus;

enum TaskFilter { all, today, week }

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repo;
  TaskProvider(this._repo);

  List<Task> _tasks = [];
  LoadStatus _status = LoadStatus.loading;
  TaskFilter _filter = TaskFilter.all;

  LoadStatus get status => _status;
  TaskFilter get filter => _filter;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Task> _sorted(Iterable<Task> list) =>
      list.toList()..sort((a, b) => a.start.compareTo(b.start));

  /// Nhiệm vụ hôm nay (dùng ở Home)
  List<Task> get todayTasks {
    final now = DateTime.now();
    return _sorted(_tasks.where((t) => _sameDay(t.start, now)));
  }

  /// Danh sách theo bộ lọc đang chọn (dùng ở màn Danh sách)
  List<Task> get filtered {
    final now = DateTime.now();
    switch (_filter) {
      case TaskFilter.all:
        return _sorted(_tasks);
      case TaskFilter.today:
        return todayTasks;
      case TaskFilter.week:
        final d = DateTime(now.year, now.month, now.day);
        final monday = d.subtract(Duration(days: d.weekday - 1));
        final nextMonday = monday.add(const Duration(days: 7));
        return _sorted(_tasks.where(
                (t) => !t.start.isBefore(monday) && t.start.isBefore(nextMonday)));
    }
  }
  List<Task> _external = []; // sự kiện từ Google Calendar

  void setFilter(TaskFilter f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _tasks = [...await _repo.getTasks(), ..._external];
      _status = LoadStatus.success;
    } catch (_) {
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> toggleDone(String id) async {
    final old = _tasks.firstWhere((t) => t.id == id);
    final updated = old.copyWith(isDone: !old.isDone);
    _replace(updated); // cập nhật giao diện trước cho mượt
    try {
      await _repo.updateTask(updated);
    } catch (_) {
      _replace(old); // lỗi thì trả về như cũ
    }
  }

  Future<void> add(Task task) async {
    final saved = await _repo.addTask(task);
    _tasks = [..._tasks, saved];
    notifyListeners();
  }

  Future<void> update(Task task) async {
    final old = _tasks.firstWhere((t) => t.id == task.id);
    _replace(task); // cập nhật giao diện trước
    try {
      await _repo.updateTask(task);
    } catch (_) {
      _replace(old); // lỗi thì trả về như cũ
    }
  }

  Future<void> remove(String id) async {
    _tasks = _tasks.where((t) => t.id != id).toList(); // xóa ngay trên giao diện
    _external = _external.where((t) => t.id != id).toList();
    notifyListeners();
    try {
      await _repo.deleteTask(id);
    } catch (_) {
      await load(); // lỗi thì tải lại danh sách từ nguồn
    }
  }


  void _replace(Task t) {
    _tasks = [for (final e in _tasks) e.id == t.id ? t : e];
    _external = [for (final e in _external) e.id == t.id ? t : e];
    notifyListeners();
  }
  /// Nhập sự kiện Google Calendar. Giữ trạng thái "đã xong" của lần trước, không nhân đôi.
  void importExternal(List<Task> events) {
    final doneIds = {
      for (final t in _tasks)
        if (t.source == 'google' && t.isDone) t.externalId
    };
    _external = [
      for (final e in events)
        doneIds.contains(e.externalId) ? e.copyWith(isDone: true) : e
    ];
    _tasks = [..._tasks.where((t) => t.source != 'google'), ..._external];
    notifyListeners();
  }
}