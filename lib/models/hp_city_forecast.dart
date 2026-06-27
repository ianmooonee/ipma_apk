class HpCityForecast {
  final int globalIdLocal;
  final DateTime? forecastDate;
  final double tMin;
  final double tMax;
  final int idWeatherType;
  final String predWindDir;
  final int classWindSpeed;
  final double precipitaProb;
  final double latitude;
  final double longitude;

  const HpCityForecast({
    required this.globalIdLocal,
    required this.forecastDate,
    required this.tMin,
    required this.tMax,
    required this.idWeatherType,
    required this.predWindDir,
    required this.classWindSpeed,
    required this.precipitaProb,
    required this.latitude,
    required this.longitude,
  });

  factory HpCityForecast.fromJson(Map<String, dynamic> j) => HpCityForecast(
        globalIdLocal: (j['globalIdLocal'] as num).toInt(),
        forecastDate: DateTime.tryParse('${j['forecastDate'] ?? ''}'),
        tMin: double.tryParse('${j['tMin']}') ?? 0,
        tMax: double.tryParse('${j['tMax']}') ?? 0,
        idWeatherType: (j['idWeatherType'] as num?)?.toInt() ?? 0,
        predWindDir: (j['predWindDir'] as String?) ?? '',
        classWindSpeed: (j['classWindSpeed'] as num?)?.toInt() ?? 0,
        precipitaProb: double.tryParse('${j['precipitaProb']}') ?? 0,
        latitude: double.tryParse('${j['latitude']}') ?? 0,
        longitude: double.tryParse('${j['longitude']}') ?? 0,
      );
}
