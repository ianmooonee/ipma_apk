import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/hourly_forecast.dart';
import '../services/weather_icons.dart';

class HourlyStrip extends StatelessWidget {
  final List<HourlyForecast> hours;
  final bool compact;

  const HourlyStrip({super.key, required this.hours, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcoming = hours
        .where((h) => h.date.isAfter(
              DateTime.now().subtract(const Duration(hours: 1)),
            ))
        .take(24)
        .toList();
    final source = upcoming.isEmpty ? hours.take(24).toList() : upcoming;

    final minT = source
        .map((h) => h.tMed)
        .fold<double>(double.infinity, (a, b) => a < b ? a : b);
    final maxT = source
        .map((h) => h.tMed)
        .fold<double>(-double.infinity, (a, b) => a > b ? a : b);

    final height = compact ? 78.0 : 150.0;
    final cellWidth = compact ? 44.0 : 60.0;
    final padding = compact
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: 16);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: source.length,
        separatorBuilder: (_, __) => SizedBox(width: compact ? 2 : 6),
        itemBuilder: (context, i) {
          final h = source[i];
          final v = weatherVisualFor(h.idWeatherType);
          final hour = DateFormat('HH').format(h.date);
          final ratio =
              (maxT - minT) <= 0.0001 ? 0.5 : (h.tMed - minT) / (maxT - minT);
          if (compact) {
            return SizedBox(
              width: cellWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${h.tMed.round()}°',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(v.icon, size: 22, color: v.gradient.last),
                  const SizedBox(height: 4),
                  Text(
                    '${hour}h',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container(
            width: cellWidth,
            decoration: BoxDecoration(
              color: i == 0
                  ? theme.colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${h.tMed.round()}°',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 28,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 3,
                      height: 10 + ratio * 18,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: v.gradient,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(v.icon, size: 28, color: v.gradient.last),
                const SizedBox(height: 4),
                Text(
                  '${hour}h',
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
