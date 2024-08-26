import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PaddleComponent extends RectangleComponent
    with CollisionCallbacks, DragCallbacks {
  PaddleComponent({required this.draggingPaddle})
      : super(
          size: Vector2(100, 20),
          paint: Paint()..color = Colors.blue,
        );

  final void Function(DragUpdateEvent event) draggingPaddle;

  @override
  void onDragUpdate(DragUpdateEvent event) {
    draggingPaddle(event);
    super.onDragUpdate(event);
  }

  @override
  Future<void> onLoad() async {
    final paddleHitBox = RectangleHitbox(
      size: size,
    );
    await add(paddleHitBox);
    return super.onLoad();
  }
}
