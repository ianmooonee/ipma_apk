class DailyForecast {
  final DateTime date;
  final double tMin;
  final double tMax;
  final int idWeatherType;
  final String predWindDir;
  final int classWindSpeed;
  final double precipitaProb;
  final double? iUv;

  const DailyForecast({
    required this.date,
    required this.tMin,
    required this.tMax,
    required this.idWeatherType,
    required this.predWindDir,
    required this.classWindSpeed,
    required this.precipitaProb,
    required this.iUv,
  });

  factory DailyForecast.fromAggregate(Map<String, dynamic> j) => DailyForecast(
        date: DateTime.parse(j['dataPrev'] as String),
        tMin: double.tryParse('${j['tMin']}') ?? 0,
        tMax: double.tryParse('${j['tMax']}') ?? 0,
        idWeatherType: (j['idTipoTempo'] as num?)?.toInt() ?? 0,
        predWindDir: (j['ddVento'] as String?) ?? '',
        classWindSpeed: (j['idFfxVento'] as num?)?.toInt() ?? 0,
        precipitaProb: double.tryParse('${j['probabilidadePrecipita']}') ?? 0,
        iUv: double.tryParse('${j['iUv']}'),
      );

  factory DailyForecast.fromDailyEndpoint(Map<String, dynamic> j) => DailyForecast(
        date: DateTime.parse(j['forecastDate'] as String),
        tMin: double.tryParse('${j['tMin']}') ?? 0,
        tMax: double.tryParse('${j['tMax']}') ?? 0,
        idWeatherType: (j['idWeatherType'] as num?)?.toInt() ?? 0,
        predWindDir: (j['predWindDir'] as String?) ?? '',
        classWindSpeed: (j['classWindSpeed'] as num?)?.toInt() ?? 0,
        precipitaProb: double.tryParse('${j['precipitaProb']}') ?? 0,
        iUv: null,
      );
}
