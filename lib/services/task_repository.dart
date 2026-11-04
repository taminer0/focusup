import '../models/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(); // GET    /tasks
  Future<Task> addTask(Task task); // POST   /tasks
  Future<Task> updateTask(Task task); // PUT    /tasks/:id
  Future<void> deleteTask(String id); // DELETE /tasks/:id
}

/// Dữ liệu giả, ngày giờ tính theo hôm nay để lọc Hôm nay/Tuần này luôn có dữ liệu.
class MockTaskRepository implements TaskRepository {
  late final List<Task> _data = _seed();

  static List<Task> _seed() {
    final n = DateTime.now();
    DateTime at(int plusDays, int h, int m) =>
        DateTime(n.year, n.month, n.day + plusDays, h, m);

    return [
      Task(
        id: '1',
        title: 'Hoàn thành báo cáo',
        location: 'S515, Nguyễn Trãi',
        start: at(0, 18, 30),
        end: at(0, 19, 30),
        priority: TaskPriority.low,
        isDone: true,
      ),
      Task(
        id: '2',
        title: 'Day Online',
        start: at(0, 19, 40),
        end: at(0, 20, 30),
        priority: TaskPriority.special,
      ),
      Task(
        id: '3',
        title: 'Nấu ăn',
        start: at(0, 20, 45),
        priority: TaskPriority.high,
      ),
      Task(
        id: '4',
        title: 'Hoàn thành báo cáo',
        start: at(1, 18, 30),
        end: at(1, 19, 30),
        priority: TaskPriority.low,
      ),
      Task(
        id: '5',
        title: 'Hoàn thành báo cáo',
        start: at(10, 18, 30),
        end: at(10, 19, 30),
        priority: TaskPriority.medium,
      ),
    ];
  }

  Future<void> _delay() => Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Task>> getTasks() async {
    await _delay();
    return List.of(_data);
  }

  @override
  Future<Task> addTask(Task task) async {
    await _delay();
    _data.add(task);
    return task;
  }

  @override
  Future<Task> updateTask(Task task) async {
    await _delay();
    final i = _data.indexWhere((e) => e.id == task.id);
    if (i != -1) _data[i] = task;
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _delay();
    _data.removeWhere((e) => e.id == id);
  }
}