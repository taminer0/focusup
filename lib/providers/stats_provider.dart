import 'package:flutter/foundation.dart';
import '../models/usage_stats.dart';
import '../services/usage_repository.dart';
import 'app_limit_provider.dart' show LoadStatus;

class StatsProvider extends ChangeNotifier {
  final UsageRepository _repo;
  StatsProvider(this._repo);

  StatsPeriod _period = StatsPeriod.week;
  UsageSummary? _summary;
  LoadStatus _status = LoadStatus.loading;

  StatsPeriod get period => _period;
  UsageSummary? get summary => _summary;
  LoadStatus get status => _status;

  Future<void> load([StatsPeriod? period]) async {
    if (period != null) _period = period;
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _summary = await _repo.getSummary(_period);
      _status = LoadStatus.success;
    } catch (_) {
      _status = LoadStatus.error;
    }
    notifyListeners();
  }
}