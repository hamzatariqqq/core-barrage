import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/blue_soldier.dart';

class AirstrikeZone
    extends PositionComponent {
  AirstrikeZone({
    required Vector2 position,
    required this.radius,
    this.warningDuration = 1.6,
    this.damage = 45,
  }) : super(
    position: position,
    size: Vector2.all(
      radius * 2,
    ),
    anchor: Anchor.center,
    priority: 70,
  );

  final double radius;

  final double warningDuration;

  final double damage;

  double _elapsed = 0;

  bool _exploded = false;

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    if (!_exploded &&
        _elapsed >=
            warningDuration) {
      _explode();
    }

    if (_elapsed >
        warningDuration + .45) {
      removeFromParent();
    }
  }

  void _explode() {
    if (_exploded) {
      return;
    }

    _exploded = true;

    final world =
        parent;

    if (world == null) {
      return;
    }

    final soldiers =
    world.children
        .whereType<
        BlueSoldier>()
        .toList();

    for (final soldier
    in soldiers) {
      final distance =
      soldier.position.distanceTo(
        position,
      );

      if (distance <= radius) {
        soldier.hit(
          damage: damage,
        );
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center =
    Offset(
      size.x / 2,
      size.y / 2,
    );

    if (!_exploded) {
      final pulse =
          .35 +
              sin(_elapsed * 9) *
                  .18;

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color =
          Colors.red.withValues(
            alpha: pulse.clamp(
              .12,
              .55,
            ),
          )
          ..style =
              PaintingStyle.fill,
      );

      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color =
          Colors.redAccent
              .withValues(
            alpha: .9,
          )
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      canvas.drawLine(
        Offset(
          center.dx - 13,
          center.dy,
        ),
        Offset(
          center.dx + 13,
          center.dy,
        ),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );

      canvas.drawLine(
        Offset(
          center.dx,
          center.dy - 13,
        ),
        Offset(
          center.dx,
          center.dy + 13,
        ),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2,
      );

      return;
    }

    final explosionProgress =
    ((_elapsed -
        warningDuration) /
        .45)
        .clamp(
      0.0,
      1.0,
    );

    final explosionRadius =
        radius *
            (.35 +
                explosionProgress *
                    .8);

    final alpha =
        1 -
            explosionProgress;

    canvas.drawCircle(
      center,
      explosionRadius,
      Paint()
        ..color =
        Colors.orange.withValues(
          alpha: alpha,
        ),
    );

    canvas.drawCircle(
      center,
      explosionRadius * .55,
      Paint()
        ..color =
        Colors.yellow.withValues(
          alpha: alpha,
        ),
    );
  }
}