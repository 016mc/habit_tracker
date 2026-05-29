import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/habit_model.dart';
import '../../../../data/models/checkin_model.dart';
import '../../../../presentation/widgets/common/app_card.dart';
import '../../../../presentation/widgets/animations/check_animation.dart';
import '../../../../presentation/widgets/animations/confetti_animation.dart';

/// 习惯卡片组件
/// 展示单个习惯的信息，支持打卡、长按菜单、左滑操作
class HabitCard extends StatefulWidget {
  /// 习惯数据
  final Habit habit;

  /// 今日已打卡次数
  final int todayCheckInCount;

  /// 打卡回调
  final VoidCallback? onCheckIn;

  /// 编辑回调
  final VoidCallback? onEdit;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 归档回调
  final VoidCallback? onArchive;

  /// 补打卡回调
  final VoidCallback? onBackfill;

  const HabitCard({
    super.key,
    required this.habit,
    this.todayCheckInCount = 0,
    this.onCheckIn,
    this.onEdit,
    this.onDelete,
    this.onArchive,
    this.onBackfill,
  });

  @override
  State<HabitCard> createState() => HabitCardState();
}

class HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  /// 是否正在展示打卡动画
  bool _showCheckAnimation = false;

  /// 是否正在展示撒花动画
  bool _showConfetti = false;

  /// 打卡按钮缩放动画控制器
  late AnimationController _tapController;
  late Animation<double> _tapScaleAnimation;

  /// 卡片是否已完成今日目标
  bool get _isCompleted =>
      widget.todayCheckInCount >= widget.habit.targetCount;

  /// 打卡进度（0.0 ~ 1.0）
  double get _progress {
    if (widget.habit.targetCount <= 0) return 0;
    final value = widget.todayCheckInCount / widget.habit.targetCount;
    return value.clamp(0.0, 1.0);
  }

  /// 获取习惯分类对应的颜色
  Color get _categoryColor {
    return AppColors.getCategoryColor(widget.habit.category.value);
  }

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _tapScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  /// 处理打卡操作
  void _handleCheckIn() {
    // 触发缩放动画
    _tapController.forward().then((_) => _tapController.reverse());

    // 如果已经完成今日目标，不再打卡
    if (_isCompleted) return;

    // 触发打卡回调
    widget.onCheckIn?.call();

    // 判断是否刚完成目标（打卡后次数等于目标次数）
    if (widget.todayCheckInCount + 1 >= widget.habit.targetCount) {
      // 完成目标，展示庆祝动画
      setState(() {
        _showCheckAnimation = true;
        _showConfetti = true;
      });

      // 动画结束后隐藏
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showCheckAnimation = false;
            _showConfetti = false;
          });
        }
      });
    } else {
      // 未完成目标，展示打卡成功动画
      setState(() {
        _showCheckAnimation = true;
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _showCheckAnimation = false;
          });
        }
      });
    }

    // 触觉反馈
    HapticFeedback.lightImpact();
  }

  /// 显示长按菜单
  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                // 拖动指示条
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // 编辑选项
                _buildMenuItem(
                  icon: Icons.edit_rounded,
                  label: '编辑习惯',
                  color: AppColors.info,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onEdit?.call();
                  },
                ),

                // 补打卡选项
                _buildMenuItem(
                  icon: Icons.history_rounded,
                  label: '补打卡',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onBackfill?.call();
                  },
                ),

                // 归档选项
                _buildMenuItem(
                  icon: Icons.archive_rounded,
                  label: '归档习惯',
                  color: AppColors.textSecondary,
                  onTap: () {
                    Navigator.pop(context);
                    widget.onArchive?.call();
                  },
                ),

                // 删除选项
                _buildMenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: '删除习惯',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context);
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 确认删除对话框
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除「${widget.habit.name}」吗？删除后数据将无法恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete?.call();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(widget.habit.id),
      // 左滑背景 - 编辑
      background: _buildSlideBackground(
        alignment: Alignment.centerLeft,
        icon: Icons.edit_rounded,
        label: '编辑',
        color: AppColors.info,
      ),
      // 右滑背景 - 删除
      secondaryBackground: _buildSlideBackground(
        alignment: Alignment.centerRight,
        icon: Icons.delete_outline_rounded,
        label: '删除',
        color: AppColors.error,
      ),
      // 左滑确认回调
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 左滑 -> 编辑
          widget.onEdit?.call();
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // 右滑 -> 删除
          widget.onDelete?.call();
          return false;
        }
        return false;
      },
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        onLongPress: () => _showContextMenu(context),
        child: Stack(
          children: [
            // 习惯卡片内容
            Row(
              children: [
                // 左侧：打卡按钮区域
                _buildCheckInButton(),

                const SizedBox(width: 14),

                // 中间：习惯信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 习惯名称 + 分类标签
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.habit.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: _isCompleted
                                    ? TextDecoration.none
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 分类颜色标识点
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _categoryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // 进度条
                      _buildProgressBar(),

                      const SizedBox(height: 4),

                      // 打卡计数文字
                      Text(
                        _isCompleted
                            ? '今日已完成'
                            : '${widget.todayCheckInCount} / ${widget.habit.targetCount} ${widget.habit.unit}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _isCompleted
                              ? AppColors.success
                              : AppColors.textHint,
                          fontWeight:
                              _isCompleted ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // 右侧：习惯图标
                _buildHabitIcon(),
              ],
            ),

            // 打卡成功对勾动画（叠加在卡片上方）
            if (_showCheckAnimation)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: CheckAnimation(
                    size: 80,
                    onComplete: () {
                      // 动画完成后由 _handleCheckIn 中的定时器控制隐藏
                    },
                  ),
                ),
              ),

            // 撒花庆祝动画（叠加在卡片上方）
            if (_showConfetti)
              ConfettiAnimation(
                isPlaying: _showConfetti,
                durationMs: 1500,
                confettiCount: 30,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建打卡按钮
  Widget _buildCheckInButton() {
    return GestureDetector(
      onTap: _handleCheckIn,
      child: AnimatedBuilder(
        animation: _tapController,
        builder: (context, child) {
          return Transform.scale(
            scale: _tapScaleAnimation.value,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isCompleted
                    ? AppColors.success.withOpacity(0.12)
                    : _categoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isCompleted
                      ? AppColors.success
                      : _categoryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: _isCompleted
                  ? Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 24,
                    )
                  : Icon(
                      Icons.add_rounded,
                      color: _categoryColor,
                      size: 24,
                    ),
            ),
          );
        },
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 4,
        child: Stack(
          children: [
            // 背景轨道
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // 进度填充
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: double.infinity * _progress,
              decoration: BoxDecoration(
                color: _isCompleted ? AppColors.success : _categoryColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建习惯图标
  Widget _buildHabitIcon() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getIconData(widget.habit.iconName),
        color: _categoryColor,
        size: 20,
      ),
    );
  }

  /// 构建滑动操作背景
  Widget _buildSlideBackground({
    required Alignment alignment,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alignment == Alignment.centerLeft) ...[
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ],
          if (alignment == Alignment.centerRight) ...[
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: color),
          ],
        ],
      ),
    );
  }

  /// 根据图标名称获取对应的 IconData
  IconData _getIconData(String iconName) {
    // 常用图标映射
    const iconMap = {
      'circle': Icons.circle_rounded,
      'star': Icons.star_rounded,
      'favorite': Icons.favorite_rounded,
      'thumb_up': Icons.thumb_up_rounded,
      'emoji_events': Icons.emoji_events_rounded,
      'local_fire_department': Icons.local_fire_department_rounded,
      'menu_book': Icons.menu_book_rounded,
      'school': Icons.school_rounded,
      'lightbulb': Icons.lightbulb_rounded,
      'create': Icons.create_rounded,
      'translate': Icons.translate_rounded,
      'code': Icons.code_rounded,
      'fitness_center': Icons.fitness_center_rounded,
      'directions_run': Icons.directions_run_rounded,
      'self_improvement': Icons.self_improvement_rounded,
      'water_drop': Icons.water_drop_rounded,
      'medication': Icons.medication_rounded,
      'monitor_heart': Icons.monitor_heart_rounded,
      'coffee': Icons.coffee_rounded,
      'bedtime': Icons.bedtime_rounded,
      'restaurant': Icons.restaurant_rounded,
      'cleaning_services': Icons.cleaning_services_rounded,
      'music_note': Icons.music_note_rounded,
      'palette': Icons.palette_rounded,
      'sports_esports': Icons.sports_esports_rounded,
      'camera_alt': Icons.camera_alt_rounded,
      'pets': Icons.pets_rounded,
      'nature': Icons.nature_rounded,
    };
    return iconMap[iconName] ?? Icons.circle_rounded;
  }
}
