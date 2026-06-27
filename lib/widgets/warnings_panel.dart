import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_warning.dart';

const _levelColors = <WarningLevel, Color>{
  WarningLevel.green: Color(0xFF43A047),
  WarningLevel.yellow: Color(0xFFFBC02D),
  WarningLevel.orange: Color(0xFFFB8C00),
  WarningLevel.red: Color(0xFFE53935),
  WarningLevel.unknown: Color(0xFF9E9E9E),
};

const _levelLabels = <WarningLevel, String>{
  WarningLevel.green: 'Verde',
  WarningLevel.yellow: 'Amarelo',
  WarningLevel.orange: 'Laranja',
  WarningLevel.red: 'Vermelho',
  WarningLevel.unknown: '—',
};

class WarningsPanel extends StatelessWidget {
  final List<WeatherWarning> warnings;

  const WarningsPanel({super.key, required this.warnings});

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    // Only show warnings that haven't ended and aren't green (informational)
    final now = DateTime.now();
    final active =
        warnings.where((w) => w.endTime.isAfter(now) && w.isActive).toList();

    if (active.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

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
              Icon(Icons.warning_amber_rounded, color: onSurface),
              const SizedBox(width: 8),
              Text(
                'Avisos meteorológicos',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...active.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _WarningRow(warning: w),
              )),
        ],
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  final WeatherWarning warning;
  const _WarningRow({required this.warning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final color = _levelColors[warning.level]!;
    final fmt = DateFormat('d/M HH:mm', 'pt_PT');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  warning.awarenessTypeName,
                  style: TextStyle(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _levelLabels[warning.level]!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${fmt.format(warning.startTime)} → ${fmt.format(warning.endTime)}',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          if (warning.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              warning.text,
              style: TextStyle(color: onSurface, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
