import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;

  const CustomCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 18.0,
        height: 18.0,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CustomPaint(
          painter: CheckPainter(value),
        ),
      ),
    );
  }
}

class CheckPainter extends CustomPainter {
  final bool isChecked;

  CheckPainter(this.isChecked);

  @override
  void paint(Canvas canvas, Size size) {
    if (isChecked) {
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(size.width * 0.25, size.height * 0.5)
        ..lineTo(size.width * 0.5, size.height * 0.75)
        ..lineTo(size.width * 0.75, size.height * 0.25);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
