/// 应用常量
/// 集中管理应用中使用的常量值
class AppConstants {
  // ============================================================
  // Hive 存储相关常量
  // ============================================================

  /// Hive 数据库名称
  static const String hiveBoxName = 'habit_tracker_box';

  /// 习惯数据在Hive中的键前缀
  static const String habitKeyPrefix = 'habit_';

  /// 打卡记录在Hive中的键前缀
  static const String checkInKeyPrefix = 'checkin_';

  /// 统计数据在Hive中的键前缀
  static const String statsKeyPrefix = 'stats_';

  /// 待同步记录列表的键
  static const String pendingSyncKey = 'pending_sync';

  // ============================================================
  // 日期格式常量
  // ============================================================

  /// 日期格式 - 年月日（用于存储和比较）
  static const String dateFormat = 'yyyy-MM-dd';

  /// 日期时间格式（用于显示）
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  /// 时间格式（用于显示）
  static const String timeFormat = 'HH:mm';

  // ============================================================
  // 打卡相关常量
  // ============================================================

  /// 默认目标连续打卡天数
  static const int defaultGoalStreakDays = 30;

  /// 最大目标连续打卡天数
  static const int maxGoalStreakDays = 365;

  /// 补签最大天数限制（允许补签最近N天内的记录）
  static const int backfillMaxDays = 7;

  // ============================================================
  // 提醒相关常量
  // ============================================================

  /// 默认提醒时间（小时:分钟）
  static const String defaultReminderTime = '09:00';

  /// 每个习惯最大提醒次数
  static const int maxReminderTimes = 3;

  // ============================================================
  // 分页与列表常量
  // ============================================================

  /// 默认每页数量
  static const int defaultPageSize = 20;

  /// 热力图显示天数（最近N天）
  static const int heatmapDays = 90;

  /// 统计面板显示天数（最近7天）
  static const int statsRecentDays = 7;

  // ============================================================
  // 动画与UI常量
  // ============================================================

  /// 默认动画时长（毫秒）
  static const int defaultAnimationDuration = 300;

  /// 卡片圆角半径
  static const double cardBorderRadius = 12.0;

  /// 习惯卡片高度
  static const double habitCardHeight = 80.0;

  // ============================================================
  // 正则表达式
  // ============================================================

  /// 日期格式校验正则（yyyy-MM-dd）
  static const String dateRegex = r'^\d{4}-\d{2}-\d{2}$';

  /// UUID格式校验正则
  static const String uuidRegex =
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$';
}
