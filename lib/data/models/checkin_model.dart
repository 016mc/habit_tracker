import 'package:uuid/uuid.dart';

/// 打卡类型枚举
enum CheckInType {
  /// 正常打卡
  normal('normal', '正常打卡'),

  /// 补签
  backfill('backfill', '补签'),

  /// 自动打卡
  auto('auto', '自动打卡');

  const CheckInType(this.value, this.label);

  /// 存储值
  final String value;

  /// 中文标签
  final String label;

  /// 从字符串值创建枚举
  static CheckInType fromValue(String value) {
    return CheckInType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => CheckInType.normal,
    );
  }
}

/// 打卡记录数据模型
///
/// 表示一次习惯打卡记录，包含打卡时间、数量、备注等信息。
class CheckIn {
  CheckIn({
    String? id,
    required this.habitId,
    required this.userId,
    required this.date,
    DateTime? checkedAt,
    this.count = 1,
    this.note = '',
    this.type = CheckInType.normal,
    this.isBackfilled = false,
    DateTime? backfilledAt,
    this.synced = false,
  })  : id = id ?? const Uuid().v4(),
        checkedAt = checkedAt ?? DateTime.now(),
        backfilledAt = backfilledAt;

  // ============================================================
  // 基本属性
  // ============================================================

  /// 唯一标识
  final String id;

  /// 关联的习惯ID
  final String habitId;

  /// 用户ID
  final String userId;

  /// 打卡日期（yyyy-MM-dd格式字符串）
  final String date;

  /// 打卡时间
  final DateTime checkedAt;

  /// 打卡数量
  final int count;

  /// 备注
  final String note;

  /// 打卡类型
  final CheckInType type;

  /// 是否为补签记录
  final bool isBackfilled;

  /// 补签时间（null表示非补签）
  final DateTime? backfilledAt;

  /// 是否已同步到服务器
  final bool synced;

  // ============================================================
  // JSON 序列化
  // ============================================================

  /// 从JSON Map创建CheckIn对象
  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String?,
      habitId: json['habitId'] as String,
      userId: json['userId'] as String,
      date: json['date'] as String,
      checkedAt: json['checkedAt'] != null
          ? DateTime.parse(json['checkedAt'] as String)
          : DateTime.now(),
      count: json['count'] as int? ?? 1,
      note: json['note'] as String? ?? '',
      type: CheckInType.fromValue(json['type'] as String? ?? 'normal'),
      isBackfilled: json['isBackfilled'] as bool? ?? false,
      backfilledAt: json['backfilledAt'] != null
          ? DateTime.parse(json['backfilledAt'] as String)
          : null,
      synced: json['synced'] as bool? ?? false,
    );
  }

  /// 转换为JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'userId': userId,
      'date': date,
      'checkedAt': checkedAt.toIso8601String(),
      'count': count,
      'note': note,
      'type': type.value,
      'isBackfilled': isBackfilled,
      'backfilledAt': backfilledAt?.toIso8601String(),
      'synced': synced,
    };
  }

  // ============================================================
  // 复制方法
  // ============================================================

  /// 创建CheckIn的副本，可选择性地覆盖某些字段
  CheckIn copyWith({
    String? id,
    String? habitId,
    String? userId,
    String? date,
    DateTime? checkedAt,
    int? count,
    String? note,
    CheckInType? type,
    bool? isBackfilled,
    DateTime? backfilledAt,
    bool? synced,
    // 用于将字段设为null的标记
    bool clearBackfilledAt = false,
  }) {
    return CheckIn(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      checkedAt: checkedAt ?? this.checkedAt,
      count: count ?? this.count,
      note: note ?? this.note,
      type: type ?? this.type,
      isBackfilled: isBackfilled ?? this.isBackfilled,
      backfilledAt: clearBackfilledAt ? null : (backfilledAt ?? this.backfilledAt),
      synced: synced ?? this.synced,
    );
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  /// 标记为已同步
  CheckIn markAsSynced() {
    return copyWith(synced: true);
  }

  /// 标记为待同步
  CheckIn markAsPendingSync() {
    return copyWith(synced: false);
  }

  @override
  String toString() {
    return 'CheckIn(id: $id, habitId: $habitId, date: $date, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckIn && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
