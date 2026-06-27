import 'package:flutter/material.dart';

import '../models/location.dart';

class CityPicker extends StatefulWidget {
  final List<IpmaLocation> locations;
  final int? currentId;
  const CityPicker({super.key, required this.locations, required this.currentId});

  static Future<IpmaLocation?> show(
    BuildContext context, {
    required List<IpmaLocation> locations,
    required int? currentId,
  }) {
    return showModalBottomSheet<IpmaLocation>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: CityPicker(locations: locations, currentId: currentId),
      ),
    );
  }

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  final TextEditingController _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _q.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.locations
        : widget.locations
            .where((l) => l.local.toLowerCase().contains(q))
            .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _q,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Pesquisar cidade...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final l = filtered[i];
                final selected = l.globalIdLocal == widget.currentId;
                return ListTile(
                  leading: Icon(
                    selected ? Icons.check_circle : Icons.location_city,
                    color: selected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(l.local),
                  subtitle: Text('lat ${l.latitude.toStringAsFixed(2)}, lon ${l.longitude.toStringAsFixed(2)}'),
                  onTap: () => Navigator.of(context).pop(l),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
