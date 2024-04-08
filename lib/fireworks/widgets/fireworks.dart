import 'package:flutter/widgets.dart';
import 'package:wheel/fireworks/foundation/controller.dart';
import 'package:wheel/fireworks/rendering/fireworks.dart';

class Fireworks extends LeafRenderObjectWidget {
  const Fireworks({
    super.key,
    required this.controller
  });

  /// The controller that manages the fireworks and tells the render box what
  /// and when to paint.
  final FireworkController controller;


  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFireworks(
      controller: controller,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderFireworks renderObject) {
    renderObject.controller = controller;
  }
}
