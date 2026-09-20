import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Premium ambient animation layer for the Core Barrage home hangar.
///
/// This widget is intentionally pointer-transparent so it never blocks
/// Home-screen buttons.
class HomeAnimationLayer extends StatefulWidget {
  const HomeAnimationLayer({
    super.key,
  });

  @override
  State<HomeAnimationLayer> createState() => _HomeAnimationLayerState();
}

class _HomeAnimationLayerState extends State<HomeAnimationLayer>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _particleController;
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7200),
    )..repeat();

    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _particleController.dispose();
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _ambientController,
            _particleController,
            _sweepController,
          ]),
          builder: (context, child) {
            return CustomPaint(
              painter: _HomeAmbientPainter(
                ambient: _ambientController.value,
                particles: _particleController.value,
                sweep: _sweepController.value,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _HomeAmbientPainter extends CustomPainter {
  const _HomeAmbientPainter({
    required this.ambient,
    required this.particles,
    required this.sweep,
  });

  final double ambient;
  final double particles;
  final double sweep;

  static const List<_ParticleSeed> _particleSeeds = [
    _ParticleSeed(.10, .27, 1.1, .13, .04),
    _ParticleSeed(.18, .46, 1.5, .19, .21),
    _ParticleSeed(.27, .34, 1.0, .16, .38),
    _ParticleSeed(.34, .58, 1.8, .18, .58),
    _ParticleSeed(.43, .29, 1.2, .15, .73),
    _ParticleSeed(.50, .52, 1.6, .21, .09),
    _ParticleSeed(.58, .38, 1.0, .16, .29),
    _ParticleSeed(.65, .60, 1.7, .18, .46),
    _ParticleSeed(.72, .31, 1.3, .17, .64),
    _ParticleSeed(.80, .49, 1.5, .20, .81),
    _ParticleSeed(.89, .37, 1.1, .15, .92),
    _ParticleSeed(.14, .65, 1.4, .14, .51),
    _ParticleSeed(.25, .72, 1.0, .17, .86),
    _ParticleSeed(.39, .68, 1.6, .15, .32),
    _ParticleSeed(.56, .73, 1.2, .19, .69),
    _ParticleSeed(.70, .69, 1.5, .17, .13),
    _ParticleSeed(.83, .74, 1.0, .14, .41),
    _ParticleSeed(.92, .63, 1.3, .16, .77),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    _paintAmbientGlow(canvas, size);
    _paintSideLights(canvas, size);
    _paintLightSweep(canvas, size);
    _paintParticles(canvas, size);
    _paintFloorGlow(canvas, size);
  }

  void _paintAmbientGlow(Canvas canvas, Size size) {
    final pulse = 0.10 + (ambient * 0.07);

    final rect = Rect.fromCircle(
      center: Offset(
        size.width * 0.50,
        size.height * 0.43,
      ),
      radius: size.width * 0.58,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(0, 174, 255, pulse),
          Color.fromRGBO(0, 116, 255, pulse * 0.40),
          const Color.fromRGBO(0, 0, 0, 0),
        ],
        stops: const [
          0.0,
          0.52,
          1.0,
        ],
      ).createShader(rect);

    canvas.drawCircle(
      Offset(
        size.width * 0.50,
        size.height * 0.43,
      ),
      size.width * 0.58,
      paint,
    );
  }

  void _paintSideLights(Canvas canvas, Size size) {
    final alpha = 0.055 + (ambient * 0.045);

    final leftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromRGBO(0, 195, 255, alpha),
          const Color.fromRGBO(0, 120, 255, 0),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * 0.16,
          size.width * 0.36,
          size.height * 0.58,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * 0.16,
        size.width * 0.36,
        size.height * 0.58,
      ),
      leftPaint,
    );

    final rightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color.fromRGBO(0, 195, 255, alpha),
          const Color.fromRGBO(0, 120, 255, 0),
        ],
      ).createShader(
        Rect.fromLTWH(
          size.width * 0.64,
          size.height * 0.16,
          size.width * 0.36,
          size.height * 0.58,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.64,
        size.height * 0.16,
        size.width * 0.36,
        size.height * 0.58,
      ),
      rightPaint,
    );
  }

  void _paintLightSweep(Canvas canvas, Size size) {
    final travel = -0.30 + (sweep * 1.60);
    final centerX = size.width * travel;

    canvas.save();

    final path = Path()
      ..moveTo(centerX - size.width * 0.12, size.height * 0.12)
      ..lineTo(centerX + size.width * 0.02, size.height * 0.12)
      ..lineTo(centerX + size.width * 0.27, size.height * 0.74)
      ..lineTo(centerX + size.width * 0.11, size.height * 0.74)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromRGBO(90, 215, 255, 0),
          const Color.fromRGBO(90, 215, 255, 0.055),
          const Color.fromRGBO(90, 215, 255, 0),
        ],
      ).createShader(
        Rect.fromLTWH(
          centerX - size.width * 0.15,
          size.height * 0.12,
          size.width * 0.45,
          size.height * 0.62,
        ),
      );

    canvas.drawPath(path, paint);

    canvas.restore();
  }

  void _paintParticles(Canvas canvas, Size size) {
    for (final seed in _particleSeeds) {
      var progress = particles + seed.phase;

      if (progress > 1) {
        progress -= 1;
      }

      final y =
          (seed.y * size.height) -
              (progress * size.height * seed.travel);

      final x =
          (seed.x * size.width) +
              math.sin(
                (progress * math.pi * 2) +
                    (seed.phase * math.pi * 2),
              ) *
                  5;

      final fade = math.sin(progress * math.pi).clamp(0.0, 1.0);

      final particlePaint = Paint()
        ..color = Color.fromRGBO(
          104,
          220,
          255,
          0.11 * fade,
        );

      canvas.drawCircle(
        Offset(x, y),
        seed.radius,
        particlePaint,
      );

      if (seed.radius >= 1.5) {
        final glowPaint = Paint()
          ..color = Color.fromRGBO(
            60,
            180,
            255,
            0.035 * fade,
          );

        canvas.drawCircle(
          Offset(x, y),
          seed.radius * 3.0,
          glowPaint,
        );
      }
    }
  }

  void _paintFloorGlow(Canvas canvas, Size size) {
    final pulse = 0.10 + (ambient * 0.08);

    final rect = Rect.fromCenter(
      center: Offset(
        size.width * 0.50,
        size.height * 0.66,
      ),
      width: size.width * 0.72,
      height: size.height * 0.11,
    );

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.fromRGBO(0, 195, 255, pulse),
          Color.fromRGBO(0, 125, 255, pulse * 0.42),
          const Color.fromRGBO(0, 0, 0, 0),
        ],
        stops: const [
          0.0,
          0.52,
          1.0,
        ],
      ).createShader(rect);

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeAmbientPainter oldDelegate) {
    return oldDelegate.ambient != ambient ||
        oldDelegate.particles != particles ||
        oldDelegate.sweep != sweep;
  }
}

