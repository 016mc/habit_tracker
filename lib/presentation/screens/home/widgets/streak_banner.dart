import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 连续打卡横幅组件
/// 显示当前最长连续打卡天数，带火焰图标动画效果
class StreakBanner extends StatefulWidget {
  /// 当前连续打卡天数
  final int streakDays;

  /// 最长连续打卡天数
  final int bestStreakDays;

  /// 点击回调（可跳转到统计页面）
  final VoidCallback? onTap;

  const StreakBanner({
    super.key,
    required this.streakDays,
    this.bestStreakDays = 0,
    this.onTap,
  });

  @override
  State<StreakBanner> createState() => _StreakBannerState();
}

class _StreakBannerState extends State<StreakBanner>
    with SingleTickerProviderStateMixin {
  /// 火焰图标缩放动画控制器
  late AnimationController _fireController;

  /// 火焰图标缩放动画
  late Animation<double> _fireScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 火焰呼吸式缩放动画：1.0 -> 1.2 -> 1.0 循环
    _fireScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_fireController);

    // 循环播放
    _fireController.repeat();
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  /// 根据连续天数获取对应的激励文案
  String _getStreakMessage(int days) {
    if (days == 0) return '开始你的打卡之旅吧';
    if (days < 3) return '刚刚起步，继续加油';
    if (days < 7) return '坚持就是胜利';
    if (days < 14) return '你已经坚持了一周';
    if (days < 30) return '太棒了，继续保持';
    if (days < 60) return '习惯正在养成中';
    if (days < 100) return '你的毅力令人敬佩';
    return '传奇打卡者';
  }

  /// 根据连续天数获取火焰颜色
  Color _getFireColor(int days) {
    if (days == 0) return const Color(0xFF94A3B8);
    if (days < 7) return const Color(0xFFF59E0B);
    if (days < 14) return const Color(0xFFF97316);
    if (days < 30) return const Color(0xFFEF4444);
    return const Color(0xFFDC2626);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fireColor = _getFireColor(widget.streakDays);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.08),
              AppColors.primaryDark.withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 火焰图标（带动画）
            AnimatedBuilder(
              animation: _fireController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fireScaleAnimation.value,
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: fireColor,
                    size: 32,
                  ),
                );
              },
            ),
            const SizedBox(width: 14),

            // 连续打卡信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 连续天数
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${widget.streakDays}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '天连续打卡',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // 激励文案
                  Text(
                    _getStreakMessage(widget.streakDays),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            // 最长记录（如果有）
            if (widget.bestStreakDays > 0) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '最长记录',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 14,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.bestStreakDays}天',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
