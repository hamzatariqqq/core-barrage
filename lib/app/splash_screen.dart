import 'dart:math' as math;

import 'package:flutter/material.dart';

class CoreBarrageSplashScreen extends StatefulWidget {
  const CoreBarrageSplashScreen({
    super.key,
    required this.homeBuilder,
  });

  final WidgetBuilder homeBuilder;

  @override
  State<CoreBarrageSplashScreen> createState() =>
      _CoreBarrageSplashScreenState();
}

class _CoreBarrageSplashScreenState
    extends State<CoreBarrageSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _backgroundController;
  late final AnimationController _pulseController;
  late final AnimationController _loadingController;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _start();
  }

  Future<void> _start() async {
    await _loadingController.forward();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),
        pageBuilder: (
            context,
            animation,
            secondaryAnimation,
            ) {
          return widget.homeBuilder(context);
        },
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  String _status(double progress) {
    if (progress < 0.28) {
      return 'INITIALIZING SYSTEMS';
    }

    if (progress < 0.55) {
      return 'LOADING ASSETS';
    }

    if (progress < 0.82) {
      return 'PREPARING BATTLEFIELD';
    }

    if (progress < 0.97) {
      return 'SYNCING WEAPONS';
    }

    return 'READY FOR BATTLE';
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020812),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _pulseController,
          _loadingController,
        ]),
        builder: (context, child) {
          final progress = _loadingController.value;

          final backgroundScale = 1.06 -
              (_backgroundController.value * 0.06);

          final pulse =
              0.5 +
                  (_pulseController.value * 0.5);

          final percentage =
          (progress * 100).round();

          return Stack(
            fit: StackFit.expand,
            children: [
              Transform.scale(
                scale: backgroundScale,
                child: Image.asset(
                  'assets/images/ui/splash/splash_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(
                        alpha: 0.06,
                      ),
                      Colors.transparent,
                      Colors.black.withValues(
                        alpha: 0.20,
                      ),
                      Colors.black.withValues(
                        alpha: 0.72,
                      ),
                    ],
                    stops: const [
                      0.0,
                      0.40,
                      0.70,
                      1.0,
                    ],
                  ),
                ),
              ),

              // Animated targeting glow.
              Align(
                alignment: const Alignment(
                  0,
                  -0.34,
                ),
                child: Transform.scale(
                  scale: 0.92 + (pulse * 0.08),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFFA000)
                              .withValues(
                            alpha:
                            0.18 +
                                (pulse * 0.20),
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Rotating targeting ring.
              Align(
                alignment: const Alignment(
                  0,
                  -0.34,
                ),
                child: Transform.rotate(
                  angle:
                  _backgroundController.value *
                      math.pi *
                      2,
                  child: Opacity(
                    opacity: 0.25 + (pulse * 0.20),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                          const Color(0xFFFFB21A),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.gps_fixed,
                        color: Color(
                          0xFFFFB21A,
                        ),
                        size: 42,
                      ),
                    ),
                  ),
                ),
              ),

              // Moving scanner.
              Positioned(
                left: 0,
                right: 0,
                top:
                MediaQuery.sizeOf(context).height *
                    progress,
                child: Opacity(
                  opacity: progress < 0.98
                      ? 0.32
                      : 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(0xFFFFA000)
                              .withValues(
                            alpha: 0.8,
                          ),
                          blurRadius: 16,
                          spreadRadius: 3,
                        ),
                      ],
                      gradient:
                      const LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFFFFB21A),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 26,
                right: 26,
                bottom: 46,
                child: Container(
                  padding:
                  const EdgeInsets.fromLTRB(
                    18,
                    15,
                    18,
                    16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xD9081018),
                    borderRadius:
                    BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(
                        0x55FFB21A,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                        const Color(0xFFFF8A00)
                            .withValues(
                          alpha: 0.10,
                        ),
                        blurRadius: 22,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _status(progress),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight:
                                FontWeight.w900,
                                letterSpacing: 1.8,
                              ),
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: const TextStyle(
                              color: Color(
                                0xFFFFB21A,
                              ),
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Container(
                        height: 10,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF111820,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            30,
                          ),
                          border: Border.all(
                            color: const Color(
                              0x88FFB21A,
                            ),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FractionallySizedBox(
                              alignment:
                              Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(
                                decoration:
                                const BoxDecoration(
                                  gradient:
                                  LinearGradient(
                                    colors: [
                                      Color(
                                        0xFFFF7A00,
                                      ),
                                      Color(
                                        0xFFFFD54A,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            Align(
                              alignment: Alignment(
                                (progress * 2) - 1,
                                0,
                              ),
                              child: Container(
                                width: 18,
                                decoration:
                                BoxDecoration(
                                  color: Colors.white
                                      .withValues(
                                    alpha: 0.75,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(
                                        0xFFFFB21A,
                                      ),
                                      blurRadius: 12,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 13),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          _StageDot(
                            active: progress >= 0.05,
                            label: 'SYSTEM',
                          ),
                          _StageDot(
                            active: progress >= 0.30,
                            label: 'ASSETS',
                          ),
                          _StageDot(
                            active: progress >= 0.58,
                            label: 'BATTLE',
                          ),
                          _StageDot(
                            active: progress >= 0.84,
                            label: 'WEAPONS',
                          ),
                          _StageDot(
                            active: progress >= 0.98,
                            label: 'READY',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.active,
    required this.label,
  });

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color(0xFFFFB21A)
        : const Color(0xFF65717C);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(
            milliseconds: 250,
          ),
          width: active ? 9 : 7,
          height: active ? 9 : 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: active
                ? [
              BoxShadow(
                color: const Color(
                  0xFFFFA000,
                ).withValues(
                  alpha: 0.55,
                ),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 6.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}