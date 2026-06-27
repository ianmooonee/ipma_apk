import 'package:flutter/material.dart';

import '../models/daily_forecast.dart';
import '../models/fire_risk.dart';
import '../models/hourly_forecast.dart';
import '../models/sea_forecast.dart';
import '../services/weather_icons.dart';
import 'hourly_strip.dart';
import 'sea_panel.dart';
import 'stat_chip.dart';
import 'temp_trend_panel.dart';

// IPMA wind speed classes (from wind-speed-daily-classe.json)
const _windClassLabels = <int, String>{
  1: 'Fraco', // ≤ 15 km/h
  2: 'Moderado', // 16–35 km/h
  3: 'Forte', // 36–55 km/h
  4: 'Muito forte', // > 55 km/h
};

Color _uvColor(double uv) {
  if (uv < 3) return const Color(0xFF43A047);
  if (uv < 6) return const Color(0xFFFBC02D);
  if (uv < 8) return const Color(0xFFFB8C00);
  if (uv < 11) return const Color(0xFFE53935);
  return const Color(0xFF8E24AA);
}

String _uvLabel(double uv) {
  if (uv < 3) return 'Baixo';
  if (uv < 6) return 'Moderado';
  if (uv < 8) return 'Alto';
  if (uv < 11) return 'M. alto';
  return 'Extremo';
}

const _fireLabels = <FireRiskLevel, String>{
  FireRiskLevel.reduzido: 'Reduzido',
  FireRiskLevel.moderado: 'Moderado',
  FireRiskLevel.elevado: 'Elevado',
  FireRiskLevel.muitoElevado: 'M. elevado',
  FireRiskLevel.maximo: 'Máximo',
  FireRiskLevel.unknown: '—',
};

const _fireColors = <FireRiskLevel, Color>{
  FireRiskLevel.reduzido: Color(0xFF43A047),
  FireRiskLevel.moderado: Color(0xFFFBC02D),
  FireRiskLevel.elevado: Color(0xFFFB8C00),
  FireRiskLevel.muitoElevado: Color(0xFFE53935),
  FireRiskLevel.maximo: Color(0xFF8E24AA),
  FireRiskLevel.unknown: Color(0xFF9E9E9E),
};

String _agoLabel(DateTime when) {
  final diff = DateTime.now().difference(when);
  if (diff.inMinutes < 1) return 'agora mesmo';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  final days = diff.inDays;
  return days == 1 ? 'há 1 dia' : 'há $days dias';
}

class TodayHero extends StatelessWidget {
  final String city;
  final DailyForecast today;
  final List<HourlyForecast> hourly;
  final DateTime? lastUpdated;
  final FireRisk? fireRisk;
  final List<SeaSnapshot> sea;
  final String? seaSourceName;
  final List<TempPoint> tempHistory20d;
  final VoidCallback onCityTap;
  final VoidCallback onRefresh;

  const TodayHero({
    super.key,
    required this.city,
    required this.today,
    required this.hourly,
    required this.lastUpdated,
    required this.fireRisk,
    required this.sea,
    required this.seaSourceName,
    required this.tempHistory20d,
    required this.onCityTap,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final v = weatherVisualFor(today.idWeatherType);
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final subtle = onSurface.withValues(alpha: 0.6);
    final fire = fireRisk;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onCityTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: onSurface, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            city,
                            style: TextStyle(
                              color: onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.expand_more, color: subtle, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: Icon(Icons.refresh, color: onSurface),
                tooltip: 'Atualizar',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(v.icon, size: 96, color: v.gradient.last),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${today.tMax.round()}°',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 64,
                        fontWeight: FontWeight.w200,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mín. ${today.tMin.round()}°',
                      style: TextStyle(color: subtle, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      v.description,
                      style: TextStyle(color: onSurface, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatChip(
                icon: Icons.air,
                label: 'Vento',
                value:
                    '${today.predWindDir} · ${_windClassLabels[today.classWindSpeed] ?? '—'}',
              ),
              StatChip(
                icon: Icons.water_drop_outlined,
                label: 'Precip.',
                value: '${today.precipitaProb.round()}%',
              ),
              if (today.iUv != null)
                StatChip(
                  icon: Icons.wb_sunny_outlined,
                  label: 'UV · ${_uvLabel(today.iUv!)}',
                  value: today.iUv!.toStringAsFixed(1),
                  accent: _uvColor(today.iUv!),
                ),
              if (fire != null && fire.level != FireRiskLevel.unknown)
                StatChip(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Incêndio',
                  value: _fireLabels[fire.level] ?? '—',
                  accent: _fireColors[fire.level],
                ),
            ],
          ),
          if (hourly.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(
              height: 1,
              color: onSurface.withValues(alpha: 0.08),
            ),
            const SizedBox(height: 10),
            HourlyStrip(hours: hourly, compact: true),
          ],
          if (sea.isNotEmpty || tempHistory20d.length >= 2) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (sea.isNotEmpty)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openSheet(
                        context,
                        SeaPanel(snapshots: sea, sourceName: seaSourceName),
                      ),
                      icon: const Icon(Icons.waves, size: 18),
                      label: const Text('Estado do mar'),
                    ),
                  ),
                if (sea.isNotEmpty && tempHistory20d.length >= 2)
                  const SizedBox(width: 8),
                if (tempHistory20d.length >= 2)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openSheet(
                        context,
                        TempTrendPanel(points: tempHistory20d),
                      ),
                      icon: const Icon(Icons.show_chart, size: 18),
                      label: const Text('Temp. 20 d'),
                    ),
                  ),
              ],
            ),
          ],
          if (lastUpdated != null) ...[
            const SizedBox(height: 14),
            Text(
              'Atualizado ${_agoLabel(lastUpdated!)} · ${_fmt(lastUpdated!)}',
              style: TextStyle(color: subtle, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  void _openSheet(BuildContext context, Widget panel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final maxH = MediaQuery.of(ctx).size.height * 0.85;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [panel, const SizedBox(height: 12)],
            ),
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${d.day}/${d.month} $h:$m';
  }
}
