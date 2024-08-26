import 'package:breaking_blocks/components/ball.dart';
import 'package:breaking_blocks/components/count_down_text.dart';
import 'package:breaking_blocks/components/my_text_button.dart';
import 'package:breaking_blocks/components/paddle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/block.dart';

void main() {
  runApp(MaterialApp(
    home: SafeArea(child: GameWidget(game: MyGame())),
  ));
}

const int kGameTryCount = 3;

class MyGame extends FlameGame with HasCollisionDetection {
  int failedCount = kGameTryCount;

  bool get isGameOver => failedCount == 0;

  bool get isCleared =>
      children.whereType<BlockComponent>().isEmpty && failedCount > 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final paddle = PaddleComponent(draggingPaddle: draggingPaddle);
    final paddleSize = paddle.size;
    paddle
      ..position.x = size.x / 2 - paddleSize.x / 2
      ..position.y = size.y - paddleSize.y - 50;

    await addMyTextButton('Start!');

    await addAll([ScreenHitbox(), paddle]);

    await resetBlocks();
  }

  Future<void> resetBall() async {
    final ball = BallComponent(onBallRemove: onBallRemove);
    ball.position
      ..x = size.x / 2 - ball.size.x / 2
      ..y = size.y / 2 - ball.size.y / 2;
    await add(ball);
  }

  Future<void> onBallRemove() async {
    if (!isCleared) {
      failedCount--;
      if (isGameOver) {
        await addMyTextButton('Game Over!');
      } else {
        await addMyTextButton('Retry');
      }
    }
  }

  Future<void> resetBlocks() async {
    children.whereType<BlockComponent>().forEach((block) {
      block.removeFromParent();
    });
    final sizeX = (size.x - 50 * 2 - 5 * 2) / 3;
    final sizeY = (size.y * (1 / 3) - 50 - 5 * 4) / 3;
    final blocks = List.generate(
      3,
      (i) => List.generate(
        2,
        (j) {
          final block = BlockComponent(
              blockSize: Vector2(sizeX, sizeY), onBlockRemove: onBlockRemove);
          block.position
            ..x = 50 + (sizeX + 5) * i
            ..y = 50 + (sizeY + 5) * j;
          return block;
        },
      ),
    ).expand((element) => element).toList();
    await addAll(blocks);
  }

  Future<void> onBlockRemove() async {
    if (isCleared) {
      await addMyTextButton('Clear!');
      children.whereType<BallComponent>().forEach((ball) {
        ball.removeFromParent();
      });
    }
  }

  void draggingPaddle(DragUpdateEvent event) {
    final paddle = children.whereType<PaddleComponent>().first;

    paddle.position.x += event.localDelta.x;

    if (paddle.position.x < 0) {
      paddle.position.x = 0;
    }
    if (paddle.position.x > size.x - paddle.size.x) {
      paddle.position.x = size.x - paddle.size.x;
    }
  }

  Future<void> addMyTextButton(String text) async {
    final myTextButton = MyTextButton(
      text,
      onTapDownMyTextButton: onTapDownMyTextButton,
      renderMyTextButton: renderMyTextButton,
    );

    myTextButton.position
      ..x = size.x / 2 - myTextButton.size.x / 2
      ..y = size.y / 2 - myTextButton.size.y / 2;

    await add(myTextButton);
  }

  Future<void> onTapDownMyTextButton() async {
    children.whereType<MyTextButton>().forEach((button) {
      button.removeFromParent();
    });
    if (isCleared || isGameOver) {
      await resetBlocks();
      failedCount = kGameTryCount;
    }

    await countdown();
    await resetBall();
  }

  void renderMyTextButton(Canvas canvas) {
    final myTextButton = children.whereType<MyTextButton>().first;
    final rect = Rect.fromLTWH(
      -10,
      -10,
      myTextButton.size.x + 20,
      myTextButton.size.y + 20,
    );
    final bgPaint = Paint()..color = Colors.blue;
    canvas.drawRect(rect, bgPaint);
  }

  Future<void> countdown() async {
    for (var i = 3; i > 0; i--) {
      final countdownText = CountDownTextComponent(count: i);

      countdownText.position
        ..x = size.x / 2 - countdownText.size.x / 2
        ..y = size.y / 2 - countdownText.size.y / 2;

      await add(countdownText);

      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }
}
