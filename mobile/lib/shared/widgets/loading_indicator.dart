import 'package:flutter/material.dart';
import 'package:mobile/core/config/theme/app_colors.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const CustomLoadingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 24,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
      ),
    );
  }
}

class PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulseLoadingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 24,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.6 + (0.4 * _animation.value)),
          ),
        );
      },
    );
  }
}

class DotLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const DotLoadingIndicator({
    super.key,
    this.color = AppColors.primary,
    this.size = 8,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<DotLoadingIndicator> createState() => _DotLoadingIndicatorState();
}

class _DotLoadingIndicatorState extends State<DotLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animations = List.generate(3, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.2,
          0.6 + (index * 0.2),
          curve: Curves.easeInOut,
        ),
      ));
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.25),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(
                  0.3 + (0.7 * _animations[index].value),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}