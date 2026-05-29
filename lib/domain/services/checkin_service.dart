import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../data/datasources/local/hive_service.dart';
import '../../data/models/checkin_model.dart';
import '../../data/models/habit_model.dart';
import '../../data/models/habit_stats_model.dart';

/// 打卡业务服务
///
/// 封装打卡的业务逻辑，包括打卡操作、撤销打卡、补打卡、
/// 打卡状态判断以及打卡统计计算等功能。
class CheckInService {
  /// Hive 本地存储服务
  final HiveService _hiveService;

  CheckInService({HiveService? hiveService})
      : _hiveService = hiveService ?? HiveService.instance;

  // ============================================================
  // 打卡操作
  // ============================================================

  /// 执行打卡操作
  ///
  /// [habitId] 习惯ID
  /// [userId] 用户ID
  /// [count] 打卡数量（默认1）
  /// [note] 备注
  /// [type] 打卡类型（默认正常打卡）
  /// 返回创建的打卡记录
  Future<CheckIn> checkIn({
    required String habitId,
    required String userId,
    int count = 1,
    String note = '',
    CheckInType type = CheckInType.normal,
  }) async {
    // 检查习惯是否存在
    final habit = await _hiveService.getHabit(habitId);
    if (habit == null) {
      throw StateError('习惯不存在: $habitId');
    }

    // 检查是否已打卡（正常打卡不允许重复）
    if (type == CheckInType.normal) {
      final today = AppDateUtils.getTodayString();
      final alreadyChecked = await _hiveService.hasCheckedIn(
        habitId: habitId,
        date: today,
      );
      if (alreadyChecked) {
        throw StateError('今日已打卡，请勿重复操作');
      }
    }

    // 参数校验
    if (count <= 0) {
      throw ArgumentError('打卡数量必须大于0');
    }

    // 创建打卡记录
    final checkIn = CheckIn(
      habitId: habitId,
      userId: userId,
      date: AppDateUtils.getTodayString(),
      count: count,
      note: note,
      type: type,
      isBackfilled: type == CheckInType.backfill,
      backfilledAt: type == CheckInType.backfill ? DateTime.now() : null,
    );

    // 保存到本地数据库
    await _hiveService.saveCheckIn(checkIn);

    return checkIn;
  }

  /// 撤销打卡
  ///
  /// [habitId] 习惯ID
  /// [date] 要撤销的日期（默认今天）
  /// 返回是否撤销成功
  Future<bool> undoCheckIn({
    required String habitId,
    String? date,
  }) async {
    final targetDate = date ?? AppDateUtils.getTodayString();

    // 获取该日期的打卡记录
    final checkIns = await _hiveService.getCheckInsByDate(
      habitId: habitId,
      date: targetDate,
    );

    if (checkIns.isEmpty) {
      return false; // 没有打卡记录，无需撤销
    }

    // 删除所有该日期的打卡记录
    for (final checkIn in checkIns) {
      await _hiveService.deleteCheckIn(checkIn.id);
    }

    return true;
  }

  /// 补打卡
  ///
  /// [habitId] 习惯ID
  /// [userId] 用户ID
  /// [date] 要补打卡的日期（yyyy-MM-dd格式）
  /// [count] 打卡数量（默认1）
  /// [note] 备注
  /// 返回创建的补签打卡记录
  Future<CheckIn> backfillCheckIn({
    required String habitId,
    required String userId,
    required String date,
    int count = 1,
    String note = '',
  }) async {
    // 校验日期格式
    if (!RegExp(AppConstants.dateRegex).hasMatch(date)) {
      throw ArgumentError('日期格式不正确，应为 yyyy-MM-dd');
    }

    // 检查补签日期是否在允许范围内
    final canBackfill = await canBackfillCheckIn(
      habitId: habitId,
      date: date,
    );
    if (!canBackfill) {
      throw StateError(
        '超出补签范围，只能补签最近 ${AppConstants.backfillMaxDays} 天内的记录',
      );
    }

    // 检查该日期是否已打卡
    final alreadyChecked = await _hiveService.hasCheckedIn(
      habitId: habitId,
      date: date,
    );
    if (alreadyChecked) {
      throw StateError('该日期已打卡，请勿重复补签');
    }

    // 检查习惯是否存在
    final habit = await _hiveService.getHabit(habitId);
    if (habit == null) {
      throw StateError('习惯不存在: $habitId');
    }

    // 创建补签记录
    final checkIn = CheckIn(
      habitId: habitId,
      userId: userId,
      date: date,
      count: count,
      note: note,
      type: CheckInType.backfill,
      isBackfilled: true,
      backfilledAt: DateTime.now(),
    );

    // 保存到本地数据库
    await _hiveService.saveCheckIn(checkIn);

    return checkIn;
  }

