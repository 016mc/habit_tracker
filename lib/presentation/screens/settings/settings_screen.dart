import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../presentation/theme/app_theme.dart';
import '../../widgets/common/app_card.dart';
import 'widgets/theme_selector.dart';

/// 设置页面
///
/// 提供应用设置功能，包括：
/// - 主题切换（浅色/深色/跟随系统）
/// - 数据管理（导出/清除数据）
/// - 关于信息
/// 采用简约列表设计风格。
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        padding: AppTheme.pagePadding.add(
          const EdgeInsets.only(bottom: 24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 外观设置
            _buildSectionTitle(context, '外观'),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 主题模式标签
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '主题模式',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 主题选择器
                  const ThemeSelector(),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // 数据管理
            _buildSectionTitle(context, '数据管理'),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
                    icon: Icons.download_outlined,
                    iconColor: AppColors.learning,
                    title: '导出数据',
                    subtitle: '将所有习惯和打卡记录导出为JSON文件',
                    onTap: _onExportData,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsItem(
                    context,
                    icon: Icons.delete_outline,
                    iconColor: AppColors.error,
                    title: '清除所有数据',
                    subtitle: '删除所有习惯和打卡记录，此操作不可恢复',
                    onTap: _onClearData,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // 关于
            _buildSectionTitle(context, '关于'),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildSettingsItem(
                    context,
                    icon: Icons.info_outline,
                    iconColor: AppColors.info,
                    title: '版本',
                    subtitle: 'v1.0.0',
                    trailing: null,
                  ),
                  const Divider(height: 1, indent: 56),
                  _buildSettingsItem(
                    context,
                    icon: Icons.code_outlined,
                    iconColor: AppColors.gaming,
                    title: '开源许可',
                    subtitle: '查看使用的开源库许可证',
                    onTap: _onOpenLicenses,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 构建设置项
  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 图标
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),

              // 文字信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // 尾部组件
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ] else if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 导出数据回调
  void _onExportData() {
    // TODO: 实现数据导出逻辑
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据导出功能开发中')),
    );
  }

  /// 清除数据回调
  void _onClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除数据'),
        content: const Text(
          '此操作将删除所有习惯和打卡记录，且不可恢复。\n\n确定要继续吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现数据清除逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清除')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }

  /// 打开开源许可页面
  void _onOpenLicenses() {
    showLicensePage(
      context: context,
      applicationName: '习惯追踪',
      applicationVersion: 'v1.0.0',
    );
  }
}
