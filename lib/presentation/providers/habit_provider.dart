import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/habit_model.dart';
import '../../domain/services/habit_service.dart';

/// 习惯列表状态
///
/// 包含习惯列表数据、加载状态、筛选条件和搜索关键词
class HabitState {
  /// 习惯列表
  final List<Habit> habits;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息（null表示无错误）
  final String? error;

  /// 当前筛选的分类（null表示不筛选）
  final HabitCategory? filterCategory;

  /// 搜索关键词
  final String searchQuery;

  const HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
    this.filterCategory,
    this.searchQuery = '',
  });

  /// 创建副本
  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    String? error,
    HabitCategory? filterCategory,
    String? searchQuery,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterCategory: clearFilter ? null : (filterCategory ?? this.filterCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// 获取筛选和搜索后的习惯列表
  List<Habit> get filteredHabits {
    var result = habits;

    // 按分类筛选
    if (filterCategory != null) {
      result = result.where((h) => h.category == filterCategory).toList();
    }

    // 按关键词搜索
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result.where((h) {
        return h.name.toLowerCase().contains(query) ||
            h.description.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  /// 获取按分类分组的习惯列表
  Map<HabitCategory, List<Habit>> get groupedByCategory {
    final grouped = <HabitCategory, List<Habit>>{};
    for (final habit in filteredHabits) {
      grouped.putIfAbsent(habit.category, () => []).add(habit);
    }
    return grouped;
  }
}

/// 习惯状态管理 Notifier
///
/// 使用 StateNotifier 管理习惯列表的状态，提供加载、增删改查、筛选和搜索功能。
class HabitNotifier extends StateNotifier<HabitState> {
  /// 习惯业务服务
  final HabitService _habitService;

  /// 当前用户ID
  final String _userId;

  HabitNotifier({
    required HabitService habitService,
    required String userId,
  })  : _habitService = habitService,
        _userId = userId,
        super(const HabitState());

  // ============================================================
  // 加载数据
  // ============================================================

  /// 加载所有活跃习惯
  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final habits = await _habitService.getActiveHabits(_userId);
      // 按 sortOrder 排序
      habits.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      state = state.copyWith(habits: habits, isLoading: false);
      
      // 调试输出
      print('DEBUG: 已加载 ${habits.length} 个习惯');
      for (final h in habits) {
        print('DEBUG: - ${h.name} (order: ${h.sortOrder})');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载习惯失败: ${e.toString()}',
      );
      print('DEBUG: 加载习惯失败: $e');
    }
  }

  /// 刷新习惯列表（静默刷新，不显示加载状态）
  Future<void> refreshHabits() async {
    try {
      final habits = await _habitService.getActiveHabits(_userId);
      state = state.copyWith(habits: habits, clearError: true);
    } catch (e) {
      // 静默刷新失败不改变加载状态，只记录错误
      state = state.copyWith(error: '刷新失败: ${e.toString()}');
    }
  }

  // ============================================================
  // 习惯 CRUD
  // ============================================================

  /// 添加新习惯
  ///
  /// [name] 习惯名称
  /// [description] 习惯描述
  /// [category] 习惯分类
  /// [iconName] 图标名称
  /// [colorValue] 颜色值
  /// [frequency] 打卡频率
  /// [specificDays] 指定打卡的星期几
  /// [targetCount] 每次打卡目标数量
  /// [targetValue] 目标值
  /// [unit] 单位
  /// [reminderTimes] 提醒时间列表
  /// [goalStreakDays] 目标连续打卡天数
  Future<void> addHabit({
    required String name,
    String description = '',
    HabitCategory category = HabitCategory.custom,
    String iconName = 'circle',
    int colorValue = 0xFF6B7280,
    HabitFrequency frequency = HabitFrequency.daily,
    List<int>? specificDays,
    int targetCount = 1,
    double targetValue = 1.0,
    String unit = '次',
    List<String>? reminderTimes,
    int goalStreakDays = 30,
  }) async {
    try {
      // 计算新的 sortOrder（当前最大 + 1）
      final maxOrder = state.habits.isEmpty 
          ? 0 
          : state.habits.map((h) => h.sortOrder).reduce((a, b) => a > b ? a : b);
      
      final habit = await _habitService.createHabit(
        name: name,
        userId: _userId,
        description: description,
        category: category,
        iconName: iconName,
        colorValue: colorValue,
        frequency: frequency,
        specificDays: specificDays,
        targetCount: targetCount,
        targetValue: targetValue,
        unit: unit,
        reminderTimes: reminderTimes,
        goalStreakDays: goalStreakDays,
        sortOrder: maxOrder + 1,
      );

      // 将新习惯添加到列表
      final updatedHabits = [...state.habits, habit];
      // 按 sortOrder 排序
      updatedHabits.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      state = state.copyWith(habits: updatedHabits, clearError: true);
      
      // 调试输出
      print('DEBUG: 习惯已保存: ${habit.name}, ID: ${habit.id}');
      print('DEBUG: 当前习惯列表数量: ${updatedHabits.length}');
    } catch (e) {
      state = state.copyWith(error: '添加习惯失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 编辑习惯
  ///
  /// [habitId] 习惯ID
  /// 其他参数为可选的更新字段
  Future<void> editHabit({
    required String habitId,
    String? name,
    String? description,
    HabitCategory? category,
    String? iconName,
    int? colorValue,
    HabitFrequency? frequency,
    List<int>? specificDays,
    int? targetCount,
    double? targetValue,
    String? unit,
    List<String>? reminderTimes,
    int? goalStreakDays,
    int? sortOrder,
  }) async {
    try {
      final updatedHabit = await _habitService.updateHabit(
        habitId: habitId,
        name: name,
        description: description,
        category: category,
        iconName: iconName,
        colorValue: colorValue,
        frequency: frequency,
        specificDays: specificDays,
        targetCount: targetCount,
        targetValue: targetValue,
        unit: unit,
        reminderTimes: reminderTimes,
        goalStreakDays: goalStreakDays,
        sortOrder: sortOrder,
      );

      // 更新列表中的对应习惯
      final updatedHabits = state.habits.map((h) {
        return h.id == habitId ? updatedHabit : h;
      }).toList();

      state = state.copyWith(habits: updatedHabits, clearError: true);
    } catch (e) {
      state = state.copyWith(error: '编辑习惯失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 删除习惯
  ///
  /// [habitId] 习惯ID
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitService.deleteHabit(habitId);

      // 从列表中移除
      final updatedHabits =
          state.habits.where((h) => h.id != habitId).toList();
      state = state.copyWith(habits: updatedHabits, clearError: true);
    } catch (e) {
      state = state.copyWith(error: '删除习惯失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 归档习惯
  ///
  /// [habitId] 习惯ID
  Future<void> archiveHabit(String habitId) async {
    try {
      await _habitService.archiveHabit(habitId);

      // 从活跃列表中移除
      final updatedHabits =
          state.habits.where((h) => h.id != habitId).toList();
      state = state.copyWith(habits: updatedHabits, clearError: true);
    } catch (e) {
      state = state.copyWith(error: '归档习惯失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 恢复已归档习惯
  ///
  /// [habitId] 习惯ID
  Future<void> unarchiveHabit(String habitId) async {
    try {
      await _habitService.unarchiveHabit(habitId);
      // 重新加载习惯列表
      await loadHabits();
    } catch (e) {
      state = state.copyWith(error: '恢复习惯失败: ${e.toString()}');
      rethrow;
    }
  }

  /// 加载已归档习惯列表
  Future<List<Habit>> loadArchivedHabits() async {
    return await _habitService.getArchivedHabits(_userId);
  }

  // ============================================================
  // 筛选与搜索
  // ============================================================

  /// 按分类筛选习惯
  ///
  /// [category] 要筛选的分类，传入null取消筛选
  void filterByCategory(HabitCategory? category) {
    if (category == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(filterCategory: category);
    }
  }

  /// 清除分类筛选
  void clearFilter() {
    state = state.copyWith(clearFilter: true);
  }

  /// 搜索习惯
  ///
  /// [query] 搜索关键词，传入空字符串清除搜索
  void searchHabits(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 清除搜索关键词
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// 清除所有筛选和搜索条件
  void clearAllFilters() {
    state = state.copyWith(clearFilter: true, searchQuery: '');
  }

  // ============================================================
  // 预设习惯
  // ============================================================

  /// 创建默认预设习惯
  Future<void> createDefaultHabits() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final newHabits = await _habitService.createDefaultHabits(_userId);
      final updatedHabits = [...newHabits, ...state.habits];
      state = state.copyWith(habits: updatedHabits, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '创建预设习惯失败: ${e.toString()}',
      );
    }
  }

  // ============================================================
  // 错误处理
  // ============================================================

  /// 清除错误信息
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ============================================================
// Providers
// ============================================================

/// 习惯业务服务 Provider
///
/// 提供全局单例的 HabitService 实例
final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService();
});

/// 当前用户ID Provider
///
/// 默认使用本地用户ID，登录后可覆盖为实际用户ID
final currentUserIdProvider = StateProvider<String>((ref) {
  return 'local_user';
});

/// 习惯状态管理 Provider
///
/// 监听习惯列表的变化，提供加载、增删改查、筛选和搜索功能
final habitProvider =
    StateNotifierProvider<HabitNotifier, HabitState>((ref) {
  final habitService = ref.watch(habitServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  return HabitNotifier(habitService: habitService, userId: userId);
});

/// 按分类筛选后的习惯列表 Provider
///
/// 便捷 Provider，直接提供筛选后的习惯列表
final filteredHabitsProvider = Provider<List<Habit>>((ref) {
  final habitState = ref.watch(habitProvider);
  return habitState.filteredHabits;
});

/// 按分类分组的习惯列表 Provider
///
/// 便捷 Provider，直接提供分组后的习惯列表
final groupedHabitsProvider =
    Provider<Map<HabitCategory, List<Habit>>>((ref) {
  final habitState = ref.watch(habitProvider);
  return habitState.groupedByCategory;
});
