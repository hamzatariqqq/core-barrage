import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Level2IndustrialBackground extends PositionComponent {
  Level2IndustrialBackground({
    required this.gameSize,
    this.scrollSpeed = 95,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: -1000,
  );

  final Vector2 gameSize;

  final double scrollSpeed;

  double _offset = 0;

  double _slowOffset = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _offset += scrollSpeed * dt;

    _slowOffset += scrollSpeed * .42 * dt;

    if (_offset >= 150) {
      _offset -= 150;
    }

    if (_slowOffset >= 240) {
      _slowOffset -= 240;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final width = gameSize.x;
    final height = gameSize.y;

    final roadLeft = width * .22;
    final roadRight = width * .78;
    final roadWidth =
        roadRight - roadLeft;

    // ==========================================================
    // BASE
    // ==========================================================

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        width,
        height,
      ),
      Paint()
        ..color = const Color(
          0xFF081117,
        ),
    );

    // ==========================================================
    // OUTER INDUSTRIAL FLOOR
    // ==========================================================

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        roadLeft,
        height,
      ),
      Paint()
        ..color = const Color(
          0xFF111D23,
        ),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        roadRight,
        0,
        width - roadRight,
        height,
      ),
      Paint()
        ..color = const Color(
          0xFF111D23,
        ),
    );

    // ==========================================================
    // MAIN ROAD
    // ==========================================================

    final roadRect = Rect.fromLTWH(
      roadLeft,
      0,
      roadWidth,
      height,
    );

    canvas.drawRect(
      roadRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(
              0xFF121C22,
            ),
            Color(
              0xFF273238,
            ),
            Color(
              0xFF2D393F,
            ),
            Color(
              0xFF273238,
            ),
            Color(
              0xFF121C22,
            ),
          ],
        ).createShader(
          roadRect,
        ),
    );

    // ==========================================================
    // ROAD SIDE RECESSES
    // ==========================================================

    canvas.drawRect(
      Rect.fromLTWH(
        roadLeft,
        0,
        12,
        height,
      ),
      Paint()
        ..color = const Color(
          0xFF091217,
        ),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        roadRight - 12,
        0,
        12,
        height,
      ),
      Paint()
        ..color = const Color(
          0xFF091217,
        ),
    );

    // ==========================================================
    // ROAD EDGE METAL
    // ==========================================================

    final metalPaint = Paint()
      ..color = const Color(
        0xFF66818D,
      )
      ..strokeWidth = 2.5;

    canvas.drawLine(
      Offset(
        roadLeft + 12,
        0,
      ),
      Offset(
        roadLeft + 12,
        height,
      ),
      metalPaint,
    );

    canvas.drawLine(
      Offset(
        roadRight - 12,
        0,
      ),
      Offset(
        roadRight - 12,
        height,
      ),
      metalPaint,
    );

    // ==========================================================
    // CYAN EDGE LIGHTS
    // ==========================================================

    final cyanPaint = Paint()
      ..color = const Color(
        0xFF25CFFF,
      ).withValues(
        alpha: .72,
      );

    _drawEdgeLights(
      canvas,
      x: roadLeft + 18,
      height: height,
      paint: cyanPaint,
    );

    _drawEdgeLights(
      canvas,
      x: roadRight - 18,
      height: height,
      paint: cyanPaint,
    );

    // ==========================================================
    // CENTRAL ROAD MARKERS
    // ==========================================================

    _drawCenterMarkers(
      canvas,
      centerX: width / 2,
      height: height,
    );

    // ==========================================================
    // ROAD PLATE SEAMS
    // ==========================================================

    _drawRoadSeams(
      canvas,
      roadLeft: roadLeft,
      roadRight: roadRight,
      height: height,
    );

    // ==========================================================
    // INDUSTRIAL SIDE MODULES
    // ==========================================================

    _drawIndustrialSide(
      canvas,
      left: true,
    );

    _drawIndustrialSide(
      canvas,
      left: false,
    );

    // ==========================================================
    // ROAD DAMAGE / SCRATCHES
    // ==========================================================

    _drawRoadWear(
      canvas,
      roadLeft: roadLeft,
      roadWidth: roadWidth,
      height: height,
    );

    // ==========================================================
    // DISTANT FACTORY HAZE
    // ==========================================================

    final hazeRect = Rect.fromLTWH(
      0,
      0,
      width,
      height * .27,
    );

    canvas.drawRect(
      hazeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(
              0xFF2B6070,
            ).withValues(
              alpha: .32,
            ),
            const Color(
              0xFF15313D,
            ).withValues(
              alpha: .12,
            ),
            Colors.transparent,
          ],
        ).createShader(
          hazeRect,
        ),
    );

    // ==========================================================
    // SUBTLE VIGNETTE
    // ==========================================================

    final vignetteRect = Rect.fromLTWH(
      0,
      0,
      width,
      height,
    );

    canvas.drawRect(
      vignetteRect,
      Paint()
        ..shader = RadialGradient(
          radius: .85,
          colors: [
            Colors.transparent,
            Colors.black.withValues(
              alpha: .18,
            ),
          ],
        ).createShader(
          vignetteRect,
        ),
    );
  }

  // ============================================================
  // CENTER ROAD MARKERS
  // ============================================================

  void _drawCenterMarkers(
      Canvas canvas, {
        required double centerX,
        required double height,
      }) {
    final markerPaint = Paint()
      ..color = const Color(
        0xFFFFB52E,
      ).withValues(
        alpha: .78,
      );

    const markerHeight = 26.0;
    const spacing = 90.0;

    double y =
        -spacing + _offset;

    while (y < height + spacing) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            centerX - 2.5,
            y,
            5,
            markerHeight,
          ),
          const Radius.circular(
            2,
          ),
        ),
        markerPaint,
      );

      y += spacing;
    }
  }

  // ============================================================
  // EDGE LIGHTS
  // ============================================================

  void _drawEdgeLights(
      Canvas canvas, {
        required double x,
        required double height,
        required Paint paint,
      }) {
    const segmentHeight = 24.0;
    const spacing = 72.0;

    double y =
        -spacing + _offset;

    while (y < height + spacing) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x - 1.5,
            y,
            3,
            segmentHeight,
          ),
          const Radius.circular(
            2,
          ),
        ),
        paint,
      );

      y += spacing;
    }
  }

  // ============================================================
  // ROAD SEAMS
  // ============================================================

  void _drawRoadSeams(
      Canvas canvas, {
        required double roadLeft,
        required double roadRight,
        required double height,
      }) {
    final seamPaint = Paint()
      ..color = Colors.black.withValues(
        alpha: .23,
      )
      ..strokeWidth = 1.5;

    const spacing = 150.0;

    double y =
        -spacing + _offset;

    int row = 0;

    while (y < height + spacing) {
      canvas.drawLine(
        Offset(
          roadLeft + 18,
          y,
        ),
        Offset(
          roadRight - 18,
          y,
        ),
        seamPaint,
      );

      final boltPaint = Paint()
        ..color = const Color(
          0xFF65747B,
        ).withValues(
          alpha: .40,
        );

      final boltY = y + 4;

      final boltXs = <double>[
        roadLeft + 27,
        roadLeft + 52,
        roadRight - 52,
        roadRight - 27,
      ];

      for (final x in boltXs) {
        canvas.drawCircle(
          Offset(
            x,
            boltY,
          ),
          row.isEven ? 1.5 : 1.2,
          boltPaint,
        );
      }

      row++;

      y += spacing;
    }
  }

  // ============================================================
  // INDUSTRIAL SIDES
  // ============================================================

  void _drawIndustrialSide(
      Canvas canvas, {
        required bool left,
      }) {
    final width = gameSize.x;
    final height = gameSize.y;

    final roadLeft = width * .22;
    final roadRight = width * .78;

    final sideStart =
    left ? 0.0 : roadRight;

    final sideWidth =
    left
        ? roadLeft
        : width - roadRight;

    const segment = 150.0;

    double y =
        -segment + _offset;

    int index = 0;

    while (y < height + segment) {
      final alternate =
          index % 3;

      final bodyColor =
      alternate == 0
          ? const Color(
        0xFF25363F,
      )
          : alternate == 1
          ? const Color(
        0xFF17262E,
      )
          : const Color(
        0xFF1D3038,
      );

      final panelRect = Rect.fromLTWH(
        sideStart + 7,
        y + 7,
        max(
          10,
          sideWidth - 14,
        ),
        112,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          panelRect,
          const Radius.circular(
            7,
          ),
        ),
        Paint()
          ..color = bodyColor,
      );

      // Inner metal plate.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            panelRect.left + 7,
            panelRect.top + 9,
            max(
              8,
              panelRect.width - 14,
            ),
            42,
          ),
          const Radius.circular(
            4,
          ),
        ),
        Paint()
          ..color = const Color(
            0xFF0C171D,
          ),
      );

      // Large pipe near road.
      final pipeX =
      left
          ? sideStart +
          sideWidth -
          14
          : sideStart + 14;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            pipeX - 4,
            y + 13,
            8,
            91,
          ),
          const Radius.circular(
            4,
          ),
        ),
        Paint()
          ..color = const Color(
            0xFF607984,
          ),
      );

      // Pipe connector.
      canvas.drawRect(
        Rect.fromLTWH(
          pipeX - 7,
          y + 42,
          14,
          8,
        ),
        Paint()
          ..color = const Color(
            0xFF344750,
          ),
      );

      // Warning stripe.
      canvas.drawRect(
        Rect.fromLTWH(
          sideStart + 11,
          y + 92,
          max(
            5,
            sideWidth - 22,
          ),
          5,
        ),
        Paint()
          ..color = const Color(
            0xFFFFA629,
          ).withValues(
            alpha: .74,
          ),
      );

      // Warning stripe dark sections.
      for (double sx =
          sideStart + 15;
      sx <
          sideStart +
              sideWidth -
              13;
      sx += 24) {
        canvas.drawRect(
          Rect.fromLTWH(
            sx,
            y + 92,
            10,
            5,
          ),
          Paint()
            ..color = const Color(
              0xFF352915,
            ).withValues(
              alpha: .75,
            ),
        );
      }

      // Industrial light.
      final lightColor =
      index.isEven
          ? const Color(
        0xFF39D8FF,
      )
          : const Color(
        0xFFFF6136,
      );

      final lightX =
      left
          ? sideStart + 19
          : sideStart +
          sideWidth -
          19;

      canvas.drawCircle(
        Offset(
          lightX,
          y + 26,
        ),
        6,
        Paint()
          ..color = lightColor.withValues(
            alpha: .15,
          ),
      );

      canvas.drawCircle(
        Offset(
          lightX,
          y + 26,
        ),
        2.8,
        Paint()
          ..color = lightColor,
      );

      // Small vents.
      for (int vent = 0;
      vent < 3;
      vent++) {
        final ventY =
            y +
                61 +
                vent * 7;

        canvas.drawRect(
          Rect.fromLTWH(
            sideStart + 19,
            ventY,
            max(
              7,
              sideWidth - 38,
            ),
            2,
          ),
          Paint()
            ..color = const Color(
              0xFF4A616B,
            ).withValues(
              alpha: .60,
            ),
        );
      }

      index++;

      y += segment;
    }

    _drawSlowLargeStructures(
      canvas,
      left: left,
    );
  }

  // ============================================================
  // LARGE SIDE STRUCTURES
  // ============================================================

  void _drawSlowLargeStructures(
      Canvas canvas, {
        required bool left,
      }) {
    final width = gameSize.x;
    final height = gameSize.y;

    final roadLeft = width * .22;
    final roadRight = width * .78;

    final sideStart =
    left ? 0.0 : roadRight;

    final sideWidth =
    left
        ? roadLeft
        : width - roadRight;

    const spacing = 240.0;

    double y =
        -spacing + _slowOffset;

    int index = 0;

    while (y < height + spacing) {
      if (index.isEven) {
        final structureX =
        left
            ? sideStart + 7
            : sideStart +
            sideWidth -
            31;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              structureX,
              y + 125,
              24,
              55,
            ),
            const Radius.circular(
              5,
            ),
          ),
          Paint()
            ..color = const Color(
              0xFF071015,
            ),
        );

        canvas.drawRect(
          Rect.fromLTWH(
            structureX + 7,
            y + 111,
            10,
            20,
          ),
          Paint()
            ..color = const Color(
              0xFF495D66,
            ),
        );

        canvas.drawCircle(
          Offset(
            structureX + 12,
            y + 142,
          ),
          4,
          Paint()
            ..color = const Color(
              0xFFFF7B31,
            ).withValues(
              alpha: .78,
            ),
        );
      }

      index++;

      y += spacing;
    }
  }

  // ============================================================
  // ROAD WEAR
  // ============================================================

  void _drawRoadWear(
      Canvas canvas, {
        required double roadLeft,
        required double roadWidth,
        required double height,
      }) {
    final random = Random(
      27,
    );

    final darkPaint = Paint()
      ..color = Colors.black.withValues(
        alpha: .16,
      )
      ..strokeWidth = 1.2;

    final lightPaint = Paint()
      ..color = const Color(
        0xFF71848D,
      ).withValues(
        alpha: .10,
      )
      ..strokeWidth = 1;

    for (int i = 0; i < 22; i++) {
      final x =
          roadLeft +
              25 +
              random.nextDouble() *
                  max(
                    1,
                    roadWidth - 50,
                  );

      final originalY =
          random.nextDouble() *
              height;

      final y =
          (originalY + _slowOffset) %
              height;

      final dx =
          random.nextDouble() *
              26 -
              13;

      final length =
          12 +
              random.nextDouble() * 24;

      canvas.drawLine(
        Offset(
          x,
          y,
        ),
        Offset(
          x + dx,
          y + length,
        ),
        i.isEven
            ? darkPaint
            : lightPaint,
      );
    }
  }
}