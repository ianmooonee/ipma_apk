class StationObservation {
  final int idEstacao;
  final String localEstacao;
  final DateTime? time;
  final double latitude;
  final double longitude;
  final double? temperatura;
  final double? humidade;
  final double? pressao;
  final double? intensidadeVentoKm;
  final String descDirVento;
  final double? precAcumulada;
  final double? radiacao;

  const StationObservation({
    required this.idEstacao,
    required this.localEstacao,
    required this.time,
    required this.latitude,
    required this.longitude,
    required this.temperatura,
    required this.humidade,
    required this.pressao,
    required this.intensidadeVentoKm,
    required this.descDirVento,
    required this.precAcumulada,
    required this.radiacao,
  });

  static double? _real(num? v) {
    if (v == null) return null;
    final d = v.toDouble();
    if (d <= -99) return null;
    return d;
  }

  factory StationObservation.fromFeature(Map<String, dynamic> feat) {
    final geom = feat['geometry'] as Map<String, dynamic>;
    final coords = (geom['coordinates'] as List).cast<num>();
    final p = feat['properties'] as Map<String, dynamic>;
    return StationObservation(
      idEstacao: (p['idEstacao'] as num).toInt(),
      localEstacao: (p['localEstacao'] as String?) ?? '',
      time: DateTime.tryParse((p['time'] as String?) ?? ''),
      longitude: coords[0].toDouble(),
      latitude: coords[1].toDouble(),
      temperatura: _real(p['temperatura'] as num?),
      humidade: _real(p['humidade'] as num?),
      pressao: _real(p['pressao'] as num?),
      intensidadeVentoKm: _real(p['intensidadeVentoKM'] as num?),
      descDirVento: (p['descDirVento'] as String?) ?? '',
      precAcumulada: _real(p['precAcumulada'] as num?),
      radiacao: _real(p['radiacao'] as num?),
    );
  }
}
