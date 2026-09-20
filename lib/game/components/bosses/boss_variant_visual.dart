import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../../app/progression/selected_level.dart';
import '../../systems/level/level_runtime_config.dart';
import 'basic_boss.dart';

class BossVariantVisual extends SpriteAnimationComponent
    with HasGameReference<FlameGame> {
  BossVariantVisual({
    required this.boss,
    required this.config,
  }) : super(
    anchor: Anchor.bottomCenter,
    priority: 121,
  );

  final BasicBoss boss;
  final LevelRuntimeConfig config;

  late final int level;

  bool _animatedBoss = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    level = SelectedLevel.current.clamp(1, 15).toInt();

    await _loadBoss();

    position.setFrom(
      boss.position,
    );
  }

  // ============================================================
  // UNIVERSAL BOSS LOADER
  //
  // First checks:
  // bosses/boss_XX_walk.png
  //
  // If animation asset doesn't exist:
  // bosses/boss_XX.png
  // ============================================================

  Future<void> _loadBoss() async {
    final number =
    level.toString().padLeft(
      2,
      '0',
    );

    final animatedPath =
        'bosses/boss_${number}_walk.png';

    try {
      final image =
      await game.images.load(
        animatedPath,
      );

      _animatedBoss =
      true;

      _buildWalkingAnimation(
        image,
      );
    } catch (_) {
      _animatedBoss =
      false;

      await _loadStaticBoss(
        number,
      );
    }

    size =
        _bossSize();
  }

  // ============================================================
  // 8 FRAME WALKING ANIMATION
  //
  // 4 COLUMNS
  // 2 ROWS
  // ============================================================

  void _buildWalkingAnimation(
      dynamic image,
      ) {
    final double frameWidth =
        image.width.toDouble() / 4.0;

    final double frameHeight =
        image.height.toDouble() / 2.0;

    final frames = <Sprite>[];

    for (int row = 0; row < 2; row++) {
      for (int column = 0;
      column < 4;
      column++) {
        frames.add(
          Sprite(
            image,
            srcPosition: Vector2(
              column.toDouble() *
                  frameWidth,
              row.toDouble() *
                  frameHeight,
            ),
            srcSize: Vector2(
              frameWidth,
              frameHeight,
            ),
          ),
        );
      }
    }

    animation =
        SpriteAnimation.spriteList(
          frames,
          stepTime:
          _animationSpeed(),
          loop: true,
        );
  }

  // ============================================================
  // STATIC FALLBACK
  // ============================================================

  Future<void> _loadStaticBoss(
      String number,
      ) async {
    final image =
    await game.images.load(
      'bosses/boss_$number.png',
    );

    animation =
        SpriteAnimation.spriteList(
          [
            Sprite(
              image,
            ),
          ],
          stepTime: 1,
          loop: true,
        );
  }

  // ============================================================
  // ANIMATION SPEED BY LEVEL
  // ============================================================

  double _animationSpeed() {
    if (level <= 2) {
      return 0.100;
    }

    if (level <= 5) {
      return 0.095;
    }

    if (level <= 10) {
      return 0.085;
    }

    return 0.075;
  }

  // ============================================================
  // SIZE BY LEVEL
  // ============================================================

  Vector2 _bossSize() {
    switch (level) {
      case 1:
        return Vector2(
          160,
          160,
        );

      case 2:
        return Vector2(
          175,
          175,
        );

      case 3:
        return Vector2(
          165,
          165,
        );

      case 4:
        return Vector2(
          170,
          170,
        );

      case 5:
        return Vector2(
          185,
          185,
        );

      case 6:
      case 7:
        return Vector2(
          170,
          170,
        );

      case 8:
      case 9:
        return Vector2(
          178,
          178,
        );

      case 10:
        return Vector2(
          192,
          192,
        );

      case 11:
      case 12:
        return Vector2(
          180,
          180,
        );

      case 13:
      case 14:
        return Vector2(
          188,
          188,
        );

      case 15:
        return Vector2(
          205,
          205,
        );

      default:
        return Vector2(
          170,
          170,
        );
    }
  }

  // ============================================================
  // FOLLOW REAL BOSS
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(
      dt,
    );

    if (!boss.isMounted) {
      removeFromParent();
      return;
    }

    position.setFrom(
      boss.position,
    );

    if (_animatedBoss) {
      animationTicker
          ?.paused = false;
    }
  }

  // ============================================================
  // GROUND SHADOW
  // ============================================================

  @override
  void render(
      Canvas canvas,
      ) {
    final shadowWidth =
        size.x *
            0.60;

    final shadowHeight =
        size.y *
            0.075;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          size.x / 2,
          size.y - 4,
        ),
        width:
        shadowWidth,
        height:
        shadowHeight,
      ),
      Paint()
        ..color =
        Colors.black
            .withValues(
          alpha: 0.42,
        ),
    );

    super.render(
      canvas,
    );
  }
}