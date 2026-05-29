import 'dart:math';
import 'package:flutter/material.dart';

/// 连续打卡火焰动画组件
/// 展示简单的火焰粒子效果，用于连续打卡天数展示
/// 火焰粒子从底部向上飘动，逐渐变小并消失
class StreakFireAnimation extends StatefulWidget {
  /// 动画尺寸（宽度和高度）
  final double size;

  /// 火焰颜色，默认橙红色渐变
  final Color? color;

  /// 粒子数量
  final int particleCount;

  /// 是否自动播放
  final bool autoPlay;

  const StreakFireAnimation({
    super.key,
    this.size = 60.0,
    this.color,
    this.particleCount = 12,
    this.autoPlay = true,
  });

  @override
  State<StreakFireAnimation> createState() => _StreakFireAnimationState();
}

class _StreakFireAnimationState extends State<StreakFireAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_FireParticle> _particles;

  /// 随机数生成器
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _initParticles();
  }

  /// 初始化粒子
  void _initParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return _FireParticle(
        // 错开每个粒子的起始时间，形成连续效果
        delay: index / widget.particleCount,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size * 1.2,
          child: CustomPaint(
            painter: _FireParticlePainter(
              particles: _particles,
              progress: _controller.value,
              baseColor: widget.color ?? const Color(0xFFF97316),
              size: widget.size,
            ),
          ),
        );
      },
    );
  }
}

/// 火焰粒子数据
class _FireParticle {
  /// 粒子延迟（0.0 - 1.0），控制粒子出现的时间
  final double delay;

  /// 粒子水平偏移（-1.0 - 1.0），相对于中心位置
  final double xOffset;

  /// 粒子最大尺寸
  final double maxSize;

  /// 粒子生命周期（0.0 - 1.0），控制粒子存在时长
  final double lifetime;

  /// 粒子摆动幅度
  final double swayAmount;

  /// 粒子摆动速度
  final double swaySpeed;

  _FireParticle({
    required this.delay,
    double? xOffset,
    double? maxSize,
    double? lifetime,
    double? swayAmount,
    double? swaySpeed,
  })  : xOffset = xOffset ?? (Random().nextDouble() * 0.6 - 0.3),
        maxSize = maxSize ?? Random().nextDouble() * 0.3 + 0.15,
        lifetime = lifetime ?? Random().nextDouble() * 0.3 + 0.5,
        swayAmount = swayAmount ?? Random().nextDouble() * 0.2 + 0.1,
        swaySpeed = swaySpeed ?? Random().nextDouble() * 4 + 2;
}

/// 火焰粒子绘制器
class _FireParticlePainter extends CustomPainter {
  final List<_FireParticle> particles;
  final double progress;
  final Color baseColor;
  final double size;

  _FireParticlePainter({
    required this.particles,
    required this.progress,
    required this.baseColor,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height * 0.75);

    for (final particle in particles) {
      // 计算粒子当前生命进度
      final particleProgress = _getParticleProgress(progress, particle);
      if (particleProgress < 0 || particleProgress > 1) continue;

      // 计算粒子位置
      final normalizedProgress = particleProgress / particle.lifetime;
      final y = center.dy - normalizedProgress * size * 0.8;

      // 水平摆动
      final sway = sin(normalizedProgress * particle.swaySpeed * pi) *
          particle.swayAmount *
          size *
          0.5;
      final x = center.dx + particle.xOffset * size * 0.3 + sway;

      // 粒子大小随生命周期变化（先增大后缩小）
      final sizeProgress = normalizedProgress;
      double particleSize;
      if (sizeProgress < 0.2) {
        // 增大阶段
        particleSize = particle.maxSize * size * (sizeProgress / 0.2);
      } else {
        // 缩小阶段
        particleSize = particle.maxSize *
            size *
            (1.0 - (sizeProgress - 0.2) / 0.8);
      }
      particleSize = particleSize.clamp(0.5, size * 0.4);

      // 透明度随生命周期变化
      final opacity = normalizedProgress < 0.1
          ? normalizedProgress / 0.1
          : (1.0 - normalizedProgress).clamp(0.0, 1.0) * 0.8;

      // 颜色从黄色（底部）渐变到红色（顶部）
      final colorProgress = normalizedProgress;
      final color = Color.lerp(
        const Color(0xFFFDE047), // 黄色
        baseColor, // 橙红色
        colorProgress.clamp(0.0, 1.0),
      )!.withOpacity(opacity);

      // 绘制粒子（带模糊效果的圆形）
      final paint = Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(
        Offset(x, y),
        particleSize,
        paint,
      );

      // 绘制粒子核心（更亮的小圆）
      if (normalizedProgress < 0.5) {
        final corePaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        canvas.drawCircle(
          Offset(x, y),
          particleSize * 0.4,
          corePaint,
        );
      }
    }
  }

  /// 计算粒子当前进度
  double _getParticleProgress(double globalProgress, _FireParticle particle) {
    final adjustedProgress = (globalProgress + particle.delay) % 1.0;
    return adjustedProgress / particle.lifetime;
  }

  @override
  bool shouldRepaint(covariant _FireParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
