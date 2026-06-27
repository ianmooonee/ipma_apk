import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/sea_forecast.dart';

class SeaPanel extends StatelessWidget {
  final List<SeaSnapshot> snapshots;
  final String? sourceName;

  const SeaPanel({super.key, required this.snapshots, this.sourceName});

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) return const SizedBox.shrink();
    final now = DateTime.now();
    final current = snapshots.firstWhere(
      (s) => s.date.isAfter(now.subtract(const Duration(hours: 1))),
      orElse: () => snapshots.last,
    );
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: onSurface.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waves, color: onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Estado do mar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (sourceName != null)
                Text(
                  sourceName!,
                  style: TextStyle(
                    color: onSurface.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SeaTile(
                  label: 'Ondulação',
                  value: current.waveHeight != null
                      ? '${current.waveHeight!.toStringAsFixed(1)} m'
                      : '—',
                ),
              ),
              Expanded(
                child: _CompassTile(direction: current.swellDir),
              ),
              Expanded(
                child: _SeaTile(
                  label: 'Período',
                  value: current.swellPeriod != null
                      ? '${current.swellPeriod!.toStringAsFixed(1)} s'
                      : '—',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (current.waterTemp != null)
            Row(
              children: [
                Icon(Icons.thermostat, color: onSurface.withValues(alpha: 0.6), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Água ${current.waterTemp!.toStringAsFixed(1)} °C',
                  style: TextStyle(color: onSurface, fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SeaTile extends StatelessWidget {
  final String label;
  final String value;
  const _SeaTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      children: [
        Text(value, style: TextStyle(color: onSurface, fontSize: 22, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }
}

class _CompassTile extends StatelessWidget {
  final String direction;
  const _CompassTile({required this.direction});

  static const _angles = <String, double>{
    'N': 0, 'NE': 45, 'E': 90, 'SE': 135,
    'S': 180, 'SO': 225, 'SW': 225, 'O': 270, 'W': 270, 'NO': 315, 'NW': 315,
  };

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final deg = _angles[direction] ?? 0;
    return Column(
      children: [
        Transform.rotate(
          angle: deg * math.pi / 180,
          child: Icon(Icons.navigation, color: onSurface, size: 28),
        ),
        const SizedBox(height: 4),
        Text(direction.isEmpty ? '—' : direction,
            style: TextStyle(color: onSurface, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text('Direção', style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }
}
