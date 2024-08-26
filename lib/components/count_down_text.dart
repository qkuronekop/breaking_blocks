import 'package:flame/components.dart';
import 'package:flutter/material.dart';

const TextStyle kCountdownTextStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 160,
);

class CountDownTextComponent extends TextComponent {
  CountDownTextComponent({required this.count})
      : super(
            size: Vector2.all(200),
            textRenderer: TextPaint(
              style: kCountdownTextStyle,
            ),
            text: '$count');

  final int count;

  @override
  Future<void> render(Canvas canvas) async {
    super.render(canvas);
    await Future<void>.delayed(const Duration(seconds: 1));
    removeFromParent();
  }
}
