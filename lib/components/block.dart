import 'dart:math';
import 'package:breaking_blocks/components/ball.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

const List<MaterialColor> kBlockColors = [
  Colors.red,
  Colors.blue,
  Colors.green,
  Colors.yellow,
  Colors.purple,
  Colors.orange,
];

class BlockComponent extends RectangleComponent with CollisionCallbacks {
  BlockComponent({required this.blockSize, required this.onBlockRemove})
      : super(
          size: blockSize,
          paint: Paint()
            ..color = kBlockColors[Random().nextInt(kBlockColors.length)],
        );

  final Vector2 blockSize;
  final Future<void> Function() onBlockRemove;

  @override
  Future<void> onLoad() async {
    final blockHitBox = RectangleHitbox(
      size: size,
    );
    await add(blockHitBox);
    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is BallComponent) {
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  Future<void> onRemove() async {
    await onBlockRemove();
    super.onRemove();
  }
}
