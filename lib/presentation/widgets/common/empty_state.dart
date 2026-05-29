import 'package:flutter/material.dart';

/// 空状态占位组件
/// 当列表或页面没有数据时展示友好的空状态提示
class EmptyState extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 图标颜色，为 null 时使用主题次要文字色
  final Color? iconColor;

  /// 图标大小
  final double iconSize;

  /// 标题文字
  final String title;

  /// 描述文字
  final String? message;

  /// 主操作按钮文字
  final String? actionText;

  /// 主操作按钮回调
  final VoidCallback? onAction;

  /// 次要操作按钮文字
  final String? secondaryActionText;

  /// 次要操作按钮回调
  final VoidCallback? onSecondaryAction;

  /// 自定义图标组件（优先于 icon 参数）
  final Widget? customIcon;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.iconSize = 64.0,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.customIcon,
  });

  /// 创建习惯列表空状态
  factory EmptyState.noHabits({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.checklist_rtl_rounded,
      title: '还没有习惯',
      message: '点击下方按钮添加你的第一个习惯，开始养成好习惯吧！',
      actionText: '添加习惯',
      onAction: onAction,
    );
  }

  /// 创建打卡记录空状态
  factory EmptyState.noCheckIns({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.event_available_rounded,
      title: '今天还没有打卡',
      message: '坚持打卡，养成好习惯！',
      actionText: '去打卡',
      onAction: onAction,
    );
  }

  /// 创建统计数据空状态
  factory EmptyState.noStatistics() {
    return EmptyState(
      icon: Icons.bar_chart_rounded,
      title: '暂无统计数据',
      message: '开始打卡后，这里将展示你的习惯统计数据',
    );
  }

  /// 创建搜索结果空状态
  factory EmptyState.noSearchResults({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.search_off_rounded,
      title: '未找到结果',
      message: '尝试更换关键词搜索',
      actionText: '清除搜索',
      onAction: onAction,
    );
  }

  /// 创建网络错误空状态
  factory EmptyState.networkError({VoidCallback? onAction}) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: '网络连接失败',
      message: '请检查网络设置后重试',
      actionText: '重试',
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor =
        iconColor ?? theme.colorScheme.onSurfaceVariant.withOpacity(0.5);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标区域
            _buildIcon(effectiveIconColor),
            const SizedBox(height: 24),

            // 标题
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // 描述文字
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 操作按钮
            if (actionText != null) ...[
              const SizedBox(height: 24),
              _buildActionButton(theme),
            ],

            // 次要操作按钮
            if (secondaryActionText != null) ...[
              const SizedBox(height: 12),
              _buildSecondaryActionButton(theme),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建图标
  Widget _buildIcon(Color iconColor) {
    if (customIcon != null) {
      return customIcon!;
    }
    return Icon(
      icon,
      size: iconSize,
      color: iconColor,
    );
  }

  /// 构建主操作按钮
  Widget _buildActionButton(ThemeData theme) {
    return SizedBox(
      width: 160,
      height: 44,
      child: ElevatedButton(
        onPressed: onAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          actionText!,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 构建次要操作按钮
  Widget _buildSecondaryActionButton(ThemeData theme) {
    return SizedBox(
      width: 160,
      height: 44,
      child: TextButton(
        onPressed: onSecondaryAction,
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          secondaryActionText!,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