  // ============================================================
  // 打卡状态判断
  // ============================================================

  /// 判断某个习惯今日是否已打卡
  ///
  /// [habitId] 习惯ID
  /// 返回是否已打卡
  Future<bool> isCheckedInToday(String habitId) async {
    final today = AppDateUtils.getTodayString();
    return await _hiveService.hasCheckedIn(habitId: habitId, date: today);
  }

  /// 判断某个习惯在指定日期是否已打卡
  ///
  /// [habitId] 习惯ID
  /// [date] 日期字符串（yyyy-MM-dd）
  /// 返回是否已打卡
  Future<bool> isCheckedInOnDate({
    required String habitId,
    required String date,
  }) async {
    return await _hiveService.hasCheckedIn(habitId: habitId, date: date);
  }

  /// 检查是否可以补打卡
  ///
  /// [habitId] 习惯ID
  /// [date] 要补打卡的日期
  /// 返回是否可以补打卡
  Future<bool> canBackfillCheckIn({
    required String habitId,
    required String date,
  }) async {
    // 补签日期不能是今天或未来
    if (AppDateUtils.isTodayString(date)) {
      return false; // 今天应该使用正常打卡
    }

    final targetDate = AppDateUtils.parseDate(date);
    if (targetDate == null) {
      return false;
    }

    // 补签日期不能是未来日期
    if (AppDateUtils.isAfterDay(targetDate, DateTime.now())) {
      return false;
    }

    // 检查是否在允许的补签天数范围内
    final daysDiff = AppDateUtils.daysBetween(targetDate, DateTime.now());
    if (daysDiff > AppConstants.backfillMaxDays) {
      return false;
    }

    // 检查该日期是否已打卡
    final alreadyChecked = await _hiveService.hasCheckedIn(
      habitId: habitId,
      date: date,
    );
    if (alreadyChecked) {
      return false;
    }

    return true;
  }

