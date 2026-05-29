import 'package:intl/intl.dart';

/// 日期工具类
/// 提供日期相关的常用操作方法
class AppDateUtils {
  // ============================================================
  // 格式化
  // ============================================================

  /// 日期格式化器 - yyyy-MM-dd
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// 日期时间格式化器 - yyyy-MM-dd HH:mm:ss
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// 时间格式化器 - HH:mm
  static final DateFormat _timeFormat = DateFormat('HH:mm');

  /// 获取今日日期字符串（yyyy-MM-dd）
  static String getTodayString() {
    return _dateFormat.format(DateTime.now());
  }

  /// 将DateTime格式化为日期字符串（yyyy-MM-dd）
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// 将DateTime格式化为日期时间字符串（yyyy-MM-dd HH:mm:ss）
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// 将DateTime格式化为时间字符串（HH:mm）
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  /// 将日期字符串解析为DateTime
  /// [dateStr] 格式为 yyyy-MM-dd
  /// 解析失败返回null
  static DateTime? parseDate(String dateStr) {
    try {
      return _dateFormat.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // 日期比较
  // ============================================================

  /// 判断两个日期是否是同一天
  /// [date1] 第一个日期
  /// [date2] 第二个日期
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 判断给定日期是否是今天
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// 判断给定日期字符串是否是今天
  static bool isTodayString(String dateStr) {
    final date = parseDate(dateStr);
    if (date == null) return false;
    return isToday(date);
  }

  /// 判断日期1是否在日期2之前（仅比较日期部分）
  static bool isBeforeDay(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d1.isBefore(d2);
  }

  /// 判断日期1是否在日期2之后（仅比较日期部分）
  static bool isAfterDay(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d1.isAfter(d2);
  }

  // ============================================================
  // 日期计算
  // ============================================================

  /// 获取两个日期之间的天数差（date2 - date1）
  /// 返回正数表示date2在date1之后
  static int daysBetween(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d2.difference(d1).inDays;
  }

  /// 获取从指定日期到今天的天数差
  static int daysFromNow(DateTime date) {
    return daysBetween(date, DateTime.now());
  }

  /// 获取某日期之后N天的日期字符串
  static String getDateAfter(DateTime date, int days) {
    return formatDate(date.add(Duration(days: days)));
  }

  /// 获取某日期之前N天的日期字符串
  static String getDateBefore(DateTime date, int days) {
    return formatDate(date.subtract(Duration(days: days)));
  }

  /// 获取今天之后N天的日期字符串
  static String getDaysAfterToday(int days) {
    return getDateAfter(DateTime.now(), days);
  }

  /// 获取今天之前N天的日期字符串
  static String getDaysBeforeToday(int days) {
    return getDateBefore(DateTime.now(), days);
  }

  // ============================================================
  // 连续打卡计算
  // ============================================================

  /// 计算连续打卡天数
  /// [checkInDates] 已打卡的日期字符串列表（需按日期升序排列）
  /// 返回从今天（或昨天）开始往回计算的连续打卡天数
  static int calculateStreak(List<String> checkInDates) {
    if (checkInDates.isEmpty) return 0;

    // 去重并排序
    final sortedDates = checkInDates.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    final today = getTodayString();
    final yesterday = getDaysBeforeToday(1);

    // 如果今天或昨天没有打卡，连续天数为0
    if (sortedDates.last != today && sortedDates.last != yesterday) {
      return 0;
    }

    int streak = 1;
    // 从最后一天开始往前遍历
    for (int i = sortedDates.length - 2; i >= 0; i--) {
      final current = parseDate(sortedDates[i + 1])!;
      final previous = parseDate(sortedDates[i])!;

      // 如果前一天的日期与当前日期相差1天，连续天数+1
      if (daysBetween(previous, current) == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// 计算最长连续打卡天数
  /// [checkInDates] 已打卡的日期字符串列表
  static int calculateLongestStreak(List<String> checkInDates) {
    if (checkInDates.isEmpty) return 0;

    // 去重并排序
    final sortedDates = checkInDates.toSet().toList()
      ..sort((a, b) => a.compareTo(b));

    int longestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final current = parseDate(sortedDates[i])!;
      final previous = parseDate(sortedDates[i - 1])!;

      if (daysBetween(previous, current) == 1) {
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return longestStreak;
  }

  // ============================================================
  // 日期范围
  // ============================================================

  /// 获取最近N天的日期字符串列表（包含今天）
  static List<String> getRecentDays(int days) {
    final result = <String>[];
    final today = DateTime.now();
    for (int i = days - 1; i >= 0; i--) {
      result.add(formatDate(today.subtract(Duration(days: i))));
    }
    return result;
  }

  /// 获取本周的日期字符串列表（周一到周日）
  static List<String> getCurrentWeekDays() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1=周一, 7=周日
    final monday = now.subtract(Duration(days: weekday - 1));

    return List.generate(7, (i) {
      return formatDate(monday.add(Duration(days: i)));
    });
  }

  /// 获取本月的日期字符串列表
  static List<String> getCurrentMonthDays() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDay.day;

    return List.generate(daysInMonth, (i) {
      return formatDate(firstDay.add(Duration(days: i)));
    });
  }

  // ============================================================
  // 星期相关
  // ============================================================

  /// 星期中文映射
  static const Map<int, String> weekdayChinese = {
    1: '周一',
    2: '周二',
    3: '周三',
    4: '周四',
    5: '周五',
    6: '周六',
    7: '周日',
  };

  /// 获取星期几的中文表示
  static String getWeekdayChinese(DateTime date) {
    return weekdayChinese[date.weekday] ?? '';
  }

  /// 获取星期几的中文表示（从日期字符串）
  static String getWeekdayChineseFromString(String dateStr) {
    final date = parseDate(dateStr);
    if (date == null) return '';
    return getWeekdayChinese(date);
  }
}
