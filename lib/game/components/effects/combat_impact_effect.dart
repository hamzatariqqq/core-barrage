import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

enum CombatImpactType {
  missile,
  bossRage,
}

class CombatImpactEffect extends PositionComponent {
  CombatImpactEffect({
    required this.gameSize,
    required this.type,
    this.impactPosition,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: 1400,
  );

  final Vector2 gameSize;
  final CombatImpactType type;
  final Vector2? impactPosition;

  double _timer = 0;

  double get _duration {
    switch (type) {
      case CombatImpactType.missile:
        return 0.72;
      case CombatImpactType.bossRage:
        return 0.85;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _timer += dt;

    if (_timer >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final progress = (_timer / _duration).clamp(0.0, 1.0);

    switch (type) {
      case CombatImpactType.missile:
        _renderMissile(
          canvas,
          progress,
        );
        break;

      case CombatImpactType.bossRage:
        _renderBossRage(
          canvas,
          progress,
        );
        break;
    }
  }

  // ============================================================
  // MISSILE IMPACT
  // ============================================================

  void _renderMissile(
      Canvas canvas,
      double progress,
      ) {
    final center = impactPosition != null
        ? Offset(
      impactPosition!.x,
      impactPosition!.y,
    )
        : Offset(
      gameSize.x / 2,
      gameSize.y * 0.42,
    );

    final fade = (1.0 - progress).clamp(0.0, 1.0);

    final explosiveFade =
    (1.0 - (progress / 0.72)).clamp(0.0, 1.0);

    // ----------------------------------------------------------
    // INITIAL SCREEN FLASH
    // ----------------------------------------------------------

    if (progress < 0.22) {
      final flash =
      (1.0 - progress / 0.22).clamp(0.0, 1.0);

      canvas.drawRect(
        Rect.fromLTWH(
          0,
          0,
          gameSize.x,
          gameSize.y,
        ),
        Paint()
          ..color = const Color(0xFFFFE0A3).withValues(
            alpha: flash * 0.24,
          ),
      );
    }

    // ----------------------------------------------------------
    // SCREEN HEAT TINT
    // ----------------------------------------------------------

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      Paint()
        ..color = const Color(0xFFFF6A21).withValues(
          alpha: fade * 0.045,
        ),
    );

    // ----------------------------------------------------------
    // OUTER EXPLOSION GLOW
    // ----------------------------------------------------------

    final outerRadius = 30 + progress * 175;

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = const Color(0xFFFF4D16).withValues(
          alpha: explosiveFade * 0.08,
        ),
    );

    // ----------------------------------------------------------
    // ORANGE FIREBALL
    // ----------------------------------------------------------

    final fireRadius = 18 + progress * 105;

    canvas.drawCircle(
      center,
      fireRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(
              alpha: explosiveFade * 0.78,
            ),
            const Color(0xFFFFD35A).withValues(
              alpha: explosiveFade * 0.70,
            ),
            const Color(0xFFFF7A20).withValues(
              alpha: explosiveFade * 0.46,
            ),
            const Color(0xFFFF351A).withValues(
              alpha: explosiveFade * 0.12,
            ),
            Colors.transparent,
          ],
          stops: const [
            0,
            .18,
            .43,
            .72,
            1,
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: fireRadius,
          ),
        ),
    );

    // ----------------------------------------------------------
    // CORE FLASH
    // ----------------------------------------------------------

    if (progress < 0.28) {
      final coreFade =
      (1.0 - progress / 0.28).clamp(0.0, 1.0);

      final coreRadius = 16 + progress * 52;

      canvas.drawCircle(
        center,
        coreRadius,
        Paint()
          ..color = Colors.white.withValues(
            alpha: coreFade * 0.82,
          ),
      );

      canvas.drawCircle(
        center,
        coreRadius * 1.35,
        Paint()
          ..color = const Color(0xFFFFD45C).withValues(
            alpha: coreFade * 0.35,
          ),
      );
    }

    // ----------------------------------------------------------
    // SHOCKWAVE 1
    // ----------------------------------------------------------

    final shockProgress =
    (progress / 0.82).clamp(0.0, 1.0);

    final shockRadius = 24 + shockProgress * 175;

