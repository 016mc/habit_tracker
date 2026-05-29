import 'package:uuid/uuid.dart';

/// 习惯分类枚举
enum HabitCategory {
  /// 补充剂
  supplement('supplement', '补充剂'),

  /// 学习
  learning('learning', '学习'),

  /// 游戏
  gaming('gaming', '游戏'),

  /// 运动
  exercise('exercise', '运动'),

  /// 自定义
  custom('custom', '自定义');

  const HabitCategory(this.value, this.label);

  /// 存储值
  final String value;

  /// 中文标签
  final String label;

  /// 从字符串值创建枚举
  static HabitCategory fromValue(String value) {
    return HabitCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HabitCategory.custom,
    );
  }
}

/// 习惯频率枚举
enum HabitFrequency {
  /// 每天
  daily('daily', '每天'),

  /// 每周
  weekly('weekly', '每周'),

  /// 指定天数
  specificDays('specificDays', '指定天数');

  const HabitFrequency(this.value, this.label);

  /// 存储值
  final String value;

  /// 中文标签
  final String label;

  /// 从字符串值创建枚举
  static HabitFrequency fromValue(String value) {
    return HabitFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => HabitFrequency.daily,
    );
  }
}

/// 习惯数据模型
///
/// 表示一个用户创建的习惯，包含习惯的基本信息、分类、频率、目标等。
class Habit {
  Habit({
    String? id,
    required this.userId,
    required this.name,
    this.description = '',
    this.category = HabitCategory.custom,
    this.iconName = 'circle',
    this.colorValue = 0xFF6B7280,
    this.frequency = HabitFrequency.daily,
    List<int>? specificDays,
    this.targetCount = 1,
    this.targetValue = 1.0,
    this.unit = '次',
    List<String>? reminderTimes,
    this.goalStreakDays = 30,
    this.sortOrder = 0,
    DateTime? createdAt,
    this.archivedAt,
    this.isDeleted = false,
  })  : id = id ?? const Uuid().v4(),
        specificDays = specificDays ?? [],
        reminderTimes = reminderTimes ?? [],
        createdAt = createdAt ?? DateTime.now();

  // ============================================================
  // 基本属性
  // ============================================================

  /// 唯一标识
  final String id;

  /// 用户ID
  final String userId;

  /// 习惯名称
  final String name;

  /// 习惯描述
  final String description;

  /// 习惯分类
  final HabitCategory category;

  /// 图标名称
  final String iconName;

  /// 颜色值（ARGB int）
  final int colorValue;

  /// 习惯频率
  final HabitFrequency frequency;

  /// 指定打卡的星期几（1=周一, 7=周日），仅在frequency为specificDays时有效
  final List<int> specificDays;

  /// 每次打卡的目标数量
  final int targetCount;

  /// 目标值（如跑步公里数、喝水杯数等）
  final double targetValue;

  /// 单位（如"公里"、"杯"、"次"等）
  final String unit;

  /// 提醒时间列表（格式：HH:mm）
  final List<String> reminderTimes;

  /// 目标连续打卡天数
  final int goalStreakDays;

  /// 排序顺序（越小越靠前）
  final int sortOrder;

  /// 创建时间
  final DateTime createdAt;

  /// 归档时间（null表示未归档）
  final DateTime? archivedAt;

  /// 是否已删除（软删除标记）
  final bool isDeleted;

  // ============================================================
  // JSON 序列化
  // ============================================================

  /// 从JSON Map创建Habit对象
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: HabitCategory.fromValue(json['category'] as String? ?? 'custom'),
      iconName: json['iconName'] as String? ?? 'circle',
      colorValue: json['colorValue'] as int? ?? 0xFF6B7280,
      frequency: HabitFrequency.fromValue(json['frequency'] as String? ?? 'daily'),
      specificDays: (json['specificDays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      targetCount: json['targetCount'] as int? ?? 1,
      targetValue: (json['targetValue'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] as String? ?? '次',
      reminderTimes: (json['reminderTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      goalStreakDays: json['goalStreakDays'] as int? ?? 30,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  /// 转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'category': category.value,
      'iconName': iconName,
      'colorValue': colorValue,
      'frequency': frequency.value,
      'specificDays': specificDays,
      'targetCount': targetCount,
      'targetValue': targetValue,
      'unit': unit,
      'reminderTimes': reminderTimes,
      'goalStreakDays': goalStreakDays,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'archivedAt': archivedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  // ============================================================
  // 复制方法
  // ============================================================

  /// 创建Habit的副本，可选择性地覆盖某些字段
  Habit copyWith({
    String? id,
    String? userId,
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
    DateTime? createdAt,
    DateTime? archivedAt,
    bool? isDeleted,
    // 用于将字段设为null的标记
    bool clearArchivedAt = false,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      frequency: frequency ?? this.frequency,
      specificDays: specificDays ?? this.specificDays,
      targetCount: targetCount ?? this.targetCount,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      goalStreakDays: goalStreakDays ?? this.goalStreakDays,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 是否已归档
  bool get isArchived => archivedAt != null;

  /// 是否为活跃状态（未删除且未归档）
  bool get isActive => !isDeleted && !isArchived;

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, category: ${category.label})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
