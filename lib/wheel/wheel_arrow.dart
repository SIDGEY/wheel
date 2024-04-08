import 'package:flutter/material.dart';

class Arrow extends StatelessWidget {
  const Arrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(builder: (context, constraints) {
        return CustomPaint(
          painter: ArrowPainter(),
          size: const Size.square(20),
        );
      }),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width + 2, size.height / 2 - 10);
    path.lineTo(size.width - 20, size.height / 2);
    path.lineTo(size.width + 2, size.height / 2 + 10);
    path.close();

    canvas.drawShadow(path, Colors.black, 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
