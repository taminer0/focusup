import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/app_bottom_nav.dart';
import 'focus/focus_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'stats/stats_screen.dart';
import 'tasks/task_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  /// Mở danh sách nhiệm vụ. Nếu người dùng bấm tab ở thanh dưới của màn đó
  /// thì quay về và chuyển sang tab tương ứng.
  Future<void> _openTasks() async {
    final tab = await Navigator.of(context).push<int>(
      MaterialPageRoute(builder: (_) => const TaskListScreen()),
    );
    if (tab != null) _goTo(tab);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onSeeAllTasks: _openTasks),
      const FocusScreen(),
      const StatsScreen(),
      ProfileScreen(onGoToTab: _goTo, onOpenTasks: _openTasks),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: _index, onTap: _goTo),
    );
  }
}