import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class GameHud extends PositionComponent {
  GameHud({
    required this.gameSize,
    required this.onPause,
    required this.onMissile,
    required this.onFreeze,
    this.levelNumber = 1,
    this.levelTitle = 'FIRST ASSAULT',
    this.bossName = 'SCOUT CAPTAIN',
    this.accent = const Color(0xFF27C7FF),
  }) : super(
    size: gameSize,
    priority: 1000,
  );

  final Vector2 gameSize;

  final VoidCallback onPause;
  final VoidCallback onMissile;
  final VoidCallback onFreeze;

  final int levelNumber;
  final String levelTitle;
  final String bossName;
  final Color accent;

  late final TextComponent healthText;
  late final TextComponent coinText;
  late final TextComponent armyText;

  late final HudProgressBar levelProgress;

  late final PositionComponent bossHud;
  late final HudProgressBar bossProgress;
  late final TextComponent bossHealthText;

  late final CombatAbilityButton missileButton;
  late final CombatAbilityButton freezeButton;

  bool _bossVisible = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _buildTopHud();
    _buildBossHud();
    _buildBottomHud();
  }

  // ============================================================
  // TOP HUD
  // ============================================================

  void _buildTopHud() {
    const double topY = 7;

    add(
      TacticalTopPanel(
        position: Vector2(7, topY),
        size: Vector2(gameSize.x - 14, 64),
        accent: accent,
      ),
    );

    // ------------------------------------------------------------
    // REAL PAUSE BUTTON
    // ------------------------------------------------------------

    add(
      HudPauseButton(
        position: Vector2(29, topY + 27),
        accent: accent,
        onPressed: onPause,
      ),
    );

    // ------------------------------------------------------------
    // LEVEL TITLE
    // ------------------------------------------------------------

    add(
      TextComponent(
        text: 'LEVEL $levelNumber',
        position: Vector2(
          gameSize.x / 2,
          topY + 8,
        ),
        anchor: Anchor.topCenter,
        priority: 1120,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black87,
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );

    add(
      TextComponent(
        text: levelTitle.toUpperCase(),
        position: Vector2(
          gameSize.x / 2,
          topY + 23,
        ),
        anchor: Anchor.topCenter,
        priority: 1120,
        textRenderer: TextPaint(
          style: TextStyle(
            color: accent,
            fontSize: 6.2,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
      ),
    );

    // ------------------------------------------------------------
    // MISSION PROGRESS
    // ------------------------------------------------------------

    levelProgress = HudProgressBar(
      position: Vector2(
        58,
        topY + 45,
      ),
      size: Vector2(
        gameSize.x - 116,
        7,
      ),
      fillColor: accent,
      backgroundColor: const Color(0xFF020B11),
      borderColor: accent.withValues(alpha: .55),
      glow: true,
    );

    add(levelProgress);

    add(
      TextComponent(
        text: 'MISSION',
        position: Vector2(
          gameSize.x / 2,
          topY + 55,
        ),
        anchor: Anchor.topCenter,
        priority: 1120,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF68899D),
            fontSize: 4.7,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
          ),
        ),
      ),
    );

    // ------------------------------------------------------------
    // COINS
    // ------------------------------------------------------------

    add(
      TacticalStatPanel(
        position: Vector2(
          gameSize.x - 78,
          topY + 12,
        ),
        size: Vector2(67, 29),
        borderColor: const Color(0xFF8C7223),
      ),
    );

    add(
      CircleComponent(
        position: Vector2(
          gameSize.x - 66,
          topY + 26,
        ),
        radius: 6,
        anchor: Anchor.center,
        priority: 1110,
        paint: Paint()
          ..color = const Color(0xFFFFC82F),
      ),
    );

    add(
      TextComponent(
        text: r'$',
        position: Vector2(
          gameSize.x - 66,
          topY + 26,
        ),
        anchor: Anchor.center,
        priority: 1120,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF513B00),
            fontSize: 7,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    coinText = TextComponent(
      text: '0',
      position: Vector2(
        gameSize.x - 42,
        topY + 26,
      ),
      anchor: Anchor.center,
      priority: 1120,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    add(coinText);

    // ------------------------------------------------------------
    // HEALTH
    // ------------------------------------------------------------

    add(
      TacticalStatPanel(
        position: Vector2(
          8,
          topY + 69,
        ),
        size: Vector2(82, 27),
        borderColor: const Color(0xFF9C3945),
      ),
    );

    add(
      TextComponent(
        text: '♥',
        position: Vector2(
          22,
          topY + 82,
        ),
        anchor: Anchor.center,
        priority: 1120,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFF5362),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Color(0xAAFF3344),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );

    healthText = TextComponent(
      text: '100',
      position: Vector2(
        58,
        topY + 82,
      ),
      anchor: Anchor.center,
      priority: 1120,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    add(healthText);
  }

  // ============================================================
  // BOSS HUD
  // ============================================================

  void _buildBossHud() {
    bossHud = PositionComponent(
      position: Vector2(
        gameSize.x / 2,
        105,
      ),
      priority: 1150,
    );

    bossHud.add(
      TacticalBossPanel(
        position: Vector2(-116, 0),
        size: Vector2(232, 51),
      ),
    );

    bossHud.add(
      TextComponent(
        text: '⚠  ${bossName.toUpperCase()}  ⚠',
        position: Vector2(0, 6),
        anchor: Anchor.topCenter,
        priority: 1160,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            letterSpacing: .8,
            shadows: [
              Shadow(
                color: Color(0xAAFF303D),
                blurRadius: 5,
              ),
            ],
          ),
        ),
      ),
    );

    bossProgress = HudProgressBar(
      position: Vector2(-91, 27),
      size: Vector2(182, 10),
      fillColor: const Color(0xFFFF4552),
      backgroundColor: const Color(0xFF26070B),
      borderColor: const Color(0xFFB83C46),
      glow: true,
    );

    bossHud.add(bossProgress);

    bossHealthText = TextComponent(
      text: '',
      position: Vector2(0, 32),
      anchor: Anchor.center,
      priority: 1170,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 6.2,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );

    bossHud.add(bossHealthText);

    bossHud.add(
      TextComponent(
        text: 'BOSS',
        position: Vector2(0, 41),
        anchor: Anchor.topCenter,
        priority: 1160,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFF6A73),
            fontSize: 4.8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM HUD
  // ============================================================

  void _buildBottomHud() {
    // ------------------------------------------------------------
    // ARMY
    // ------------------------------------------------------------

    add(
      ArmyHudBadge(
        position: Vector2(
          gameSize.x - 38,
          gameSize.y - 106,
        ),
        accent: accent,
      ),
    );

    armyText = TextComponent(
      text: '6',
      position: Vector2(
        gameSize.x - 38,
        gameSize.y - 112,
      ),
      anchor: Anchor.center,
      priority: 1120,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );

    add(armyText);

    add(
      TextComponent(
        text: 'ARMY',
        position: Vector2(
          gameSize.x - 38,
          gameSize.y - 94,
        ),
        anchor: Anchor.center,
        priority: 1120,
        textRenderer: TextPaint(
          style: TextStyle(
            color: accent,
            fontSize: 5.5,
            fontWeight: FontWeight.w900,
            letterSpacing: .7,
          ),
        ),
      ),
    );

    // ------------------------------------------------------------
    // ABILITY DOCK
    // ------------------------------------------------------------

    add(
      BottomAbilityDock(
        position: Vector2(
          gameSize.x / 2,
          gameSize.y - 42,
        ),
        size: Vector2(
          gameSize.x - 18,
          76,
        ),
        accent: accent,
      ),
    );

    missileButton = CombatAbilityButton(
      position: Vector2(
        49,
        gameSize.y - 42,
      ),
      title: 'MISSILE',
      symbol: '▲',
      accent: const Color(0xFFFF983A),
      onPressed: onMissile,
    );

    add(missileButton);

    freezeButton = CombatAbilityButton(
      position: Vector2(
        gameSize.x - 49,
        gameSize.y - 42,
      ),
      title: 'FREEZE',
      symbol: '❄',
      accent: const Color(0xFF52C9FF),
      onPressed: onFreeze,
    );

    add(freezeButton);

    add(
      TextComponent(
        text: 'COMBAT ABILITIES',
        position: Vector2(
          gameSize.x / 2,
          gameSize.y - 58,
        ),
        anchor: Anchor.center,
        priority: 1110,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFF7893A3),
            fontSize: 5,
            fontWeight: FontWeight.w900,
            letterSpacing: .9,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PUBLIC API — PRESERVED
  // ============================================================

  void updateHealth(double health) {
    healthText.text = health.ceil().clamp(0, 9999).toString();
  }

  void updateArmy(int army) {
    armyText.text = army.toString();
  }

  void updateCoins(int coins) {
    coinText.text = coins.toString();
  }

  void updateProgress(double progress) {
    levelProgress.progress = progress.clamp(0.0, 1.0);
  }

  void showBoss() {
    if (_bossVisible) return;

    _bossVisible = true;
    add(bossHud);
  }

  void hideBoss() {
    if (!_bossVisible) return;

    _bossVisible = false;
    bossHud.removeFromParent();
  }

  void updateBossHealth({
    required double health,
    required double maxHealth,
  }) {
    if (maxHealth <= 0) return;

    final safeHealth = math.max(0.0, health);

    bossProgress.progress =
        (safeHealth / maxHealth).clamp(0.0, 1.0);

    bossHealthText.text =
    '${safeHealth.ceil()} / ${maxHealth.ceil()}';
  }

  void updateMissileCooldown(double seconds) {
    missileButton.setCooldown(seconds);
  }

  void updateFreezeCooldown(double seconds) {
    freezeButton.setCooldown(seconds);
  }
}

// ============================================================
// TOP PANEL
// ============================================================

class TacticalTopPanel extends PositionComponent {
  TacticalTopPanel({
    required Vector2 position,
    required Vector2 size,
    required this.accent,
  }) : super(
    position: position,
    size: size,
    priority: 1100,
  );

  final Color accent;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final shape = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(13),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF018354A),
            Color(0xF00A1B28),
            Color(0xF0051119),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..color = accent.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final linePaint = Paint()
      ..color = accent.withValues(alpha: .13)
      ..strokeWidth = 1;

    canvas.drawLine(
      const Offset(45, 0),
      Offset(45, size.y),
      linePaint,
    );

    canvas.drawLine(
      Offset(size.x - 82, 0),
      Offset(size.x - 82, size.y),
      linePaint,
    );
  }
}

// ============================================================
// STAT PANEL
// ============================================================

class TacticalStatPanel extends PositionComponent {
  TacticalStatPanel({
    required Vector2 position,
    required Vector2 size,
    required this.borderColor,
  }) : super(
    position: position,
    size: size,
    priority: 1105,
  );

  final Color borderColor;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final shape = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(8),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..color = const Color(0xE506131C),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..color = borderColor.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

// ============================================================
// PAUSE BUTTON
// ============================================================

class HudPauseButton extends PositionComponent
    with TapCallbacks {
  HudPauseButton({
    required Vector2 position,
    required this.accent,
    required this.onPressed,
  }) : super(
    position: position,
    size: Vector2.all(38),
    anchor: Anchor.center,
    priority: 1200,
  );

  final Color accent;
  final VoidCallback onPressed;

  bool _pressed = false;

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressed = false;
    onPressed();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    final radius = _pressed ? 14.0 : 15.5;

    canvas.drawCircle(
      center,
      radius + 3,
      Paint()
        ..color = accent.withValues(
          alpha: _pressed ? .20 : .09,
        ),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF091821),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = accent.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    final pausePaint = Paint()
      ..color = Colors.white;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - 5,
          center.dy - 6,
          3.5,
          12,
        ),
        const Radius.circular(1),
      ),
      pausePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx + 1.5,
          center.dy - 6,
          3.5,
          12,
        ),
        const Radius.circular(1),
      ),
      pausePaint,
    );
  }
}

