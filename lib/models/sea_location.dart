class SeaLocation {
  final int globalIdLocal;
  final String local;
  final int idRegiao;
  final String? idAreaAviso;
  final double latitude;
  final double longitude;

  const SeaLocation({
    required this.globalIdLocal,
    required this.local,
    required this.idRegiao,
    required this.idAreaAviso,
    required this.latitude,
    required this.longitude,
  });

  factory SeaLocation.fromJson(Map<String, dynamic> j) => SeaLocation(
        globalIdLocal: (j['globalIdLocal'] as num).toInt(),
        local: (j['local'] as String?) ?? '',
        idRegiao: (j['idRegiao'] as num?)?.toInt() ?? 0,
        idAreaAviso: j['idAreaAviso'] as String?,
        latitude: double.tryParse('${j['latitude']}') ?? 0,
        longitude: double.tryParse('${j['longitude']}') ?? 0,
      );
}