    canvas.drawCircle(
      center,
      shockRadius,
      Paint()
        ..color = const Color(0xFFFFC75C).withValues(
          alpha: fade * 0.72,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(
          1.0,
          6.5 * fade,
        ),
    );

    // ----------------------------------------------------------
    // SHOCKWAVE 2
    // ----------------------------------------------------------

    final secondProgress =
    ((progress - 0.10) / 0.90).clamp(0.0, 1.0);

    if (progress > 0.10) {
      final secondRadius =
          18 + secondProgress * 125;

      canvas.drawCircle(
        center,
        secondRadius,
        Paint()
          ..color = const Color(0xFFFF793D).withValues(
            alpha: fade * 0.38,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(
            1.0,
            3.5 * fade,
          ),
      );
    }

    // ----------------------------------------------------------
    // EXPLOSION RAYS
    // ----------------------------------------------------------

    const rayCount = 14;

    for (int i = 0; i < rayCount; i++) {
      final angle =
          (i / rayCount) * pi * 2 + 0.18;

      final rayVariation =
          0.80 + ((i % 4) * 0.08);

      final start =
          fireRadius * (0.40 + progress * 0.18);

      final end =
          fireRadius * (1.05 + rayVariation);

      final startPoint = Offset(
        center.dx + cos(angle) * start,
        center.dy + sin(angle) * start,
      );

      final endPoint = Offset(
        center.dx + cos(angle) * end,
        center.dy + sin(angle) * end,
      );

      canvas.drawLine(
        startPoint,
        endPoint,
        Paint()
          ..color = const Color(0xFFFFB83F).withValues(
            alpha: fade * 0.55,
          )
          ..strokeWidth = max(
            0.5,
            2.6 * fade,
          )
          ..strokeCap = StrokeCap.round,
      );
    }

    // ----------------------------------------------------------
    // FLYING SPARKS
    // ----------------------------------------------------------

    const sparkCount = 20;

    for (int i = 0; i < sparkCount; i++) {
      final angle =
          (i / sparkCount) * pi * 2 +
              sin(i * 4.7) * 0.20;

      final speed =
          55.0 + (i % 6) * 13.0;

      final distance =
          progress * speed * 1.65;

      final sparkCenter = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      final sparkSize =
      max(0.7, (3.0 - progress * 2.0));

      final sparkColor = i.isEven
          ? const Color(0xFFFFD75B)
          : const Color(0xFFFF7A28);

      canvas.drawCircle(
        sparkCenter,
        sparkSize,
        Paint()
          ..color = sparkColor.withValues(
            alpha: fade * 0.85,
          ),
      );
    }

    // ----------------------------------------------------------
    // DEBRIS
    // ----------------------------------------------------------

    const debrisCount = 9;

    for (int i = 0; i < debrisCount; i++) {
      final angle =
          (i / debrisCount) * pi * 2 + 0.4;

      final distance =
          progress * (75 + (i % 3) * 25);

      final debrisPosition = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      canvas.save();

      canvas.translate(
        debrisPosition.dx,
        debrisPosition.dy,
      );

      canvas.rotate(
        progress * 8 + i,
      );

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: 4,
          height: 2,
        ),
        Paint()
          ..color = const Color(0xFF39271C).withValues(
            alpha: fade * 0.75,
          ),
      );

      canvas.restore();
    }

    // ----------------------------------------------------------
    // CENTER IMPACT MARK
    // ----------------------------------------------------------

