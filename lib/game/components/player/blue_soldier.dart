import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BlueSoldier extends RectangleComponent {
  BlueSoldier({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(14, 18),
    anchor: Anchor.center,
    paint: Paint()..color = const Color(0xFF5EDBFF),
  );
}