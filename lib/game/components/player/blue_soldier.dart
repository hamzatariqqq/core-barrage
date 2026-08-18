import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BlueSoldier extends SpriteAnimationComponent
    with HasGameReference<FlameGame> {
  BlueSoldier({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(34, 44),
    anchor: Anchor.center,
    priority: 10,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = await game.images.load(
      'player/run/blue_soldier_run.png',
    );

    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: 0.10,
        textureSize: Vector2(256, 256),
        loop: true,
      ),
    );
  }
}