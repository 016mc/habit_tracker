import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/checkin_model.dart';

/// 首页 - 支持拖拽排序
class HomeScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<CheckIn> todayCheckIns;
  final int streakDays;
  final int bestStreakDays;
  final VoidCallback? onAddHabit;
  final ValueChanged<Habit>? onEditHabit;
  final ValueChanged<String>? onDeleteHabit;
  final ValueChanged<String>? onArchiveHabit;
  final ValueChanged<String>? onCheckIn;
  final VoidCallback? onBackfill;
  final VoidCallback? onStatisticsTap;
  final VoidCallback? onSettingsTap;
  final ValueChanged<List<Habit>>? onReorderHabits;

  const HomeScreen({
    super.key,
    required this.habits,
    required this.todayCheckIns,
    this.streakDays = 0,
    this.bestStreakDays = 0,
    this.onAddHabit,
    this.onEditHabit,
    this.onDeleteHabit,
    this.onArchiveHabit,
    this.onCheckIn,
    this.onBackfill,
    this.onStatisticsTap,
    this.onSettingsTap,
    this.onReorderHabits,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 使用本地状态管理习惯列表，不依赖 widget.habits 的实时更新
  List<Habit> _localHabits = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _localHabits = List.from(widget.habits);
    _initialized = true;
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只在习惯数量变化时更新（新增或删除），不更新顺序
    if (widget.habits.length != oldWidget.habits.length) {
      _localHabits = List.from(widget.habits);
    }
  }

  /// 判断某个习惯今日是否已打卡
  bool _isCheckedIn(String habitId) {
    return widget.todayCheckIns.any((c) => c.habitId == habitId);
  }

  /// 获取某个习惯今日打卡次数
  int _getCheckInCount(String habitId) {
    return widget.todayCheckIns.where((c) => c.habitId == habitId).length;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Habit item = _localHabits.removeAt(oldIndex);
      _localHabits.insert(newIndex, item);
    });

    // 更新排序顺序并回调
    final updatedHabits = _localHabits.asMap().entries.map((entry) {
      return entry.value.copyWith(sortOrder: entry.key);
    }).toList();

    widget.onReorderHabits?.call(updatedHabits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('习惯打卡'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: widget.onSettingsTap,
          ),
        ],
      ),
      body: _localHabits.isEmpty
          ? const Center(
              child: Text('还没有习惯，点击右下角添加'),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _localHabits.length,
              onReorder: _onReorder,
              proxyDecorator: (child, index, animation) {
                return Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final habit = _localHabits[index];
                final checkCount = _getCheckInCount(habit.id);
                final completed = checkCount >= habit.targetCount;

                return _buildHabitCard(
                  key: ValueKey(habit.id),
                  habit: habit,
                  completed: completed,
                  checkCount: checkCount,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAddHabit,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitCard({
    required Key key,
    required Habit habit,
    required bool completed,
    required int checkCount,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: completed
            ? AppColors.primary.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completed
              ? AppColors.primary.withOpacity(0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽手柄
            ReorderableDragStartListener(
              index: _localHabits.indexOf(habit),
              child: const Icon(
                Icons.drag_handle,
                color: Color(0xFFCBD5E1),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            // 习惯图标
            CircleAvatar(
              backgroundColor: completed
                  ? AppColors.primary
                  : Color(habit.colorValue),
              radius: 18,
              child: Icon(
                completed ? Icons.check : _getCategoryIcon(habit.category),
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          completed
              ? '已完成 ${checkCount}/${habit.targetCount} ${habit.unit}'
              : '目标: ${habit.targetCount} ${habit.unit}（已打卡 $checkCount 次）',
          style: TextStyle(
            color: completed ? AppColors.primary : const Color(0xFF94A3B8),
            fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: completed
                ? AppColors.primary
                : const Color(0xFFCBD5E1),
            size: 28,
          ),
          tooltip: completed ? '已完成' : '打卡',
          onPressed: completed
              ? null
              : () => widget.onCheckIn?.call(habit.id),
        ),
        onTap: () => widget.onEditHabit?.call(habit),
      ),
    );
  }

  /// 根据分类获取图标
  IconData _getCategoryIcon(HabitCategory category) {
    switch (category) {
      case HabitCategory.supplement:
        return Icons.medication;
      case HabitCategory.learning:
        return Icons.menu_book;
      case HabitCategory.gaming:
        return Icons.sports_esports;
      case HabitCategory.exercise:
        return Icons.fitness_center;
      case HabitCategory.custom:
        return Icons.star;
    }
  }
}
