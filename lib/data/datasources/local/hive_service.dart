import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../models/checkin_model.dart';
import '../../models/habit_model.dart';
import '../../models/habit_stats_model.dart';

/// Hive本地存储服务
///
/// 负责习惯和打卡记录的本地持久化存储，提供CRUD操作和查询功能。
/// 使用Hive作为本地数据库引擎。
class HiveService {
  // ============================================================
  // 单例模式
  // ============================================================

  static HiveService? _instance;

  /// 获取HiveService单例实例
  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }

  HiveService._();

  // ============================================================
  // Box引用
  // ============================================================

  Box? _box;

  /// 获取或初始化Hive Box
  Future<Box> _getBox() async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox(AppConstants.hiveBoxName);
    return _box!;
  }

  // ============================================================
  // 初始化与清理
  // ============================================================

  /// 初始化Hive服务，打开数据库
  Future<void> init() async {
    await _getBox();
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }

  /// 清空所有数据（慎用！）
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }

  // ============================================================
  // 习惯 CRUD
  // ============================================================

  /// 保存习惯（新增或更新）
  Future<void> saveHabit(Habit habit) async {
    final box = await _getBox();
    final key = '${AppConstants.habitKeyPrefix}${habit.id}';
    await box.put(key, habit.toJson());
  }

  /// 批量保存习惯
  Future<void> saveHabits(List<Habit> habits) async {
    final box = await _getBox();
    final Map<String, Map<String, dynamic>> entries = {};
    for (final habit in habits) {
      final key = '${AppConstants.habitKeyPrefix}${habit.id}';
      entries[key] = habit.toJson();
    }
    await box.putAll(entries);
  }

  /// 根据ID获取习惯
  Future<Habit?> getHabit(String id) async {
    final box = await _getBox();
    final key = '${AppConstants.habitKeyPrefix}$id';
    final json = box.get(key);
    if (json == null) return null;
    return Habit.fromJson(Map<String, dynamic>.from(json as Map));
  }

  /// 获取用户的所有习惯
  Future<List<Habit>> getAllHabits(String userId) async {
    final box = await _getBox();
    final habits = <Habit>[];

    for (final key in box.keys) {
      if (key.toString().startsWith(AppConstants.habitKeyPrefix)) {
        final json = box.get(key);
        if (json != null) {
          final habit = Habit.fromJson(Map<String, dynamic>.from(json as Map));
          if (habit.userId == userId && !habit.isDeleted) {
            habits.add(habit);
          }
        }
      }
    }

    // 按 sortOrder 排序（越小越靠前），sortOrder 相同则按创建时间倒序
    habits.sort((a, b) {
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
    return habits;
  }

  /// 获取用户的所有活跃习惯（未删除且未归档）
  Future<List<Habit>> getActiveHabits(String userId) async {
    final allHabits = await getAllHabits(userId);
    return allHabits.where((h) => h.isActive).toList();
  }

  /// 获取用户的所有已归档习惯
  Future<List<Habit>> getArchivedHabits(String userId) async {
    final allHabits = await getAllHabits(userId);
    return allHabits.where((h) => h.isArchived).toList();
  }

  /// 删除习惯（软删除）
  Future<void> deleteHabit(String id) async {
    final habit = await getHabit(id);
    if (habit != null) {
      await saveHabit(habit.copyWith(isDeleted: true));
    }
  }

  /// 彻底删除习惯（从数据库中移除）
  Future<void> permanentlyDeleteHabit(String id) async {
    final box = await _getBox();
    final key = '${AppConstants.habitKeyPrefix}$id';
    await box.delete(key);
  }

  /// 归档习惯
  Future<void> archiveHabit(String id) async {
    final habit = await getHabit(id);
    if (habit != null) {
      await saveHabit(habit.copyWith(archivedAt: DateTime.now()));
    }
  }

  /// 取消归档习惯
  Future<void> unarchiveHabit(String id) async {
    final habit = await getHabit(id);
    if (habit != null) {
      await saveHabit(habit.copyWith(clearArchivedAt: true));
    }
  }

  // ============================================================
  // 打卡记录 CRUD
  // ============================================================

  /// 保存打卡记录（新增或更新）
  Future<void> saveCheckIn(CheckIn checkIn) async {
    final box = await _getBox();
    final key = '${AppConstants.checkInKeyPrefix}${checkIn.id}';
    await box.put(key, checkIn.toJson());

    // 如果未同步，添加到待同步列表
    if (!checkIn.synced) {
      await _addPendingSync(checkIn.id);
    }
  }

  /// 批量保存打卡记录
  Future<void> saveCheckIns(List<CheckIn> checkIns) async {
    final box = await _getBox();
    final Map<String, Map<String, dynamic>> entries = {};
    for (final checkIn in checkIns) {
      final key = '${AppConstants.checkInKeyPrefix}${checkIn.id}';
      entries[key] = checkIn.toJson();
    }
    await box.putAll(entries);

    // 将未同步的记录添加到待同步列表
    final pendingIds =
        checkIns.where((c) => !c.synced).map((c) => c.id).toList();
    if (pendingIds.isNotEmpty) {
      await _addPendingSyncIds(pendingIds);
    }
  }

  /// 根据ID获取打卡记录
  Future<CheckIn?> getCheckIn(String id) async {
    final box = await _getBox();
    final key = '${AppConstants.checkInKeyPrefix}$id';
    final json = box.get(key);
    if (json == null) return null;
    return CheckIn.fromJson(Map<String, dynamic>.from(json as Map));
  }

  /// 获取某个习惯的所有打卡记录
  Future<List<CheckIn>> getCheckInsByHabit(String habitId) async {
    final box = await _getBox();
    final checkIns = <CheckIn>[];

    for (final key in box.keys) {
      if (key.toString().startsWith(AppConstants.checkInKeyPrefix)) {
        final json = box.get(key);
        if (json != null) {
          final checkIn =
              CheckIn.fromJson(Map<String, dynamic>.from(json as Map));
          if (checkIn.habitId == habitId) {
            checkIns.add(checkIn);
          }
        }
      }
    }

    // 按日期倒序排列
    checkIns.sort((a, b) => b.date.compareTo(a.date));
    return checkIns;
  }

  /// 获取某个习惯在指定日期的打卡记录
  Future<List<CheckIn>> getCheckInsByDate({
    required String habitId,
    required String date,
  }) async {
    final allCheckIns = await getCheckInsByHabit(habitId);
    return allCheckIns.where((c) => c.date == date).toList();
  }

  /// 获取某个习惯在日期范围内的打卡记录
  Future<List<CheckIn>> getCheckInsByDateRange({
    required String habitId,
    required String startDate,
    required String endDate,
  }) async {
    final allCheckIns = await getCheckInsByHabit(habitId);
    return allCheckIns
        .where((c) => c.date.compareTo(startDate) >= 0 && c.date.compareTo(endDate) <= 0)
        .toList();
  }

  /// 获取某个习惯的所有打卡日期列表
  Future<List<String>> getCheckInDates(String habitId) async {
    final checkIns = await getCheckInsByHabit(habitId);
    // 去重并返回日期列表
    return checkIns.map((c) => c.date).toSet().toList()..sort();
  }

  /// 获取某个习惯在指定日期是否已打卡
  Future<bool> hasCheckedIn({
    required String habitId,
    required String date,
  }) async {
    final checkIns = await getCheckInsByDate(habitId: habitId, date: date);
    return checkIns.isNotEmpty;
  }

  /// 删除打卡记录
  Future<void> deleteCheckIn(String id) async {
    final box = await _getBox();
    final key = '${AppConstants.checkInKeyPrefix}$id';
    await box.delete(key);
    // 从待同步列表中移除
    await _removePendingSync(id);
  }

  /// 删除某个习惯的所有打卡记录
  Future<void> deleteCheckInsByHabit(String habitId) async {
    final checkIns = await getCheckInsByHabit(habitId);
    final box = await _getBox();
    for (final checkIn in checkIns) {
      final key = '${AppConstants.checkInKeyPrefix}${checkIn.id}';
      await box.delete(key);
    }
  }

  // ============================================================
  // 统计数据
  // ============================================================

  /// 保存统计数据
  Future<void> saveStats(HabitStats stats) async {
    final box = await _getBox();
    final key = '${AppConstants.statsKeyPrefix}${stats.habitId}';
    await box.put(key, stats.toJson());
  }

  /// 获取统计数据
  Future<HabitStats?> getStats(String habitId) async {
    final box = await _getBox();
    final key = '${AppConstants.statsKeyPrefix}$habitId';
    final json = box.get(key);
    if (json == null) return null;
    return HabitStats.fromJson(Map<String, dynamic>.from(json as Map));
  }

  /// 删除统计数据
  Future<void> deleteStats(String habitId) async {
    final box = await _getBox();
    final key = '${AppConstants.statsKeyPrefix}$habitId';
    await box.delete(key);
  }

  // ============================================================
  // 同步相关
  // ============================================================

  /// 获取所有待同步的打卡记录ID列表
  Future<List<String>> getPendingSyncIds() async {
    final box = await _getBox();
    final ids = box.get(AppConstants.pendingSyncKey);
    if (ids == null) return [];
    return List<String>.from(ids as List);
  }

  /// 获取所有待同步的打卡记录
  Future<List<CheckIn>> getPendingSyncCheckIns() async {
    final ids = await getPendingSyncIds();
    final checkIns = <CheckIn>[];
    for (final id in ids) {
      final checkIn = await getCheckIn(id);
      if (checkIn != null) {
        checkIns.add(checkIn);
      }
    }
    return checkIns;
  }

  /// 标记打卡记录为已同步
  Future<void> markAsSynced(String checkInId) async {
    final checkIn = await getCheckIn(checkInId);
    if (checkIn != null) {
      await saveCheckIn(checkIn.markAsSynced());
    }
    await _removePendingSync(checkInId);
  }

  /// 批量标记打卡记录为已同步
  Future<void> markBatchAsSynced(List<String> checkInIds) async {
    for (final id in checkInIds) {
      await markAsSynced(id);
    }
  }

  /// 添加单个ID到待同步列表
  Future<void> _addPendingSync(String id) async {
    final box = await _getBox();
    final existingIds = await getPendingSyncIds();
    if (!existingIds.contains(id)) {
      existingIds.add(id);
      await box.put(AppConstants.pendingSyncKey, existingIds);
    }
  }

  /// 批量添加ID到待同步列表
  Future<void> _addPendingSyncIds(List<String> ids) async {
    final box = await _getBox();
    final existingIds = await getPendingSyncIds();
    for (final id in ids) {
      if (!existingIds.contains(id)) {
        existingIds.add(id);
      }
    }
    await box.put(AppConstants.pendingSyncKey, existingIds);
  }

  /// 从待同步列表中移除ID
  Future<void> _removePendingSync(String id) async {
    final box = await _getBox();
    final existingIds = await getPendingSyncIds();
    existingIds.remove(id);
    await box.put(AppConstants.pendingSyncKey, existingIds);
  }

  // ============================================================
  // 数据统计辅助方法
  // ============================================================

  /// 计算并更新某个习惯的统计数据
  Future<HabitStats> calculateAndSaveStats({
    required Habit habit,
  }) async {
    final checkInDates = await getCheckInDates(habit.id);
    final today = AppDateUtils.getTodayString();

    // 计算总天数（从创建日期到今天）
    final totalDays = AppDateUtils.daysBetween(habit.createdAt, DateTime.now()) + 1;

    // 计算连续打卡天数
    final currentStreak = AppDateUtils.calculateStreak(checkInDates);

    // 计算最长连续打卡天数
    final longestStreak = AppDateUtils.calculateLongestStreak(checkInDates);

    // 计算总打卡次数
    final checkIns = await getCheckInsByHabit(habit.id);
    final totalCheckIns = checkIns.fold<int>(0, (sum, c) => sum + c.count);

    // 计算完成率
    final completionRate = totalDays > 0 ? checkInDates.length / totalDays : 0.0;

    // 计算最近7天打卡情况
    final recentDays = AppDateUtils.getRecentDays(7);
    final last7Days = recentDays.map((date) => checkInDates.contains(date)).toList();

    // 构建热力图数据
    final heatmapData = <String, int>{};
    for (final checkIn in checkIns) {
      if (heatmapData.containsKey(checkIn.date)) {
        heatmapData[checkIn.date] = heatmapData[checkIn.date]! + checkIn.count;
      } else {
        heatmapData[checkIn.date] = checkIn.count;
      }
    }

    // 创建统计对象
    final stats = HabitStats(
      habitId: habit.id,
      userId: habit.userId,
      currentStreak: currentStreak,
      longestStreak: longestStreak > currentStreak ? longestStreak : currentStreak,
      totalCheckIns: totalCheckIns,
      totalDays: totalDays,
      completionRate: completionRate,
      last7Days: last7Days,
      heatmapData: heatmapData,
      lastUpdated: DateTime.now(),
    );

    // 保存统计数据
    await saveStats(stats);

    return stats;
  }
}
