import 'package:flame/components.dart';
import 'package:flame/game.dart';

class ScrollingBattlefield extends PositionComponent
    with HasGameReference<FlameGame> {
  ScrollingBattlefield({
    required this.gameSize,
  }) : super(
    size: gameSize,
    priority: -100,
  );

  final Vector2 gameSize;

  late SpriteComponent background1;
  late SpriteComponent background2;

  static const double scrollSpeed = 90;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = await game.images.load(
      'environment/battlefield/battlefield_01.png',
    );

    final sprite = Sprite(image);

    background1 = SpriteComponent(
      sprite: sprite,
      position: Vector2(0, 0),
      size: gameSize,
    );

    background2 = SpriteComponent(
      sprite: sprite,
      position: Vector2(0, -gameSize.y),
      size: gameSize,
    );

    add(background1);
    add(background2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    background1.position.y += scrollSpeed * dt;
    background2.position.y += scrollSpeed * dt;

    if (background1.position.y >= gameSize.y) {
      background1.position.y =
          background2.position.y - gameSize.y;
    }

    if (background2.position.y >= gameSize.y) {
      background2.position.y =
          background1.position.y - gameSize.y;
    }
  }
}