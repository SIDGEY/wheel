import 'dart:math';

import 'package:wheel/fireworks/foundation/object.dart';

/// Firework particle that is part of an explosion.
///
/// Inspired by https://codepen.io/whqet/pen/Auzch.
class FireworkParticle extends FireworkObjectWithTrail {
  FireworkParticle({
    required super.random,
    required super.position,
    required double hueBaseValue,
    required super.size,
  })  : angle = random.nextDouble() * 2 * pi,
        velocity = random.nextDouble() * 12 + 1,
        hue = hueBaseValue - 50 + random.nextDouble() * 100,
        brightness = .5 + random.nextDouble() * .3,
        alphaDecay = random.nextDouble() * .007 + .013,
        super(
          trailCount: size.toInt() * 2,
        );

  final double angle;

  double velocity;
  final double friction = .96;
  final double gravity = 2.35;

  final double hue;
  final double brightness;

  double alpha = 1;
  final double alphaDecay;

  @override
  void update() {
    super.update();

    velocity *= friction;

    position += Point(
      cos(angle) * velocity,
      sin(angle) * velocity + gravity,
    );

    alpha -= alphaDecay;
  }
}
