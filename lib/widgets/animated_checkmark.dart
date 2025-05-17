import 'package:flutter/material.dart';

class AnimatedCheckmark extends StatefulWidget {
  final double size;
  final Duration duration;
  const AnimatedCheckmark({Key? key, this.size = 64, this.duration = const Duration(milliseconds: 800)}) : super(key: key);

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.square(widget.size),
          painter: _CheckmarkPainter(_animation.value),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  _CheckmarkPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = size.width * 0.12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.55);
    path.lineTo(size.width * 0.45, size.height * 0.8);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    final pathMetric = path.computeMetrics().first;
    final extractPath = pathMetric.extractPath(0, pathMetric.length * progress);
    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) => oldDelegate.progress != progress;
} 