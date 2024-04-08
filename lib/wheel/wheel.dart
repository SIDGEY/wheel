import 'dart:math';

import 'package:flutter/material.dart';

class Wheel extends StatelessWidget {
  final _WheelPainter _painter;

  Wheel(List<String> items, {super.key}) : _painter = _WheelPainter(items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(builder: (context, constraints) {
        final radius = min(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          painter: _painter,
          size: Size.square(radius),
        );
      }),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> items;

  const _WheelPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    // Border
    final defaultStrokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.black45;
    var pivotOffset = size.center(const Offset(0.0, 0.0));
    var centerRadius = min(size.height, size.width) * 0.5 + 5;

    var paint = Paint()
      ..shader = const RadialGradient(
        radius: .6,
        colors: <Color>[
          Color.fromARGB(255, 255, 215, 0),
          Color.fromARGB(255, 218, 165, 32),
        ],
      ).createShader(Rect.fromCircle(
        center: pivotOffset,
        radius: centerRadius,
      ));
    canvas.drawCircle(pivotOffset, centerRadius, paint);
    canvas.drawCircle(pivotOffset, centerRadius, defaultStrokePaint);
    //End border

    double angle = (2 * pi) / items.length;
    double radius = min(size.width / 2, size.height / 2);
    Offset center = Offset(size.width / 2, size.height / 2);
    double startAngle = -angle / 2;

    // Position of the wheel on the outside of the wheel
    Offset textPosition = const Offset(-40, 0);

    for (int i = 0; i < items.length; i++) {
      final sectionStartAngle = startAngle + angle * i;
      final paint = Paint()..color = Colors.primaries[i % Colors.primaries.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), sectionStartAngle, angle, true, paint);

      // Text
      final textSpan = TextSpan(
        text: items[i],
        style: const TextStyle(
            color: Colors.white, fontSize: 12, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.end,
      );

      // Position and rotate text using canvas operations
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(sectionStartAngle + angle / 2);
      textPainter
        ..layout(minWidth: radius, maxWidth: radius)
        ..paint(canvas, textPosition);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
