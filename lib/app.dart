import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/theme/app_theme.dart';
import 'presentation/theme/theme_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/statistics/statistics_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/providers/habit_provider.dart';
import 'presentation/providers/checkin_provider.dart';
import 'presentation/providers/stats_provider.dart';

/// 应用根组件
class HabitTrackerApp extends ConsumerStatefulWidget {
  const HabitTrackerApp({super.key});

  @override
  ConsumerState<HabitTrackerApp> createState() => _HabitTrackerAppState();
}

class _HabitTrackerAppState extends ConsumerState<HabitTrackerApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// 应用初始化
  Future<void> _initializeApp() async {
    try {
      await ref.read(habitProvider.notifier).loadHabits();
      final habitState = ref.read(habitProvider);
      if (habitState.habits.isNotEmpty) {
        await ref.read(checkInProvider.notifier).loadTodayCheckIns(
              habitState.habits,
            );
        await ref.read(statsProvider.notifier).loadAllStats(
              habitState.habits,
            );
      }
    } catch (e) {
      debugPrint('初始化失败: $e');
    }

    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  /// 应用是否已完成初始化
  bool _isInitialized = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(flutterThemeModeProvider);

    return MaterialApp(
      title: '习惯打卡',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        // 全局错误边界，防止 null 值导致整个应用崩溃
        ErrorWidget.builder = (errorDetails) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('出错了: ${errorDetails.exception}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        };
        return child ?? const SizedBox.shrink();
      },
      home: _isInitialized
          ? const _HomeScreenWrapper()
          : const _SplashScreen(),
      routes: {
        '/statistics': (context) => const StatisticsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

/// 首页包装组件
class _HomeScreenWrapper extends ConsumerWidget {
  const _HomeScreenWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitProvider);
    final checkInState = ref.watch(checkInProvider);
    final statsState = ref.watch(statsProvider);

    int totalStreakDays = 0;
    int totalBestStreakDays = 0;
    for (final stats in statsState.statsMap.values) {
      if (stats.currentStreak > totalStreakDays) {
        totalStreakDays = stats.currentStreak;
      }
      if (stats.longestStreak > totalBestStreakDays) {
        totalBestStreakDays = stats.longestStreak;
      }
    }

    return HomeScreen(
      habits: habitState.habits,
      todayCheckIns: checkInState.todayCheckIns,
      streakDays: totalStreakDays,
      bestStreakDays: totalBestStreakDays,
      onAddHabit: (name) async {
        try {
          await ref.read(habitProvider.notifier).addHabit(name: name);
          final updatedHabits = ref.read(habitProvider).habits;
          ref.read(checkInProvider.notifier).loadTodayCheckIns(updatedHabits);
          ref.read(statsProvider.notifier).loadAllStats(updatedHabits);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('添加习惯失败: $e')),
            );
          }
        }
      },
      onDeleteHabit: (habitId) async {
        try {
          await ref.read(habitProvider.notifier).deleteHabit(habitId);
          final updatedHabits = ref.read(habitProvider).habits;
          ref.read(checkInProvider.notifier).loadTodayCheckIns(updatedHabits);
          ref.read(statsProvider.notifier).loadAllStats(updatedHabits);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('删除失败: $e')),
            );
          }
        }
      },
      onArchiveHabit: (habitId) async {
        try {
          await ref.read(habitProvider.notifier).archiveHabit(habitId);
          final updatedHabits = ref.read(habitProvider).habits;
          ref.read(checkInProvider.notifier).loadTodayCheckIns(updatedHabits);
          ref.read(statsProvider.notifier).loadAllStats(updatedHabits);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('归档失败: $e')),
            );
          }
        }
      },
      onCheckIn: (habitId) async {
        try {
          await ref.read(checkInProvider.notifier).checkIn(habitId: habitId);
          final updatedHabits = ref.read(habitProvider).habits;
          ref.read(statsProvider.notifier).refreshStats(updatedHabits);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('打卡失败: $e')),
            );
          }
        }
      },
      onUndoCheckIn: (habitId) async {
        try {
          await ref.read(checkInProvider.notifier).undoCheckIn(habitId: habitId);
          final updatedHabits = ref.read(habitProvider).habits;
          ref.read(statsProvider.notifier).refreshStats(updatedHabits);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('撤销打卡失败: $e')),
            );
          }
        }
      },
      onBackfill: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('补打卡功能开发中')),
        );
      },
      onReorderHabits: (reorderedHabits) async {
        // 保存新的排序顺序
        for (final habit in reorderedHabits) {
          await ref.read(habitProvider.notifier).editHabit(
            habitId: habit.id,
            sortOrder: habit.sortOrder,
          );
        }
      },
      onStatisticsTap: () {
        Navigator.of(context).pushNamed('/statistics');
      },
      onSettingsTap: () {
        Navigator.of(context).pushNamed('/settings');
      },
    );
  }
}

/// 启动页
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '习惯打卡',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ADE80)),
            ),
          ],
        ),
      ),
    );
  }
}
