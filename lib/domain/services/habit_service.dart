import '../../data/datasources/local/hive_service.dart';
import '../../data/models/habit_model.dart';

/// 习惯业务服务
///
/// 封装习惯管理的业务逻辑，包括习惯的创建、编辑、删除、归档等操作，
/// 以及预设习惯的创建功能。
class HabitService {
  /// Hive 本地存储服务
  final HiveService _hiveService;

  HabitService({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  // ============================================================
  // 习惯 CRUD 业务逻辑
  // ============================================================

  /// 创建新习惯
  ///
  /// [name] 习惯名称
  /// [userId] 用户ID
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
  /// 返回创建的习惯对象
  Future<Habit> createHabit({
    required String name,
    required String userId,
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
    int sortOrder = 0,
  }) async {
    // 参数校验
    if (name.trim().isEmpty) {
      throw ArgumentError('习惯名称不能为空');
    }

    // 创建习惯对象
    final habit = Habit(
      userId: userId,
      name: name.trim(),
      description: description.trim(),
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

    // 保存到本地数据库
    await _hiveService.saveHabit(habit);

    return habit;
  }

  /// 更新习惯
  ///
  /// [habitId] 习惯ID
  /// [name] 新的习惯名称
  /// [description] 新的描述
  /// [category] 新的分类
  /// [iconName] 新的图标名称
  /// [colorValue] 新的颜色值
  /// [frequency] 新的频率
  /// [specificDays] 新的指定天数
  /// [targetCount] 新的目标数量
  /// [targetValue] 新的目标值
  /// [unit] 新的单位
  /// [reminderTimes] 新的提醒时间
  /// [goalStreakDays] 新的目标连续天数
  /// [sortOrder] 新的排序顺序
  /// 返回更新后的习惯对象
  Future<Habit> updateHabit({
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
    // 获取现有习惯
    final existingHabit = await _hiveService.getHabit(habitId);
    if (existingHabit == null) {
      throw StateError('习惯不存在: $habitId');
    }

    // 如果更新了名称，进行校验
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError('习惯名称不能为空');
    }

    // 创建更新后的习惯对象
    final updatedHabit = existingHabit.copyWith(
      name: name?.trim(),
      description: description?.trim(),
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

    // 保存到本地数据库
    await _hiveService.saveHabit(updatedHabit);

    return updatedHabit;
  }

  /// 删除习惯（软删除）
  ///
  /// [habitId] 习惯ID
  Future<void> deleteHabit(String habitId) async {
    final habit = await _hiveService.getHabit(habitId);
    if (habit == null) {
      throw StateError('习惯不存在: $habitId');
    }
    await _hiveService.deleteHabit(habitId);
  }

  /// 归档习惯
  ///
  /// [habitId] 习惯ID
  Future<void> archiveHabit(String habitId) async {
    final habit = await _hiveService.getHabit(habitId);
    if (habit == null) {
      throw StateError('习惯不存在: $habitId');
    }
    await _hiveService.archiveHabit(habitId);
  }

  /// 取消归档习惯
  ///
  /// [habitId] 习惯ID
  Future<void> unarchiveHabit(String habitId) async {
    final habit = await _hiveService.getHabit(habitId);
    if (habit == null) {
      throw StateError('习惯不存在: $habitId');
    }
    await _hiveService.unarchiveHabit(habitId);
  }

  // ============================================================
  // 查询业务逻辑
  // ============================================================

  /// 获取所有活跃习惯
  ///
  /// [userId] 用户ID
  /// 返回活跃习惯列表（按创建时间倒序）
  Future<List<Habit>> getActiveHabits(String userId) async {
    return await _hiveService.getActiveHabits(userId);
  }

  /// 获取所有已归档习惯
  ///
  /// [userId] 用户ID
  /// 返回已归档习惯列表
  Future<List<Habit>> getArchivedHabits(String userId) async {
    return await _hiveService.getArchivedHabits(userId);
  }

  /// 获取所有习惯（包括归档的）
  ///
  /// [userId] 用户ID
  /// 返回所有习惯列表
  Future<List<Habit>> getAllHabits(String userId) async {
    return await _hiveService.getAllHabits(userId);
  }

  /// 根据ID获取习惯
  ///
  /// [habitId] 习惯ID
  /// 返回习惯对象，不存在时返回null
  Future<Habit?> getHabitById(String habitId) async {
    return await _hiveService.getHabit(habitId);
  }

  /// 按分类筛选习惯
  ///
  /// [userId] 用户ID
  /// [category] 要筛选的分类
  /// 返回该分类下的活跃习惯列表
  Future<List<Habit>> getHabitsByCategory({
    required String userId,
    required HabitCategory category,
  }) async {
    final activeHabits = await _hiveService.getActiveHabits(userId);
    return activeHabits.where((h) => h.category == category).toList();
  }

  /// 搜索习惯
  ///
  /// [userId] 用户ID
  /// [query] 搜索关键词
  /// 返回匹配的活跃习惯列表（匹配名称或描述）
  Future<List<Habit>> searchHabits({
    required String userId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      return await _hiveService.getActiveHabits(userId);
    }

    final activeHabits = await _hiveService.getActiveHabits(userId);
    final lowerQuery = query.trim().toLowerCase();

    return activeHabits.where((habit) {
      return habit.name.toLowerCase().contains(lowerQuery) ||
          habit.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ============================================================
  // 预设习惯
  // ============================================================

  /// 创建默认预设习惯
  ///
  /// [userId] 用户ID
  /// 返回创建的预设习惯列表
  Future<List<Habit>> createDefaultHabits(String userId) async {
    final defaults = _getDefaultHabitDefinitions(userId);

    final habits = <Habit>[];
    for (final definition in defaults) {
      final habit = await createHabit(
        name: definition['name'] as String,
        userId: userId,
        description: definition['description'] as String,
        category: definition['category'] as HabitCategory,
        iconName: definition['iconName'] as String,
        colorValue: definition['colorValue'] as int,
        frequency: definition['frequency'] as HabitFrequency,
        goalStreakDays: definition['goalStreakDays'] as int,
      );
      habits.add(habit);
    }

    return habits;
  }

  /// 获取预设习惯定义列表
  ///
  /// [userId] 用户ID
  /// 返回预设习惯的参数 Map 列表（不实际创建）
  List<Map<String, dynamic>> getDefaultHabitDefinitions(String userId) {
    return _getDefaultHabitDefinitions(userId);
  }

  /// 内部方法：定义默认习惯
  static List<Map<String, dynamic>> _getDefaultHabitDefinitions(String userId) {
    return [
      {
        'name': '每日补剂',
        'description': '每天按时服用维生素和补充剂',
        'category': HabitCategory.supplement,
        'iconName': 'medication',
        'colorValue': 0xFF4CAF50, // 绿色
        'frequency': HabitFrequency.daily,
        'goalStreakDays': 30,
      },
      {
        'name': '学英语',
        'description': '每天学习英语单词和语法',
        'category': HabitCategory.learning,
        'iconName': 'language',
        'colorValue': 0xFF2196F3, // 蓝色
        'frequency': HabitFrequency.daily,
        'goalStreakDays': 30,
      },
      {
        'name': '游戏登录',
        'description': '每天登录游戏领取签到奖励',
        'category': HabitCategory.gaming,
        'iconName': 'sports_esports',
        'colorValue': 0xFF9C27B0, // 紫色
        'frequency': HabitFrequency.daily,
        'goalStreakDays': 30,
      },
      {
        'name': '晨间运动',
        'description': '每天早晨进行30分钟运动',
        'category': HabitCategory.exercise,
        'iconName': 'fitness_center',
        'colorValue': 0xFFFF9800, // 橙色
        'frequency': HabitFrequency.daily,
        'goalStreakDays': 30,
      },
      {
        'name': '阅读打卡',
        'description': '每天阅读至少30分钟',
        'category': HabitCategory.learning,
        'iconName': 'menu_book',
        'colorValue': 0xFF607D8B, // 灰蓝色
        'frequency': HabitFrequency.daily,
        'goalStreakDays': 30,
      },
    ];
  }
}