class _ParticleSeed {
  const _ParticleSeed(
      this.x,
      this.y,
      this.radius,
      this.travel,
      this.phase,
      );

  final double x;
  final double y;
  final double radius;
  final double travel;
  final double phase;
}

/// Gives the main tank a subtle mechanical idle motion.
///
/// Keep this restrained. The tank should feel heavy rather than floating.
class HomeTankIdleAnimation extends StatefulWidget {
  const HomeTankIdleAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<HomeTankIdleAnimation> createState() =>
      _HomeTankIdleAnimationState();
}

class _HomeTankIdleAnimationState
    extends State<HomeTankIdleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
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
      child: widget.child,
      builder: (context, child) {
        final curved = Curves.easeInOut.transform(
          _controller.value,
        );

        final vertical = -1.2 + (curved * 2.4);
        final rotation =
            math.sin(_controller.value * math.pi) * 0.0025;
        final scale = 1.0 + (curved * 0.004);

        return Transform.translate(
          offset: Offset(0, vertical),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Premium pulse used around the primary PLAY action.
///
/// It is intentionally subtle so PLAY remains readable.
class HomePlayPulseAnimation extends StatefulWidget {
  const HomePlayPulseAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<HomePlayPulseAnimation> createState() =>
      _HomePlayPulseAnimationState();
}

class _HomePlayPulseAnimationState
    extends State<HomePlayPulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    )..repeat(reverse: true);
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
      child: widget.child,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(
          _controller.value,
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(
                  255,
                  188,
                  35,
                  0.14 + (value * 0.18),
                ),
                blurRadius: 12 + (value * 12),
                spreadRadius: value * 1.5,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 1.0 + (value * 0.012),
            child: child,
          ),
        );
      },
    );
  }
}

