import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'models/usage_stats.dart';
import 'providers/app_limit_provider.dart';
import 'providers/detox_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/main_shell.dart';
import 'services/app_limit_repository.dart';
import 'services/usage_repository.dart';
import 'providers/profile_provider.dart';
import 'services/user_repository.dart';
import 'providers/task_provider.dart';
import 'services/task_repository.dart';
import 'providers/calendar_provider.dart';
import 'services/calendar_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppLimitProvider(MockAppLimitRepository())..load(),
        ),
        ChangeNotifierProvider(create: (_) => DetoxProvider()),
        ChangeNotifierProvider(
          create: (_) => StatsProvider(MockUsageRepository())..load(StatsPeriod.week),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(MockUserRepository())..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(MockTaskRepository())..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => CalendarProvider(MockCalendarRepository()),
        ),
      ],
      child: const FocusUpApp(),
    ),
  );
}

class FocusUpApp extends StatelessWidget {
  const FocusUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}