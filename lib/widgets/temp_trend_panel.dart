import 'package:flutter/material.dart';

typedef TempPoint = ({DateTime date, double value});

class TempTrendPanel extends StatelessWidget {
  final List<TempPoint> points;
  const TempTrendPanel({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final subtle = onSurface.withValues(alpha: 0.6);
    final values = points.map((p) => p.value).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final avg = values.reduce((a, b) => a + b) / values.length;
    final last = values.last;
    final delta = last - avg;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Temperatura — últimos ${points.length} dias',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 72,
            child: CustomPaint(
              size: Size.infinite,
              painter: _SparkPainter(
                points: points,
                color: onSurface,
                axisColor: onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _TrendStat(label: 'Mín.', value: '${minV.toStringAsFixed(1)}°'),
              const SizedBox(width: 18),
              _TrendStat(label: 'Méd.', value: '${avg.toStringAsFixed(1)}°'),
              const SizedBox(width: 18),
              _TrendStat(label: 'Máx.', value: '${maxV.toStringAsFixed(1)}°'),
              const Spacer(),
              Text(
                '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}° vs. média',
                style: TextStyle(color: subtle, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendStat extends StatelessWidget {
  final String label;
  final String value;
  const _TrendStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                color: onSurface, fontSize: 14, fontWeight: FontWeight.w600)),
        Text(label,
            style: TextStyle(
                color: onSurface.withValues(alpha: 0.55), fontSize: 11)),
      ],
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<TempPoint> points;
  final Color color;
  final Color axisColor;
  _SparkPainter({
    required this.points,
    required this.color,
    required this.axisColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    const labelHeight = 14.0;
    final chartHeight = size.height - labelHeight;
    final values = points.map((p) => p.value).toList();
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : (maxV - minV);
    final dx = size.width / (points.length - 1);

    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = chartHeight - ((points[i].value - minV) / range) * chartHeight;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fill = Path.from(path)
      ..lineTo(size.width, chartHeight)
      ..lineTo(0, chartHeight)
      ..close();
    canvas.drawPath(
      fill,
      Paint()..color = color.withValues(alpha: 0.08),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    const tickCount = 5;
    for (var i = 0; i < tickCount; i++) {
      final idx = (i * (points.length - 1) / (tickCount - 1)).round();
      final p = points[idx];
      final label = '${p.date.day}/${p.date.month}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: axisColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final centerX = idx * dx;
      double x = centerX - tp.width / 2;
      if (i == 0) x = 0;
      if (i == tickCount - 1) x = size.width - tp.width;
      tp.paint(canvas, Offset(x, chartHeight + 2));
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.points != points || old.color != color;
}