/// Staggered entrance animation for Home UI sections.
class HomeEntranceAnimation extends StatefulWidget {
  const HomeEntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.08),
    this.duration = const Duration(milliseconds: 550),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;
  final Duration duration;

  @override
  State<HomeEntranceAnimation> createState() =>
      _HomeEntranceAnimationState();
}

class _HomeEntranceAnimationState
    extends State<HomeEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(curve);

    _start();
  }

  Future<void> _start() async {
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }

    if (!mounted) {
      return;
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Use this around notification badges such as Missions / Daily Reward.
/// The badge gently scales instead of aggressively bouncing.
class HomeBadgePulseAnimation extends StatefulWidget {
  const HomeBadgePulseAnimation({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<HomeBadgePulseAnimation> createState() =>
      _HomeBadgePulseAnimationState();
}

class _HomeBadgePulseAnimationState
    extends State<HomeBadgePulseAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
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
      child: widget.child,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(
          _controller.value,
        );

        return Transform.scale(
          scale: 1.0 + (value * 0.08),
          child: child,
        );
      },
    );
  }
}

/// Small premium idle animation for the soldiers standing beside the tank.
class HomeSoldierIdleAnimation extends StatefulWidget {
  const HomeSoldierIdleAnimation({
    super.key,
    required this.child,
    this.reverse = false,
  });

  final Widget child;
  final bool reverse;

  @override
  State<HomeSoldierIdleAnimation> createState() =>
      _HomeSoldierIdleAnimationState();
}

class _HomeSoldierIdleAnimationState
    extends State<HomeSoldierIdleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.reverse ? 2400 : 2100,
      ),
    )..repeat(reverse: true);
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
      child: widget.child,
      builder: (context, child) {
        final value = Curves.easeInOut.transform(
          _controller.value,
        );

        final direction = widget.reverse ? -1.0 : 1.0;

        return Transform.translate(
          offset: Offset(
            direction * value * 0.7,
            -value * 1.5,
          ),
          child: child,
        );
      },
    );
  }
}

/// Adds tactile visual feedback to a Home-screen card/button without
/// changing its original design.
class HomePressAnimation extends StatefulWidget {
  const HomePressAnimation({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius = 16,
  });

  final Widget child;
  final VoidCallback onTap;
  final double borderRadius;

  @override
  State<HomePressAnimation> createState() =>
      _HomePressAnimationState();
}

class _HomePressAnimationState extends State<HomePressAnimation> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }

    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.955 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 90),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Reusable animated number for Commander XP / Power / currencies.
class HomeAnimatedNumber extends StatelessWidget {
  const HomeAnimatedNumber({
    super.key,
    required this.value,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
    this.prefix = '',
    this.suffix = '',
  });

  final int value;
  final TextStyle style;
  final Duration duration;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: value.toDouble(),
      ),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '$prefix${_formatNumber(animatedValue.round())}$suffix',
          style: style,
        );
      },
    );
  }

  String _formatNumber(int number) {
    final text = number.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      final remaining = text.length - i;

      buffer.write(text[i]);

      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}

/// Animated progress bar useful for XP and Battle Pass.
class HomeAnimatedProgressBar extends StatelessWidget {
  const HomeAnimatedProgressBar({
    super.key,
    required this.progress,
    required this.backgroundColor,
    required this.fillColor,
    this.height = 6,
    this.duration = const Duration(milliseconds: 900),
  });

  final double progress;
  final Color backgroundColor;
  final Color fillColor;
  final double height;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: backgroundColor,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0,
            end: safeProgress,
          ),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return FractionallySizedBox(
              widthFactor: value,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(height),
                  boxShadow: [
                    BoxShadow(
                      color: fillColor.withValues(alpha: 0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}