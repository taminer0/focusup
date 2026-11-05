import '../models/task.dart';

abstract class CalendarRepository {
  Future<void> connect(); // OAuth Google (backend/native làm sau)
  Future<void> disconnect(); // DELETE /calendar/connect
  Future<List<Task>> getEvents({int days = 30}); // 30 ngày tới
}

class MockCalendarRepository implements CalendarRepository {
  @override
  Future<void> connect() =>
      Future.delayed(const Duration(milliseconds: 600));

  @override
  Future<void> disconnect() =>
      Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<Task>> getEvents({int days = 30}) async {
    final n = DateTime.now();
    DateTime at(int d, int h, int m) =>
        DateTime(n.year, n.month, n.day + d, h, m);

    return [
      Task(
        id: 'g1',
        externalId: 'g1',
        source: 'google',
        title: 'Họp nhóm đồ án',
        start: at(0, 14, 0),
        end: at(0, 15, 0),
        priority: TaskPriority.medium,
      ),
      Task(
        id: 'g2',
        externalId: 'g2',
        source: 'google',
        title: 'Nộp bài Data Mining',
        start: at(1, 9, 0),
        end: at(1, 10, 0),
        priority: TaskPriority.high,
      ),
      Task(
        id: 'g3',
        externalId: 'g3',
        source: 'google',
        title: 'Thi giữa kỳ',
        start: at(3, 0, 0),
        hasTime: false,
        priority: TaskPriority.special,
      ),
    ];
  }
}