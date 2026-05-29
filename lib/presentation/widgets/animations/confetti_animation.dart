import 'dart:math';
import 'package:flutter/material.dart';

/// 庆祝动画组件 - 撒花效果
/// 使用自定义粒子系统实现五彩纸屑飘落效果
/// 用于达成目标、连续打卡里程碑等庆祝场景
class ConfettiAnimation extends StatefulWidget {
  /// 是否正在播放
  final bool isPlaying;

  /// 动画持续时间（毫秒），默认 3 秒
  final int durationMs;

  /// 纸屑数量
  final int confettiCount;

  /// 纸屑颜色列表，为 null 时使用默认彩虹色
  final List<Color>? colors;

  /// 动画完成回调
  final VoidCallback? onComplete;

  const ConfettiAnimation({
    super.key,
    this.isPlaying = false,
    this.durationMs = 3000,
    this.confettiCount = 50,
    this.colors,
    this.onComplete,
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_ConfettiParticle>? _particles;
  final _random = Random();

  /// 默认彩虹色纸屑颜色
  static const List<Color> _defaultColors = [
    Color(0xFFFF6B6B), // 红色
    Color(0xFFFFD93D), // 黄色
    Color(0xFF6BCB77), // 绿色
    Color(0xFF4D96FF), // 蓝色
    Color(0xFFFF922B), // 橙色
    Color(0xFFCC5DE8), // 紫色
    Color(0xFF20C997), // 青色
    Color(0xFFFF6B9D), // 粉色
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    if (widget.isPlaying) {
      _startConfetti();
    }
  }

  @override
  void didUpdateWidget(ConfettiAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    }
  }

  /// 开始撒花动画
  void _startConfetti() {
    _particles = _generateParticles();
    _controller.reset();
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  /// 生成纸屑粒子
  List<_ConfettiParticle> _generateParticles() {
    final effectiveColors = widget.colors ?? _defaultColors;
    return List.generate(widget.confettiCount, (index) {
      return _ConfettiParticle(
        // 从屏幕顶部不同水平位置开始
        startX: _random.nextDouble(),
        startY: -_random.nextDouble() * 0.1,
        // 下落速度
        fallSpeed: _random.nextDouble() * 0.4 + 0.3,
        // 水平漂移速度
        driftSpeed: (_random.nextDouble() - 0.5) * 0.3,
        // 摆动参数
        swayAmplitude: _random.nextDouble() * 0.1 + 0.05,
        swayFrequency: _random.nextDouble() * 6 + 3,
        swayPhase: _random.nextDouble() * 2 * pi,
        // 旋转参数
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
        initialRotation: _random.nextDouble() * 2 * pi,
        // 纸屑大小
        width: _random.nextDouble() * 8 + 6,
        height: _random.nextDouble() * 4 + 3,
        // 颜色
        color: effectiveColors[_random.nextInt(effectiveColors.length)],
        // 出现延迟
        delay: _random.nextDouble() * 0.3,
        // 纸屑形状
        shape: _random.nextDouble() > 0.5
            ? _ConfettiShape.rectangle
            : _ConfettiShape.circle,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_particles == null || !widget.isPlaying) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox.expand(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles!,
                progress: _controller.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 纸屑粒子数据
class _ConfettiParticle {
  /// 起始 X 位置（0.0 - 1.0，相对于屏幕宽度）
  final double startX;

  /// 起始 Y 位置（0.0 - 1.0，相对于屏幕高度）
  final double startY;

  /// 下落速度
  final double fallSpeed;

  /// 水平漂移速度
  final double driftSpeed;

  /// 摆动幅度
  final double swayAmplitude;

  /// 摆动频率
  final double swayFrequency;

  /// 摆动相位
  final double swayPhase;

  /// 旋转速度（弧度/秒）
  final double rotationSpeed;

  /// 初始旋转角度
  final double initialRotation;

  /// 纸屑宽度
  final double width;

  /// 纸屑高度
  final double height;

  /// 纸屑颜色
  final Color color;

  /// 出现延迟（0.0 - 1.0）
  final double delay;

  /// 纸屑形状
  final _ConfettiShape shape;

  _ConfettiParticle({
    required this.startX,
    required this.startY,
    required this.fallSpeed,
    required this.driftSpeed,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.swayPhase,
    required this.rotationSpeed,
    required this.initialRotation,
    required this.width,
    required this.height,
    required this.color,
    required this.delay,
    required this.shape,
  });
}

/// 纸屑形状
enum _ConfettiShape {
  /// 矩形
  rectangle,

  /// 圆形
  circle,
}

/// 纸屑绘制器
class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // 计算粒子当前进度（考虑延迟）
      final adjustedProgress = (progress - particle.delay) / (1.0 - particle.delay);
      if (adjustedProgress < 0 || adjustedProgress > 1) continue;

      // 使用缓动函数让下落更自然
      final easedProgress = _easeOutQuad(adjustedProgress);

      // 计算当前位置
      final x = particle.startX * size.width +
          particle.driftSpeed * size.width * easedProgress +
          sin(easedProgress * particle.swayFrequency * pi + particle.swayPhase) *
              particle.swayAmplitude *
              size.width;

      final y = particle.startY * size.height +
          particle.fallSpeed * size.height * easedProgress;

      // 计算旋转角度
      final rotation = particle.initialRotation +
          particle.rotationSpeed * easedProgress * pi;

      // 计算透明度（最后 20% 淡出）
      final opacity = adjustedProgress > 0.8
          ? (1.0 - adjustedProgress) / 0.2
          : 1.0;

      // 绘制纸屑
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity);

      switch (particle.shape) {
        case _ConfettiShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.width,
              height: particle.height,
            ),
            paint,
          );
          break;
        case _ConfettiShape.circle:
          canvas.drawCircle(
            Offset.zero,
            particle.width / 2,
            paint,
          );
          break;
      }

      canvas.restore();
    }
  }

  /// 缓出二次方缓动函数
  double _easeOutQuad(double t) {
    return t * (2 - t);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