// ============================================================
// ARMY BADGE
// ============================================================

class ArmyHudBadge extends PositionComponent {
  ArmyHudBadge({
    required Vector2 position,
    required this.accent,
  }) : super(
    position: position,
    size: Vector2.all(52),
    anchor: Anchor.center,
    priority: 1110,
  );

  final Color accent;

  @override
  void render(Canvas canvas) {
    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    canvas.drawCircle(
      center,
      25,
      Paint()
        ..color = accent.withValues(alpha: .10),
    );

    canvas.drawCircle(
      center,
      22,
      Paint()
        ..color = const Color(0xED081720),
    );

    canvas.drawCircle(
      center,
      21,
      Paint()
        ..color = accent.withValues(alpha: .80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    canvas.drawCircle(
      center,
      17,
      Paint()
        ..color = accent.withValues(alpha: .09),
    );
  }
}

// ============================================================
// BOTTOM ABILITY DOCK
// ============================================================

class BottomAbilityDock extends PositionComponent {
  BottomAbilityDock({
    required Vector2 position,
    required Vector2 size,
    required this.accent,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.center,
    priority: 1080,
  );

  final Color accent;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final shape = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(19),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xD90B1D29),
            Color(0xE6051017),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..color = accent.withValues(alpha: .22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

// ============================================================
// ABILITY BUTTON
// ============================================================

class CombatAbilityButton extends PositionComponent
    with TapCallbacks {
  CombatAbilityButton({
    required Vector2 position,
    required this.title,
    required this.symbol,
    required this.accent,
    required this.onPressed,
  }) : super(
    position: position,
    size: Vector2.all(78),
    anchor: Anchor.center,
    priority: 1200,
  );

  final String title;
  final String symbol;
  final Color accent;
  final VoidCallback onPressed;

  double _cooldown = 0;
  bool _pressed = false;

  void setCooldown(double seconds) {
    _cooldown = seconds < 0 ? 0 : seconds;
  }

  @override
  void onTapDown(TapDownEvent event) {
    _pressed = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _pressed = false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _pressed = false;

    if (_cooldown > 0) return;

    onPressed();
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(
      size.x / 2,
      size.y / 2 - 2,
    );

    final unavailable = _cooldown > 0;
    final radius = _pressed ? 25.0 : 27.0;

    // Glow
    canvas.drawCircle(
      center,
      radius + 6,
      Paint()
        ..color = accent.withValues(
          alpha: unavailable
              ? .025
              : _pressed
              ? .20
              : .10,
        ),
    );

    // Outer dark ring
    canvas.drawCircle(
      center,
      radius + 2,
      Paint()
        ..color = const Color(0xE7041119),
    );

    // Inner button
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withValues(
              alpha: unavailable ? .07 : .20,
            ),
            const Color(0xFF091821),
          ],
        ).createShader(
          Rect.fromCircle(
            center: center,
            radius: radius,
          ),
        ),
    );

    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = accent.withValues(
          alpha: unavailable
              ? .25
              : _pressed
              ? 1
              : .82,
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = _pressed ? 2.8 : 2,
    );

    // Cooldown sweep
    if (unavailable) {
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius - 3,
        ),
        -math.pi / 2,
        math.pi * 1.55,
        false,
        Paint()
          ..color = const Color(0xAA02070B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6,
      );
    }

    final displayText = unavailable
        ? _cooldown.ceil().toString()
        : symbol;

    final symbolPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: TextStyle(
          color: unavailable
              ? Colors.white70
              : Colors.white,
          fontSize: unavailable ? 14 : 19,
          fontWeight: FontWeight.w900,
          shadows: unavailable
              ? null
              : [
            Shadow(
              color: accent,
              blurRadius: 7,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    symbolPainter.paint(
      canvas,
      Offset(
        center.dx - symbolPainter.width / 2,
        center.dy - symbolPainter.height / 2 - 5,
      ),
    );

    final titlePainter = TextPainter(
      text: TextSpan(
        text: unavailable
            ? '$title • ${_cooldown.ceil()}s'
            : '$title • READY',
        style: TextStyle(
          color: unavailable
              ? const Color(0xFF6E7C84)
              : accent,
          fontSize: 5.2,
          fontWeight: FontWeight.w900,
          letterSpacing: .35,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    titlePainter.paint(
      canvas,
      Offset(
        center.dx - titlePainter.width / 2,
        size.y - 18,
      ),
    );
  }
}

// ============================================================
// PROGRESS BAR
// ============================================================

class HudProgressBar extends PositionComponent {
  HudProgressBar({
    required Vector2 position,
    required Vector2 size,
    required this.fillColor,
    this.backgroundColor = const Color(0xFF061019),
    this.borderColor = const Color(0xFF466374),
    this.glow = false,
  }) : super(
    position: position,
    size: size,
    priority: 1115,
  );

  final Color fillColor;
  final Color backgroundColor;
  final Color borderColor;
  final bool glow;

  double progress = 0;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final shape = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(8),
    );

    if (glow) {
      canvas.drawRRect(
        shape,
        Paint()
          ..color = fillColor.withValues(alpha: .12)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            5,
          ),
      );
    }

    canvas.drawRRect(
      shape,
      Paint()
        ..color = backgroundColor,
    );

    final safeProgress =
    progress.clamp(0.0, 1.0);

    final width = size.x * safeProgress;

    if (width > 0) {
      final fillRect = Rect.fromLTWH(
        0,
        0,
        width,
        size.y,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          fillRect,
          const Radius.circular(8),
        ),
        Paint()
          ..shader = LinearGradient(
            colors: [
              fillColor.withValues(alpha: .75),
              fillColor,
            ],
          ).createShader(fillRect),
      );

      if (width > 5) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              2,
              1,
              math.max(0, width - 4),
              math.max(1, size.y * .25),
            ),
            const Radius.circular(5),
          ),
          Paint()
            ..color = Colors.white.withValues(
              alpha: .30,
            ),
        );
      }
    }

    canvas.drawRRect(
      shape,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }
}

// ============================================================
// BOSS PANEL
// ============================================================

class TacticalBossPanel extends PositionComponent {
  TacticalBossPanel({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
    priority: 1140,
  );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final shape = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(11),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF02A1015),
            Color(0xF0110A0D),
          ],
        ).createShader(rect),
    );

    canvas.drawRRect(
      shape,
      Paint()
        ..color = const Color(0xFFFF4B55)
            .withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    final leftPaint = Paint()
      ..color = const Color(0xFFFF4B55)
          .withValues(alpha: .60)
      ..strokeWidth = 2;

    canvas.drawLine(
      const Offset(10, 0),
      const Offset(28, 0),
      leftPaint,
    );

    canvas.drawLine(
      Offset(size.x - 28, 0),
      Offset(size.x - 10, 0),
      leftPaint,
    );
  }
}