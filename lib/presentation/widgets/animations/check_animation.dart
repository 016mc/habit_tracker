import 'package:flutter/material.dart';

/// 打卡成功对勾动画组件
/// 使用 AnimatedBuilder 实现绿色对勾 + 缩放弹跳效果
/// 打卡成功时展示，给予用户正向反馈
class CheckAnimation extends StatefulWidget {
  /// 动画尺寸
  final double size;

  /// 对勾颜色，默认绿色
  final Color? color;

  /// 背景圆圈颜色
  final Color? backgroundColor;

  /// 动画完成回调
  final VoidCallback? onComplete;

  /// 是否自动播放动画
  final bool autoPlay;

  /// 动画持续时间（毫秒）
  final int durationMs;

  const CheckAnimation({
    super.key,
    this.size = 80.0,
    this.color,
    this.backgroundColor,
    this.onComplete,
    this.autoPlay = true,
    this.durationMs = 1200,
  });

  @override
  State<CheckAnimation> createState() => CheckAnimationState();
}

class CheckAnimationState extends State<CheckAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 缩放弹跳动画（0 -> 1.2 -> 1.0）
  late Animation<double> _scaleAnimation;

  // 背景圆圈缩放动画
  late Animation<double> _circleScaleAnimation;

  // 背景圆圈透明度动画
  late Animation<double> _circleOpacityAnimation;

  // 对勾绘制进度动画（0 -> 1）
  late Animation<double> _checkProgressAnimation;

  // 对勾透明度动画
  late Animation<double> _checkOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    // 阶段一：背景圆圈出现（0% - 40%）
    _circleScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _circleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // 阶段二：对勾绘制（30% - 70%）
    _checkProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
      ),
    );

    _checkOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.4, curve: Curves.easeOut),
      ),
    );

    // 阶段三：整体弹跳效果（60% - 100%）
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.95),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 播放动画
  void play() {
    _controller.reset();
    _controller.forward();
  }

  /// 重置动画
  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? const Color(0xFF22C55E);
    final effectiveBgColor =
        widget.backgroundColor ?? effectiveColor.withOpacity(0.1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_scaleAnimation.value - 1.0),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 背景圆圈
                Transform.scale(
                  scale: _circleScaleAnimation.value,
                  child: Opacity(
                    opacity: _circleOpacityAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: effectiveBgColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // 对勾路径
                CustomPaint(
                  size: Size(widget.size * 0.5, widget.size * 0.5),
                  painter: _CheckMarkPainter(
                    progress: _checkProgressAnimation.value,
                    color: effectiveColor,
                    strokeWidth: widget.size * 0.06,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 对勾路径绘制器
class _CheckMarkPainter extends CustomPainter {
  /// 绘制进度（0.0 - 1.0）
  final double progress;

  /// 对勾颜色
  final Color color;

  /// 线条宽度
  final double strokeWidth;

  _CheckMarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // 对勾路径：从左下到中间，再到右上
    final startX = size.width * 0.1;
    final startY = size.height * 0.55;
    final midX = size.width * 0.4;
    final midY = size.height * 0.85;
    final endX = size.width * 0.9;
    final endY = size.height * 0.2;

    path.moveTo(startX, startY);
    path.lineTo(midX, midY);
    path.lineTo(endX, endY);

    // 计算路径总长度用于裁剪
    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return;

    final totalLength = metrics.first.length;
    final extractLength = totalLength * progress;

    // 使用 PathMetric 提取部分路径
    final extractedPath = metrics.first.extractPath(
      0,
      extractLength,
    );

    canvas.drawPath(extractedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckMarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
