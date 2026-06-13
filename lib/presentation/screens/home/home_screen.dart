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
  final ValueChanged<String>? onAddHabit;
  final ValueChanged<String>? onDeleteHabit;
  final ValueChanged<String>? onArchiveHabit;
  final ValueChanged<String>? onCheckIn;
  final ValueChanged<String>? onUndoCheckIn;
  final void Function(String habitId, String newName)? onRenameHabit;
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
    this.onDeleteHabit,
    this.onArchiveHabit,
    this.onCheckIn,
    this.onUndoCheckIn,
    this.onRenameHabit,
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

  /// 弹出添加习惯的 BottomSheet
  void _showAddHabitSheet() {
    final TextEditingController nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '添加新习惯',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '习惯名称',
                  hintText: '输入习惯名称',
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  final name = value.trim();
                  if (name.isNotEmpty) {
                    widget.onAddHabit?.call(name);
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      widget.onAddHabit?.call(name);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '创建',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('还没有习惯，点击下方按钮添加'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showAddHabitSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('添加新习惯'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
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
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton(
            onPressed: _showAddHabitSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '添加新习惯',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard({
    required Key key,
    required Habit habit,
    required bool completed,
    required int checkCount,
  }) {
    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.archive,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('归档习惯'),
            content: Text('确定要归档「${habit.name}」吗？归档后可以到设置中恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('归档'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        widget.onArchiveHabit?.call(habit.id);
      },
      child: Container(
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
                ? '已完成 $checkCount/${habit.targetCount} ${habit.unit}'
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
            tooltip: completed ? '撤销打卡' : '打卡',
            onPressed: () {
              if (completed) {
                widget.onUndoCheckIn?.call(habit.id);
              } else {
                widget.onCheckIn?.call(habit.id);
              }
            },
          ),
          onLongPress: () => _showHabitOptions(habit),
        ),
        ),
      ),
    );
  }

  /// 弹出习惯操作菜单
  void _showHabitOptions(Habit habit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('修改名称'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRenameDialog(habit);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined, color: Colors.orange),
                title: const Text('归档'),
                subtitle: const Text('归档后可在设置中恢复', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onArchiveHabit?.call(habit.id);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// 弹出修改名称对话框
  void _showRenameDialog(Habit habit) {
    final controller = TextEditingController(text: habit.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('修改名称'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '习惯名称',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              final newName = value.trim();
              if (newName.isNotEmpty && newName != habit.name) {
                widget.onRenameHabit?.call(habit.id, newName);
              }
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != habit.name) {
                  widget.onRenameHabit?.call(habit.id, newName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
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
