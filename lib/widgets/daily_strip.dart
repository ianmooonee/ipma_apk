import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/daily_forecast.dart';
import '../models/uv_forecast.dart';
import '../services/weather_icons.dart';

Color _uvColor(double uv) {
  if (uv < 3) return const Color(0xFF43A047);
  if (uv < 6) return const Color(0xFFFBC02D);
  if (uv < 8) return const Color(0xFFFB8C00);
  if (uv < 11) return const Color(0xFFE53935);
  return const Color(0xFF8E24AA);
}

class DailyStrip extends StatelessWidget {
  final List<DailyForecast> days;
  final List<UvDay> uv;

  const DailyStrip({super.key, required this.days, this.uv = const []});

  UvDay? _uvFor(DateTime date) {
    for (final u in uv) {
      if (u.date.year == date.year &&
          u.date.month == date.month &&
          u.date.day == date.day) {
        return u;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 188,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = days[i];
          final v = weatherVisualFor(d.idWeatherType);
          final weekday = DateFormat('EEE', 'pt_PT').format(d.date);
          final dayOfMonth = DateFormat('d/M').format(d.date);
          final u = _uvFor(d.date);
          return Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  weekday.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dayOfMonth,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Icon(v.icon, size: 36, color: v.gradient.last),
                const SizedBox(height: 8),
                _Range(min: d.tMin, max: d.tMax),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 12,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${d.precipitaProb.round()}%',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _UvPill(uv: u),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UvPill extends StatelessWidget {
  final UvDay? uv;
  const _UvPill({required this.uv});

  @override
  Widget build(BuildContext context) {
    final u = uv;
    if (u == null) {
      return const SizedBox(height: 18);
    }
    final color = _uvColor(u.iUv);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'UV ${u.iUv.toStringAsFixed(1)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _Range extends StatelessWidget {
  final double min;
  final double max;

  const _Range({required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${min.round()}°',
          style: t.bodyMedium?.copyWith(color: Colors.blueGrey),
        ),
        const SizedBox(width: 6),
        Text(
          '${max.round()}°',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
