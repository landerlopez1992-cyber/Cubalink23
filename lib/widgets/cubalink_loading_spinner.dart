import 'package:flutter/material.dart';

class CubalinkLoadingSpinner extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  const CubalinkLoadingSpinner({
    Key? key,
    this.size = 50.0,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _CubalinkSpinnerPainter(
          primaryColor: primaryColor ?? Color(0xFFFF9800),
          secondaryColor: secondaryColor ?? Color(0xFF37474F),
        ),
      ),
    );
  }
}

class _CubalinkSpinnerPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  _CubalinkSpinnerPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Fondo circular
    final backgroundPaint = Paint()
      ..color = secondaryColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Spinner principal
    final spinnerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Dibujar arco de spinner
    final rect = Rect.fromCircle(center: center, radius: radius - 2);
    canvas.drawArc(
      rect,
      -1.57, // -90 grados en radianes
      2.0,   // 120 grados en radianes
      false,
      spinnerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
