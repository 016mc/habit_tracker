import 'package:flutter/material.dart';

/// 加载指示器组件
/// 提供多种样式的加载动画，统一应用加载状态展示
class LoadingIndicator extends StatelessWidget {
  /// 加载指示器尺寸
  final double size;

  /// 加载指示器颜色，为 null 时使用主题主色
  final Color? color;

  /// 加载提示文字
  final String? message;

  /// 是否显示背景遮罩
  final bool showOverlay;

  /// 指示器类型
  final LoadingType type;

  const LoadingIndicator({
    super.key,
    this.size = 36.0,
    this.color,
    this.message,
    this.showOverlay = false,
    this.type = LoadingType.circular,
  });

  /// 创建全屏加载指示器（带遮罩）
  const LoadingIndicator.overlay({
    super.key,
    this.size = 36.0,
    this.color,
    this.message,
    this.showOverlay = true,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    Widget indicator;

    switch (type) {
      case LoadingType.circular:
        indicator = _buildCircularIndicator(effectiveColor);
        break;
      case LoadingType.dots:
        indicator = _buildDotsIndicator(effectiveColor);
        break;
      case LoadingType.pulse:
        indicator = _buildPulseIndicator(effectiveColor);
        break;
    }

    // 如果有提示文字，组合文字
    if (message != null) {
      indicator = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    // 如果需要遮罩
    if (showOverlay) {
      return Container(
        color: theme.scaffoldBackgroundColor.withOpacity(0.8),
        child: Center(child: indicator),
      );
    }

    return Center(child: indicator);
  }

  /// 圆形旋转指示器
  Widget _buildCircularIndicator(Color color) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  /// 三点跳动指示器
  Widget _buildDotsIndicator(Color color) {
    return _DotsAnimation(
      color: color,
      size: size * 0.25,
    );
  }

  /// 脉冲缩放指示器
  Widget _buildPulseIndicator(Color color) {
    return _PulseAnimation(
      color: color,
      size: size,
    );
  }
}

/// 加载指示器类型
enum LoadingType {
  /// 圆形旋转
  circular,

  /// 三点跳动
  dots,

  /// 脉冲缩放
  pulse,
}

/// 三点跳动动画
class _DotsAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsAnimation({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsAnimation> createState() => _DotsAnimationState();
}

class _DotsAnimationState extends State<_DotsAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: -widget.size).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // 依次启动动画，形成波浪效果
    for (int i = 0; i < _controllers.length; i++) {
      _startAnimation(i);
    }
  }

  void _startAnimation(int index) {
    Future.delayed(Duration(milliseconds: index * 150), () {
      if (mounted) {
        _controllers[index].repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.3),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// 脉冲缩放动画
class _PulseAnimation extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseAnimation({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
