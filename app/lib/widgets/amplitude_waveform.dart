import 'package:flutter/material.dart';

class AmplitudeWaveform extends StatelessWidget {
  final List<double> samples;
  final Color? color;
  final double height;

  const AmplitudeWaveform({
    super.key,
    required this.samples,
    this.color,
    this.height = 64,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _WaveformPainter(samples: samples, color: c),
        size: Size.infinite,
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> samples;
  final Color color;

  const _WaveformPainter({required this.samples, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barWidth = size.width / samples.length;
    final midY = size.height / 2;

    for (int i = 0; i < samples.length; i++) {
      final x = i * barWidth + barWidth / 2;
      final amp = samples[i].clamp(0.05, 1.0);
      final halfH = (amp * midY * 0.9).clamp(2.0, midY);
      canvas.drawLine(Offset(x, midY - halfH), Offset(x, midY + halfH), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.samples != samples || old.color != color;
}