    if (progress > 0.35) {
      final markFade =
      ((progress - 0.35) / 0.65).clamp(0.0, 1.0);

      canvas.drawCircle(
        center,
        17 + markFade * 6,
        Paint()
          ..color = Colors.black.withValues(
            alpha: fade * 0.24,
          ),
      );
    }
  }

  // ============================================================
  // BOSS RAGE
  // ============================================================

  void _renderBossRage(
      Canvas canvas,
      double progress,
      ) {
    final fade =
    (1.0 - progress).clamp(0.0, 1.0);

    final pulse =
        (sin(progress * pi * 10) + 1) / 2;

    final center = impactPosition != null
        ? Offset(
      impactPosition!.x,
      impactPosition!.y,
    )
        : Offset(
      gameSize.x / 2,
      gameSize.y * 0.29,
    );

    // ----------------------------------------------------------
    // RED SCREEN PRESSURE
    // ----------------------------------------------------------

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y,
      ),
      Paint()
        ..color = const Color(0xFFFF1C18).withValues(
          alpha:
          fade * (0.065 + pulse * 0.055),
        ),
    );

    // ----------------------------------------------------------
    // DARK DANGER VIGNETTE
    // ----------------------------------------------------------

    final screenRect = Rect.fromLTWH(
      0,
      0,
      gameSize.x,
      gameSize.y,
    );

    canvas.drawRect(
      screenRect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.85,
          colors: [
            Colors.transparent,
            const Color(0xFF8D0505).withValues(
              alpha: fade * 0.08,
            ),
            const Color(0xFF220000).withValues(
              alpha: fade * 0.25,
            ),
          ],
          stops: const [
            .30,
            .72,
            1,
          ],
        ).createShader(screenRect),
    );

    // ----------------------------------------------------------
    // PRIMARY RAGE SHOCKWAVE
    // ----------------------------------------------------------

    final radius =
        38 + progress * 250;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFFF382D).withValues(
          alpha: fade * 0.65,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(
          1.0,
          8 * fade,
        ),
    );

    // ----------------------------------------------------------
    // SECOND RAGE RING
    // ----------------------------------------------------------

    final secondRadius =
        24 + progress * 190;

    canvas.drawCircle(
      center,
      secondRadius,
      Paint()
        ..color = const Color(0xFFFF784D).withValues(
          alpha: fade * 0.34,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(
          1.0,
          4.5 * fade,
        ),
    );

    // ----------------------------------------------------------
    // INNER BOSS ENERGY
    // ----------------------------------------------------------

    final coreRadius =
        28 + pulse * 14;

    canvas.drawCircle(
      center,
      coreRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFB078).withValues(
              alpha: fade * 0.34,
            ),
            const Color(0xFFFF392D).withValues(
              alpha: fade * 0.18,
            ),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: coreRadius,
          ),
        ),
    );

    // ----------------------------------------------------------
    // ENERGY RAYS
    // ----------------------------------------------------------

    const rayCount = 12;

    for (int i = 0; i < rayCount; i++) {
      final angle =
          (i / rayCount) * pi * 2 +
              progress * 0.35;

      final inner =
          38 + progress * 28;

      final outer =
          72 + progress * 115;

      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * inner,
          center.dy + sin(angle) * inner,
        ),
        Offset(
          center.dx + cos(angle) * outer,
          center.dy + sin(angle) * outer,
        ),
        Paint()
          ..color = const Color(0xFFFF5645).withValues(
            alpha: fade * 0.32,
          )
          ..strokeWidth = max(
            0.6,
            2.2 * fade,
          )
          ..strokeCap = StrokeCap.round,
      );
    }

    // ----------------------------------------------------------
    // DANGER SIDE GLOW
    // ----------------------------------------------------------

    final left = Rect.fromLTWH(
      0,
      0,
      gameSize.x * 0.28,
      gameSize.y,
    );

    canvas.drawRect(
      left,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFFF3025).withValues(
              alpha: fade * 0.40,
            ),
            Colors.transparent,
          ],
        ).createShader(left),
    );

    final right = Rect.fromLTWH(
      gameSize.x * 0.72,
      0,
      gameSize.x * 0.28,
      gameSize.y,
    );

    canvas.drawRect(
      right,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            const Color(0xFFFF3025).withValues(
              alpha: fade * 0.40,
            ),
            Colors.transparent,
          ],
        ).createShader(right),
    );

    // ----------------------------------------------------------
    // TOP WARNING FLASH
    // ----------------------------------------------------------

    if (progress < 0.45) {
      final warningFade =
      (1.0 - progress / 0.45).clamp(0.0, 1.0);

      final warningRect = Rect.fromLTWH(
        0,
        0,
        gameSize.x,
        gameSize.y * 0.16,
      );

      canvas.drawRect(
        warningRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF1E19).withValues(
                alpha: warningFade * 0.22,
              ),
              Colors.transparent,
            ],
          ).createShader(warningRect),
      );
    }
  }
}