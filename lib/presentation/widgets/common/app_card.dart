import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// 通用卡片组件
/// 支持圆角、阴影、可选点击效果，统一应用卡片风格
class AppCard extends StatelessWidget {
  /// 卡片子组件
  final Widget child;

  /// 点击回调，为 null 时不可点击
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 卡片内边距
  final EdgeInsetsGeometry? padding;

  /// 卡片外边距
  final EdgeInsetsGeometry? margin;

  /// 卡片圆角半径，默认使用主题值
  final double? borderRadius;

  /// 卡片背景色，为 null 时使用主题默认色
  final Color? color;

  /// 是否显示边框，默认为 true
  final bool showBorder;

  /// 边框颜色
  final Color? borderColor;

  /// 点击时的水波纹颜色
  final Color? splashColor;

  /// 是否显示阴影，默认为 false（简约风格）
  final bool showShadow;

  /// 阴影颜色
  final Color? shadowColor;

  /// 阴影模糊半径
  final double shadowBlurRadius;

  /// 阴影偏移量
  final Offset shadowOffset;

  /// 卡片高度
  final double? height;

  /// 卡片宽度
  final double? width;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.showBorder = true,
    this.borderColor,
    this.splashColor,
    this.showShadow = false,
    this.shadowColor,
    this.shadowBlurRadius = 8.0,
    this.shadowOffset = const Offset(0, 2),
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderRadius =
        borderRadius ?? AppTheme.borderRadius;
    final effectivePadding =
        padding ?? AppTheme.cardPadding;
    final effectiveMargin = margin ?? EdgeInsets.zero;

    // 构建卡片内容
    Widget cardContent = Padding(
      padding: effectivePadding,
      child: child,
    );

    // 如果可点击，包裹 InkWell
    if (onTap != null || onLongPress != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          splashColor: splashColor ??
              theme.colorScheme.primary.withOpacity(0.1),
          highlightColor: theme.colorScheme.primary.withOpacity(0.05),
          child: cardContent,
        ),
      );
    }

    // 构建卡片容器
    return Container(
      width: width,
      height: height,
      margin: effectiveMargin,
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: showBorder
            ? Border.all(
                color: borderColor ?? theme.colorScheme.outlineVariant,
                width: 1,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: shadowColor ??
                      (theme.brightness == Brightness.dark
                          ? const Color(0x33000000)
                          : const Color(0x0D000000)),
                  blurRadius: shadowBlurRadius,
                  offset: shadowOffset,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        child: cardContent,
      ),
    );
  }
}

/// 带图标的卡片组件
/// 在卡片左侧显示一个图标区域
class AppCardWithIcon extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 图标背景色
  final Color iconBackgroundColor;

  /// 图标颜色
  final Color? iconColor;

  /// 卡片标题
  final String? title;

  /// 卡片副标题
  final String? subtitle;

  /// 右侧尾部组件
  final Widget? trailing;

  /// 点击回调
  final VoidCallback? onTap;

  /// 卡片内边距
  final EdgeInsetsGeometry? padding;

  /// 卡片外边距
  final EdgeInsetsGeometry? margin;

  const AppCardWithIcon({
    super.key,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFFDCFCE7),
    this.iconColor,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: padding,
      margin: margin,
      child: Row(
        children: [
          // 图标区域
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.smallBorderRadius),
            ),
            child: Icon(
              icon,
              color: iconColor ?? theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // 文字区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.titleMedium,
                  ),
                if (subtitle != null) ...[
                  if (title != null) const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),

          // 尾部组件
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
