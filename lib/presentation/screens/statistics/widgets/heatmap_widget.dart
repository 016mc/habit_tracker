import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// GitHub风格热力图组件
///
/// 展示过去一年的打卡数据，颜色深浅表示完成度。
/// 底部包含 Less-More 图例和月份标签。
class HeatmapWidget extends StatelessWidget {
  /// 热力图数据
  /// key: 日期字符串（yyyy-MM-dd），value: 当天打卡次数
  final Map<String, int> heatmapData;

  /// 单个方块的尺寸
  final double cellSize;

  /// 方块之间的间距
  final double cellSpacing;

  const HeatmapWidget({
    super.key,
    required this.heatmapData,
    this.cellSize = 14.0,
    this.cellSpacing = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // 计算过去一年的起始日期（从今天往前推365天，对齐到周日）
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(const Duration(days: 364));
    // 对齐到周日（weekday 7 = 周日）
    final alignedStart = startDate.subtract(
      Duration(days: startDate.weekday % 7),
    );

    // 生成周数据列表
    final weeks = _generateWeeks(alignedStart, today);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 月份标签
          _buildMonthLabels(weeks, theme),
          const SizedBox(height: 6),

          // 热力图主体
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 星期标签
              _buildDayLabels(theme),
              SizedBox(width: cellSpacing),

              // 热力图网格
              ...weeks.map((week) => _buildWeekColumn(week, theme)),
            ],
          ),
          const SizedBox(height: 8),

          // Less-More 图例
          _buildLegend(theme),
        ],
      ),
    );
  }

  /// 生成周数据列表
  List<List<DateTime?>> _generateWeeks(DateTime start, DateTime end) {
    final weeks = <List<DateTime?>>[];
    var current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final week = <DateTime?>[];
      for (int i = 0; i < 7; i++) {
        if (current.isAfter(end)) {
          week.add(null);
        } else {
          week.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
      weeks.add(week);
    }

    return weeks;
  }

  /// 构建月份标签
  Widget _buildMonthLabels(List<List<DateTime?>> weeks, ThemeData theme) {
    final monthLabels = <Widget>[];
    // 星期标签占位宽度
    final dayLabelWidth = 24.0;
    monthLabels.add(SizedBox(width: dayLabelWidth + cellSpacing));

    String? lastMonth;
    int weekIndex = 0;

    for (final week in weeks) {
      // 取该周第一个有效日期
      final firstDay = week.cast<DateTime?>().firstWhere(
            (d) => d != null,
            orElse: () => null,
          );

      if (firstDay != null) {
        final monthName = _getMonthName(firstDay.month);
        if (monthName != lastMonth) {
          monthLabels.add(
            SizedBox(
              width: (cellSize + cellSpacing) * _weeksInMonth(weeks, firstDay.month, firstDay.year),
              child: Text(
                monthName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
          );
          lastMonth = monthName;
        } else {
          // 同月份，占位
          monthLabels.add(SizedBox(width: cellSize + cellSpacing));
        }
      } else {
        monthLabels.add(SizedBox(width: cellSize + cellSpacing));
      }
      weekIndex++;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: monthLabels,
    );
  }

  /// 计算某月在热力图中占几周
  int _weeksInMonth(List<List<DateTime?>> weeks, int month, int year) {
    int count = 0;
    for (final week in weeks) {
      for (final day in week) {
        if (day != null && day.month == month && day.year == year) {
          count++;
          break;
        }
      }
    }
    return count;
  }

  /// 构建星期标签（左侧）
  Widget _buildDayLabels(ThemeData theme) {
    final dayNames = ['', '一', '', '三', '', '五', ''];
    return Column(
      children: dayNames.map((name) {
        return SizedBox(
          height: cellSize,
          width: 24.0,
          child: name.isEmpty
              ? null
              : Center(
                  child: Text(
                    name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
        );
      }).toList(),
    );
  }

  /// 构建单周列
  Widget _buildWeekColumn(List<DateTime?> week, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(right: cellSpacing),
      child: Column(
        children: week.map((day) {
          if (day == null) {
            // 超出范围的日期，显示空白
            return SizedBox(
              width: cellSize,
              height: cellSize,
            );
          }

          final dateKey = _formatDate(day);
          final count = heatmapData[dateKey] ?? 0;
          final color = _getHeatmapColor(count);

          return Container(
            width: cellSize,
            height: cellSize,
            margin: EdgeInsets.only(bottom: cellSpacing),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建底部 Less-More 图例
  Widget _buildLegend(ThemeData theme) {
    // 星期标签占位宽度
    final dayLabelWidth = 24.0;
    return Row(
      children: [
        SizedBox(width: dayLabelWidth + cellSpacing),
        Text(
          '少',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 4),
        ...AppColors.heatmapColors.map((color) {
          return Container(
            width: cellSize,
            height: cellSize,
            margin: EdgeInsets.only(right: cellSpacing),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 2),
        Text(
          '多',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// 根据打卡次数获取对应颜色
  Color _getHeatmapColor(int count) {
    if (count <= 0) return AppColors.heatmapColors[0];
    if (count == 1) return AppColors.heatmapColors[1];
    if (count == 2) return AppColors.heatmapColors[2];
    if (count == 3) return AppColors.heatmapColors[3];
    return AppColors.heatmapColors[4];
  }

  /// 格式化日期为 yyyy-MM-dd
  String _formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 获取月份名称
  String _getMonthName(int month) {
    const names = ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
    return names[month - 1];
  }
}
