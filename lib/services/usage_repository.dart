import '../models/usage_stats.dart';

abstract class UsageRepository {
  Future<UsageSummary> getSummary(StatsPeriod period);
}

/// Dữ liệu giả. Sau này thay bằng class đọc UsageStatsManager qua Platform Channel.
class MockUsageRepository implements UsageRepository {
  @override
  Future<UsageSummary> getSummary(StatsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 300));

    const apps = [
      AppUsageItem(
          packageName: 'com.zhiliaoapp.musically', name: 'TikTok', minutes: 80),
      AppUsageItem(
          packageName: 'com.instagram.android',
          name: 'Instagram',
          minutes: 60),
      AppUsageItem(
          packageName: 'com.google.android.youtube',
          name: 'YouTube',
          minutes: 30),
      AppUsageItem(
          packageName: 'com.facebook.katana', name: 'Facebook', minutes: 15),
    ];

    switch (period) {
      case StatsPeriod.week:
        return const UsageSummary(
          totalMinutes: 154,
          bars: [95, 120, 70, 140, 90, 150, 200],
          topApps: apps,
        );
      case StatsPeriod.month:
        return const UsageSummary(
          totalMinutes: 640,
          bars: [520, 610, 480, 700],
          topApps: apps,
        );
      case StatsPeriod.year:
        return const UsageSummary(
          totalMinutes: 7200,
          bars: [500, 620, 580, 700, 640, 720, 690, 760, 610, 650, 700, 780],
          topApps: apps,
        );
    }
  }
}