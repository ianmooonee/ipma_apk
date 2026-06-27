import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/hp_city_forecast.dart';
import '../models/location.dart';
import '../services/ipma_api.dart';
import '../services/weather_icons.dart';
import '../state/weather_store.dart';

class NationalScreen extends StatefulWidget {
  const NationalScreen({super.key});

  @override
  State<NationalScreen> createState() => _NationalScreenState();
}

class _NationalScreenState extends State<NationalScreen> {
  int _idDay = 0;
  final _api = IpmaApi();
  late Future<List<HpCityForecast>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchHpDaily(_idDay);
  }

  void _setDay(int d) {
    setState(() {
      _idDay = d;
      _future = _api.fetchHpDaily(d);
    });
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locations = context.read<WeatherStore>().locations;
    final byId = {for (final l in locations) l.globalIdLocal: l};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portugal'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Hoje')),
                ButtonSegment(value: 1, label: Text('Amanhã')),
                ButtonSegment(value: 2, label: Text('Depois')),
              ],
              selected: {_idDay},
              onSelectionChanged: (s) => _setDay(s.first),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: FutureBuilder<List<HpCityForecast>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Erro: ${snap.error}'),
                  ),
                );
              }
              final data = snap.data ?? const [];
              final grouped = <int, List<HpCityForecast>>{};
              for (final f in data) {
                grouped.putIfAbsent(_districtOf(byId, f), () => []).add(f);
              }
              final districts = grouped.keys.toList()..sort();
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                itemCount: districts.length,
                itemBuilder: (_, i) {
                  final id = districts[i];
                  final entries = grouped[id]!
                    ..sort(
                        (a, b) => _nameOf(byId, a).compareTo(_nameOf(byId, b)));
                  return _DistrictSection(
                    title: _districtName(byId, id),
                    entries: entries,
                    byId: byId,
                    theme: theme,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  int _districtOf(Map<int, IpmaLocation> byId, HpCityForecast f) =>
      byId[f.globalIdLocal]?.idDistrito ?? 0;

  String _nameOf(Map<int, IpmaLocation> byId, HpCityForecast f) =>
      byId[f.globalIdLocal]?.local ?? '${f.globalIdLocal}';

  String _districtName(Map<int, IpmaLocation> byId, int id) {
    if (id == 0) return 'Outros';
    final loc = byId.values.firstWhere(
      (l) => l.idDistrito == id,
      orElse: () => byId.values.first,
    );
    return loc.local;
  }
}

class _DistrictSection extends StatelessWidget {
  final String title;
  final List<HpCityForecast> entries;
  final Map<int, IpmaLocation> byId;
  final ThemeData theme;

  const _DistrictSection({
    required this.title,
    required this.entries,
    required this.byId,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: onSurface.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            ...entries.map((f) {
              final loc = byId[f.globalIdLocal];
              final name = loc?.local ?? '${f.globalIdLocal}';
              final v = weatherVisualFor(f.idWeatherType);
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Icon(v.icon, size: 28, color: v.gradient.last),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(color: onSurface, fontSize: 14),
                      ),
                    ),
                    Text(
                      '${f.precipitaProb.round()}%',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${f.tMin.round()}° / ${f.tMax.round()}°',
                      style: TextStyle(
                        color: onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
