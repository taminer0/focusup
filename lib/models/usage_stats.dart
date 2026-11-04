enum StatsPeriod { week, month, year }

class AppUsageItem {
  final String packageName;
  final String name;
  final int minutes;

  const AppUsageItem({
    required this.packageName,
    required this.name,
    required this.minutes,
  });
}

class UsageSummary {
  final int totalMinutes;
  final List<int> bars; // phút theo từng cột (7 ngày / 4 tuần / 12 tháng)
  final List<AppUsageItem> topApps;

  const UsageSummary({
    required this.totalMinutes,
    required this.bars,
    required this.topApps,
  });
}