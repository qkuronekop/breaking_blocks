import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class MyTextButton extends TextComponent with TapCallbacks {
  MyTextButton(String text,
      {required this.onTapDownMyTextButton, required this.renderMyTextButton})
      : super(
          text: text,
          size: Vector2(300, 60),
          anchor: Anchor.centerLeft,
        );

  final Future<void> Function() onTapDownMyTextButton;
  final void Function(Canvas canvas) renderMyTextButton;

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    await onTapDownMyTextButton();
    super.onTapDown(event);
  }

  @override
  void render(Canvas canvas) {
    renderMyTextButton(canvas);
    super.render(canvas);
  }
}
