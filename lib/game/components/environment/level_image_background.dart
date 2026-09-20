import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class LevelImageBackground extends PositionComponent
    with HasGameReference<FlameGame> {
  LevelImageBackground({
    required Vector2 gameSize,
    required this.imagePath,
    this.scrollDuration = 60.0,
  }) : super(
    position: Vector2.zero(),
    size: gameSize,
    priority: -1000,
  );

  // ============================================================
  // CONFIG
  // ============================================================

  final String imagePath;

  /// How long the background should take to travel
  /// from the BOTTOM of the image to the TOP.
  ///
  /// Level 2 = approximately 61 seconds.
  ///
  /// This is intentionally duration based rather than using
  /// a fixed scroll speed.
  ///
  /// It prevents:
  /// - background finishing too early
  /// - background becoming stuck halfway through gameplay
  /// - different phones scrolling at visually different timings
  final double scrollDuration;

  // ============================================================
  // IMAGE
  // ============================================================

  ui.Image? _image;

  // ============================================================
  // LONG IMAGE DATA
  // ============================================================

  double _worldHeight = 0.0;

  double _startY = 0.0;

  double _worldY = 0.0;

  double _elapsed = 0.0;

  bool _ready = false;

  bool _scrollable = false;

  bool _finished = false;

  // ============================================================
  // STATIC IMAGE DATA
  //
  // Levels 3-15 currently still use normal portrait images.
  // We keep support for those so they do not crash.
  // ============================================================

  double _staticWidth = 0.0;

  double _staticHeight = 0.0;

  double _staticX = 0.0;

  double _staticY = 0.0;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugPrint(
      'CORE BARRAGE BACKGROUND: loading $imagePath',
    );

    final loadedImage =
    await game.images.load(
      imagePath,
    );

    _image = loadedImage;

    final imageWidth =
    loadedImage.width.toDouble();

    final imageHeight =
    loadedImage.height.toDouble();

    // ==========================================================
    // LONG SCROLL CALCULATION
    //
    // Fit the image WIDTH exactly to game width.
    //
    // Example:
    //
    // Asset:
    // 1080 x 5760
    //
    // Phone width:
    // ~412
    //
    // Resulting battlefield:
    // ~412 x 2197
    //
    // Visible height:
    // ~914
    //
    // Travel:
    // ~1283 pixels
    // ==========================================================

    final widthScale =
        size.x / imageWidth;

    _worldHeight =
        imageHeight * widthScale;

    _scrollable =
        _worldHeight > size.y + 10.0;

    debugPrint(
      '========================================',
    );

    debugPrint(
      'CORE BARRAGE BACKGROUND',
    );

    debugPrint(
      'Asset: $imagePath',
    );

    debugPrint(
      'Original image: '
          '${loadedImage.width} x '
          '${loadedImage.height}',
    );

    debugPrint(
      'Game size: '
          '${size.x.toStringAsFixed(0)} x '
          '${size.y.toStringAsFixed(0)}',
    );

    debugPrint(
      'Width fitted height: '
          '${_worldHeight.toStringAsFixed(0)}',
    );

    debugPrint(
      'Scrollable: $_scrollable',
    );

    debugPrint(
      'Scroll duration: '
          '${scrollDuration.toStringAsFixed(1)} sec',
    );

    debugPrint(
      '========================================',
    );

    // ==========================================================
    // LONG BACKGROUND
    // ==========================================================

    if (_scrollable) {
      // Start from the BOTTOM section of the complete image.
      //
      // Example:
      //
      // Screen = 914
      // World  = 2197
      //
      // Start:
      //
      // 914 - 2197 = -1283
      //
      // Then the image slowly moves down until worldY = 0.

      _startY =
          size.y - _worldHeight;

      _worldY =
          _startY;

      _elapsed =
      0.0;

      _finished =
      false;

      debugPrint(
        'Background starting Y: '
            '${_startY.toStringAsFixed(1)}',
      );
    }

    // ==========================================================
    // SHORT BACKGROUND FALLBACK
    //
    // IMPORTANT:
    // This does NOT repeat the image.
    //
    // It uses a single cover-style image for unfinished
    // levels 3-15.
    // ==========================================================

    else {
      final scaleX =
          size.x / imageWidth;

      final scaleY =
          size.y / imageHeight;

      final coverScale =
      scaleX > scaleY
          ? scaleX
          : scaleY;

      _staticWidth =
          imageWidth * coverScale;

      _staticHeight =
          imageHeight * coverScale;

      _staticX =
          (size.x - _staticWidth) / 2;

      _staticY =
          (size.y - _staticHeight) / 2;

      debugPrint(
        'Using single-image static fallback.',
      );
    }

    _ready = true;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(
      double dt,
      ) {
    super.update(dt);

    if (!_ready ||
        _image == null ||
        !_scrollable ||
        _finished) {
      return;
    }

    _elapsed += dt;

    final safeDuration =
    scrollDuration <= 0
        ? 1.0
        : scrollDuration;

    // ==========================================================
    // NORMALIZED LEVEL PROGRESS
    //
    // 0.0 = bottom
    // 1.0 = top
    // ==========================================================

    final progress =
    (_elapsed / safeDuration)
        .clamp(
      0.0,
      1.0,
    );

    // ==========================================================
    // MOVE ONE SINGLE IMAGE
    //
    // NO:
    // - duplicate copy
    // - looping
    // - reset
    // - tiling
    //
    // Start:
    // _startY
    //
    // Finish:
    // 0
    // ==========================================================

    _worldY =
        _startY +
            ((0.0 - _startY) *
                progress);

    if (progress >= 1.0) {
      _worldY = 0.0;

      _finished = true;

      debugPrint(
        'CORE BARRAGE: background reached final fortress area.',
      );
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(
      Canvas canvas,
      ) {
    super.render(canvas);

    final image =
        _image;

    if (!_ready ||
        image == null) {
      return;
    }

    canvas.save();

    // Never render outside the game screen.
    canvas.clipRect(
      Rect.fromLTWH(
        0,
        0,
        size.x,
        size.y,
      ),
    );

    final sourceRect =
    Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    // ==========================================================
    // LONG SCROLLING IMAGE
    // ==========================================================

    if (_scrollable) {
      final destinationRect =
      Rect.fromLTWH(
        0,
        _worldY,
        size.x,
        _worldHeight,
      );

      canvas.drawImageRect(
        image,
        sourceRect,
        destinationRect,
        Paint()
          ..filterQuality =
              FilterQuality.high,
      );
    }

    // ==========================================================
    // NORMAL IMAGE
    //
    // One image only.
    // Never repeated.
    // ==========================================================

    else {
      final destinationRect =
      Rect.fromLTWH(
        _staticX,
        _staticY,
        _staticWidth,
        _staticHeight,
      );

      canvas.drawImageRect(
        image,
        sourceRect,
        destinationRect,
        Paint()
          ..filterQuality =
              FilterQuality.high,
      );
    }

    canvas.restore();

    // ==========================================================
    // GAMEPLAY VISIBILITY OVERLAY
    //
    // Very subtle dark grade at bottom.
    // Helps player / soldiers remain readable.
    // ==========================================================

    _drawGameplayGrade(
      canvas,
    );
  }

  // ============================================================
  // VISUAL GRADING
  // ============================================================

  void _drawGameplayGrade(
      Canvas canvas,
      ) {
    final screenRect =
    Rect.fromLTWH(
      0,
      0,
      size.x,
      size.y,
    );

    final paint =
    Paint()
      ..shader =
      const LinearGradient(
        begin:
        Alignment.topCenter,
        end:
        Alignment.bottomCenter,
        colors: [
          Color(
            0x00000000,
          ),
          Color(
            0x00000000,
          ),
          Color(
            0x10000000,
          ),
          Color(
            0x22000000,
          ),
        ],
        stops: [
          0.0,
          0.55,
          0.82,
          1.0,
        ],
      ).createShader(
        screenRect,
      );

    canvas.drawRect(
      screenRect,
      paint,
    );
  }

  // ============================================================
  // PUBLIC PROGRESS
  // ============================================================

  double get progress {
    if (!_ready) {
      return 0.0;
    }

    // Short/non-scrolling images are considered complete
    // backgrounds.
    if (!_scrollable) {
      return 1.0;
    }

    final safeDuration =
    scrollDuration <= 0
        ? 1.0
        : scrollDuration;

    return (_elapsed /
        safeDuration)
        .clamp(
      0.0,
      1.0,
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  bool get reachedEnd =>
      _scrollable &&
          _finished;

  bool get isScrollable =>
      _scrollable;
}