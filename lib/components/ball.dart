import 'dart:math';
import 'dart:ui';

import 'package:breaking_blocks/components/block.dart';
import 'package:breaking_blocks/components/paddle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

const double kRad = pi / 180;
const double kBallNudgeSpeed = 300;
const int kBallRandomNumber = 5;

class BallComponent extends CircleComponent with CollisionCallbacks {
  BallComponent({required this.onBallRemove}) {
    radius = 10;
    paint = Paint()..color = Colors.white;

    final vx = 500 * cos(spawnAngle * kRad);
    final vy = 500 * sin(spawnAngle * kRad);
    velocity = Vector2(vx, vy);
  }

  final Future<void> Function() onBallRemove;

  late Vector2 velocity;
  bool isCollidedScreenHitBoxX = false;
  bool isCollidedScreenHitBoxY = false;

  double get spawnAngle {
    // メソッド追加
    final random = Random().nextDouble();
    final spawnAngle = lerpDouble(45, 135, random)!;
    return spawnAngle;
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    final hitBox = CircleHitbox(radius: radius);
    await add(hitBox);
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      final screenHitBoxRect = other.toAbsoluteRect();
      for (final point in intersectionPoints) {
        if (point.x == screenHitBoxRect.left && !isCollidedScreenHitBoxX) {
          velocity.x = -velocity.x;
          isCollidedScreenHitBoxX = true;
        }
        if (point.x.toInt() == screenHitBoxRect.right.toInt() &&
            !isCollidedScreenHitBoxX) {
          velocity.x = -velocity.x;
          isCollidedScreenHitBoxX = true;
        }
        if (point.y == screenHitBoxRect.top && !isCollidedScreenHitBoxY) {
          velocity.y = -velocity.y;
          isCollidedScreenHitBoxY = true;
        }
        if (point.y.toInt() == screenHitBoxRect.bottom.toInt() &&
            !isCollidedScreenHitBoxY) {
          removeFromParent();
        }
      }
      super.onCollision(intersectionPoints, other);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    isCollidedScreenHitBoxX = false;
    isCollidedScreenHitBoxY = false;
    super.onCollisionEnd(other);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    final collisionPoint = intersectionPoints.first;
    if (other is BlockComponent) {
      final blockRect = other.toAbsoluteRect();
      updateBallTrajectory(collisionPoint, blockRect);
    }
    if (other is PaddleComponent) {
      final paddleRect = other.toAbsoluteRect();
      updateBallTrajectory(collisionPoint, paddleRect);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void updateBallTrajectory(
    // メソッド追加
    Vector2 collisionPoint,
    Rect rect,
  ) {
    final isLeftHit = collisionPoint.x == rect.left;
    final isRightHit = collisionPoint.x == rect.right;
    final isTopHit = collisionPoint.y == rect.top;
    final isBottomHit = collisionPoint.y == rect.bottom;

    final isLeftOrRightHit = isLeftHit || isRightHit;
    final isTopOrBottomHit = isTopHit || isBottomHit;

    if (isLeftOrRightHit) {
      if (isRightHit && velocity.x > 0) {
        velocity.x += kBallNudgeSpeed;
        return;
      }

      if (isLeftHit && velocity.x < 0) {
        velocity.x -= kBallNudgeSpeed;
        return;
      }

      velocity.x = -velocity.x;
      return;
    }

    if (isTopOrBottomHit) {
      velocity.y = -velocity.y;
      if (Random().nextInt(kBallRandomNumber) % kBallRandomNumber == 0) {
        velocity.x += kBallNudgeSpeed;
      }
    }
  }

  @override
  Future<void> onRemove() async {
    await onBallRemove();
    super.onRemove();
  }
}
