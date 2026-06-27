class IpmaLocation {
  final int globalIdLocal;
  final String local;
  final int idDistrito;
  final int idRegiao;
  final String? idAreaAviso;
  final double latitude;
  final double longitude;

  const IpmaLocation({
    required this.globalIdLocal,
    required this.local,
    required this.idDistrito,
    required this.idRegiao,
    required this.idAreaAviso,
    required this.latitude,
    required this.longitude,
  });

  factory IpmaLocation.fromJson(Map<String, dynamic> j) => IpmaLocation(
        globalIdLocal: j['globalIdLocal'] as int,
        local: j['local'] as String,
        idDistrito: j['idDistrito'] as int,
        idRegiao: j['idRegiao'] as int,
        idAreaAviso: j['idAreaAviso'] as String?,
        latitude: double.tryParse('${j['latitude']}') ?? 0,
        longitude: double.tryParse('${j['longitude']}') ?? 0,
      );
}