  /// 检查习惯是否需要今天打卡
  ///
  /// 根据习惯的频率设置判断今天是否需要打卡
  /// [habit] 习惯对象
  /// 返回是否需要今天打卡
  bool needsCheckInToday(Habit habit) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        // 每周频率：检查今天是否是习惯创建后的某一周的第一天
        // 简化处理：每周频率每天都允许打卡
        return true;
      case HabitFrequency.specificDays:
        // 指定天数：检查今天星期几是否在指定列表中
        final todayWeekday = DateTime.now().weekday; // 1=周一, 7=周日
        return habit.specificDays.contains(todayWeekday);
    }
  }

  // ============================================================
  // 打卡查询
  // ============================================================

  /// 获取今日打卡记录
  ///
  /// [userId] 用户ID
  /// 返回今日所有打卡记录列表
  Future<List<CheckIn>> getTodayCheckIns(String userId) async {
    final today = AppDateUtils.getTodayString();
    final allCheckIns = <CheckIn>[];

    // 获取用户所有活跃习惯
    final habits = await _hiveService.getActiveHabits(userId);

    for (final habit in habits) {
      final checkIns = await _hiveService.getCheckInsByDate(
        habitId: habit.id,
        date: today,
      );
      allCheckIns.addAll(checkIns);
    }

    return allCheckIns;
  }

  /// 获取某个习惯的今日打卡记录
  ///
  /// [habitId] 习惯ID
  /// 返回今日该习惯的打卡记录列表
  Future<List<CheckIn>> getTodayCheckInsByHabit(String habitId) async {
    final today = AppDateUtils.getTodayString();
    return await _hiveService.getCheckInsByDate(
      habitId: habitId,
      date: today,
    );
  }

  /// 获取某个习惯在日期范围内的打卡记录
  ///
  /// [habitId] 习惯ID
  /// [startDate] 开始日期（yyyy-MM-dd）
  /// [endDate] 结束日期（yyyy-MM-dd）
  /// 返回打卡记录列表
  Future<List<CheckIn>> getCheckInsByDateRange({
    required String habitId,
    required String startDate,
    required String endDate,
  }) async {
    return await _hiveService.getCheckInsByDateRange(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 获取某个习惯的所有打卡日期列表
  ///
  /// [habitId] 习惯ID
  /// 返回已打卡的日期字符串列表（去重并排序）
  Future<List<String>> getCheckInDates(String habitId) async {
    return await _hiveService.getCheckInDates(habitId);
  }

  // ============================================================
  // 打卡统计
  // ============================================================

  /// 计算连续打卡天数
  ///
  /// [habitId] 习惯ID
  /// 返回当前连续打卡天数
  Future<int> calculateCurrentStreak(String habitId) async {
    final checkInDates = await _hiveService.getCheckInDates(habitId);
    return AppDateUtils.calculateStreak(checkInDates);
  }

  /// 计算最长连续打卡天数
  ///
  /// [habitId] 习惯ID
  /// 返回历史最长连续打卡天数
  Future<int> calculateLongestStreak(String habitId) async {
    final checkInDates = await _hiveService.getCheckInDates(habitId);
    return AppDateUtils.calculateLongestStreak(checkInDates);
  }

  /// 获取习惯的打卡统计信息
  ///
  /// 通过 HiveService 的计算方法获取完整统计
  /// [habit] 习惯对象
  /// 返回统计数据
  Future<HabitStats> getHabitStats(Habit habit) async {
    return await _hiveService.calculateAndSaveStats(habit: habit);
  }

  /// 获取热力图数据
  ///
  /// [habitId] 习惯ID
  /// [days] 热力图显示天数（默认90天）
  /// 返回日期到打卡次数的映射
  Future<Map<String, int>> getHeatmapData({
    required String habitId,
    int days = AppConstants.heatmapDays,
  }) async {
    final endDate = AppDateUtils.getTodayString();
    final startDate = AppDateUtils.getDaysBeforeToday(days - 1);

    final checkIns = await _hiveService.getCheckInsByDateRange(
      habitId: habitId,
      startDate: startDate,
      endDate: endDate,
    );

    // 构建热力图数据
    final heatmapData = <String, int>{};
    for (final checkIn in checkIns) {
      if (heatmapData.containsKey(checkIn.date)) {
        heatmapData[checkIn.date] = heatmapData[checkIn.date]! + checkIn.count;
      } else {
        heatmapData[checkIn.date] = checkIn.count;
      }
    }

    return heatmapData;
  }

  /// 获取最近N天的打卡完成情况
  ///
  /// [habitId] 习惯ID
  /// [days] 天数（默认7天）
  /// 返回布尔列表，true表示已打卡，false表示未打卡
  /// 索引0=最早的一天，索引N-1=今天
  Future<List<bool>> getRecentDaysCheckInStatus({
    required String habitId,
    int days = 7,
  }) async {
    final recentDays = AppDateUtils.getRecentDays(days);
    final checkInDates = await _hiveService.getCheckInDates(habitId);

    return recentDays.map((date) => checkInDates.contains(date)).toList();
  }
}
