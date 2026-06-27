import 'package:flutter/material.dart';

import '../models/station_observation.dart';

class ObservationPanel extends StatefulWidget {
  final List<StationObservation> observations;
  const ObservationPanel({super.key, required this.observations});

  @override
  State<ObservationPanel> createState() => _ObservationPanelState();
}

class _ObservationPanelState extends State<ObservationPanel> {
  int _index = 0;

  @override
  void didUpdateWidget(covariant ObservationPanel old) {
    super.didUpdateWidget(old);
    if (_index >= widget.observations.length) _index = 0;
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.observations;
    if (list.isEmpty) return const SizedBox.shrink();
    final obs = list[_index];
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final subtle = onSurface.withValues(alpha: 0.6);
    final t = obs.time;
    final ago = t == null ? null : _agoLabel(t);

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
              Icon(Icons.sensors, color: onSurface),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Observado agora',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (ago != null)
                Text(ago, style: TextStyle(color: subtle, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          if (list.length > 1)
            _StationSelector(
              stations: list,
              selected: _index,
              onChanged: (i) => setState(() => _index = i),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Text(
                obs.localEstacao,
                style: TextStyle(color: subtle, fontSize: 12),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (obs.temperatura != null)
                Expanded(
                  child: _ObsTile(
                    label: 'Temp.',
                    value: '${obs.temperatura!.toStringAsFixed(1)}°',
                  ),
                ),
              if (obs.humidade != null)
                Expanded(
                  child: _ObsTile(
                    label: 'Humidade',
                    value: '${obs.humidade!.round()}%',
                  ),
                ),
              if (obs.intensidadeVentoKm != null)
                Expanded(
                  child: _ObsTile(
                    label: 'Vento',
                    value:
                        '${obs.intensidadeVentoKm!.round()} km/h${obs.descDirVento.isEmpty ? '' : ' ${obs.descDirVento}'}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (obs.pressao != null)
                Expanded(
                  child: _ObsTile(
                    label: 'Pressão',
                    value: '${obs.pressao!.round()} hPa',
                  ),
                ),
              if (obs.precAcumulada != null)
                Expanded(
                  child: _ObsTile(
                    label: 'Precip. 1h',
                    value: '${obs.precAcumulada!.toStringAsFixed(1)} mm',
                  ),
                ),
              if (obs.radiacao != null)
                Expanded(
                  child: _ObsTile(
                    label: 'Radiação',
                    value: '${obs.radiacao!.round()} kJ/m²',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _agoLabel(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    return 'há ${diff.inDays} dias';
  }
}

class _StationSelector extends StatelessWidget {
  final List<StationObservation> stations;
  final int selected;
  final ValueChanged<int> onChanged;

  const _StationSelector({
    required this.stations,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: stations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final sel = i == selected;
          return ChoiceChip(
            selected: sel,
            onSelected: (_) => onChanged(i),
            label: Text(
              stations[i].localEstacao,
              style: TextStyle(
                fontSize: 12,
                color: sel ? theme.colorScheme.onPrimary : onSurface,
              ),
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            selectedColor: theme.colorScheme.primary,
          );
        },
      ),
    );
  }
}

class _ObsTile extends StatelessWidget {
  final String label;
  final String value;
  const _ObsTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.55),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
