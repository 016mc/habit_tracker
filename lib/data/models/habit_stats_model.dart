/// 习惯统计数据模型
///
/// 表示一个习惯的统计信息，包括连续打卡天数、完成率、热力图数据等。
class HabitStats {
  HabitStats({
    required this.habitId,
    required this.userId,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCheckIns = 0,
    this.totalDays = 0,
    this.completionRate = 0.0,
    List<bool>? last7Days,
    Map<String, int>? heatmapData,
    DateTime? lastUpdated,
  })  : last7Days = last7Days ?? List.filled(7, false),
        heatmapData = heatmapData ?? {},
        lastUpdated = lastUpdated ?? DateTime.now();

  // ============================================================
  // 基本属性
  // ============================================================

  /// 关联的习惯ID
  final String habitId;

  /// 用户ID
  final String userId;

  /// 当前连续打卡天数
  final int currentStreak;

  /// 历史最长连续打卡天数
  final int longestStreak;

  /// 总打卡次数
  final int totalCheckIns;

  /// 从创建到现在的总天数
  final int totalDays;

  /// 完成率（0.0 ~ 1.0）
  final double completionRate;

  /// 最近7天打卡情况（true=已打卡，false=未打卡）
  /// 索引0=7天前，索引6=今天
  final List<bool> last7Days;

  /// 热力图数据
  /// key: 日期字符串（yyyy-MM-dd），value: 当天打卡次数
  final Map<String, int> heatmapData;

  /// 最后更新时间
  final DateTime lastUpdated;

  // ============================================================
  // JSON 序列化
  // ============================================================

  /// 从JSON Map创建HabitStats对象
  factory HabitStats.fromJson(Map<String, dynamic> json) {
    return HabitStats(
      habitId: json['habitId'] as String,
      userId: json['userId'] as String,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      totalCheckIns: json['totalCheckIns'] as int? ?? 0,
      totalDays: json['totalDays'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      last7Days: (json['last7Days'] as List<dynamic>?)
              ?.map((e) => e as bool)
              .toList() ??
          List.filled(7, false),
      heatmapData: (json['heatmapData'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, value as int),
          ) ??
          {},
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// 转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'userId': userId,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalCheckIns': totalCheckIns,
      'totalDays': totalDays,
      'completionRate': completionRate,
      'last7Days': last7Days,
      'heatmapData': heatmapData,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // ============================================================
  // 复制方法
  // ============================================================

  /// 创建HabitStats的副本，可选择性地覆盖某些字段
  HabitStats copyWith({
    String? habitId,
    String? userId,
    int? currentStreak,
    int? longestStreak,
    int? totalCheckIns,
    int? totalDays,
    double? completionRate,
    List<bool>? last7Days,
    Map<String, int>? heatmapData,
    DateTime? lastUpdated,
  }) {
    return HabitStats(
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      totalDays: totalDays ?? this.totalDays,
      completionRate: completionRate ?? this.completionRate,
      last7Days: last7Days ?? this.last7Days,
      heatmapData: heatmapData ?? this.heatmapData,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 获取最近7天中已打卡的天数
  int get last7DaysCheckedCount {
    return last7Days.where((checked) => checked).length;
  }

  /// 获取最近7天的完成率
  double get last7DaysCompletionRate {
    if (last7Days.isEmpty) return 0.0;
    return last7DaysCheckedCount / last7Days.length;
  }

  /// 获取完成率百分比字符串
  String get completionRateString {
    return '${(completionRate * 100).toStringAsFixed(1)}%';
  }

  /// 更新热力图中某天的打卡次数
  /// 如果次数为0，则从热力图中移除该日期
  HabitStats updateHeatmapData(String date, int count) {
    final newHeatmap = Map<String, int>.from(heatmapData);
    if (count > 0) {
      newHeatmap[date] = count;
    } else {
      newHeatmap.remove(date);
    }
    return copyWith(
      heatmapData: newHeatmap,
      lastUpdated: DateTime.now(),
    );
  }

  /// 判断是否打破了最长连续记录
  bool get isNewLongestStreak => currentStreak > longestStreak;

  @override
  String toString() {
    return 'HabitStats(habitId: $habitId, currentStreak: $currentStreak, '
        'longestStreak: $longestStreak, completionRate: $completionRate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitStats && other.habitId == habitId;
  }

  @override
  int get hashCode => habitId.hashCode;
}
