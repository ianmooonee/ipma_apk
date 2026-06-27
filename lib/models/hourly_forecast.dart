class HourlyForecast {
  final DateTime date;
  final double tMed;
  final double? utci;
  final double? precipProb;
  final int idWeatherType;
  final String windDir;
  final double windSpeedKmh;
  final double? humidity;

  const HourlyForecast({
    required this.date,
    required this.tMed,
    required this.utci,
    required this.precipProb,
    required this.idWeatherType,
    required this.windDir,
    required this.windSpeedKmh,
    required this.humidity,
  });

  factory HourlyForecast.fromAggregate(Map<String, dynamic> j) => HourlyForecast(
        date: DateTime.parse(j['dataPrev'] as String),
        tMed: double.tryParse('${j['tMed']}') ?? 0,
        utci: double.tryParse('${j['utci']}'),
        precipProb: double.tryParse('${j['probabilidadePrecipita']}'),
        idWeatherType: (j['idTipoTempo'] as num?)?.toInt() ?? 0,
        windDir: (j['ddVento'] as String?) ?? '',
        windSpeedKmh: double.tryParse('${j['ffVento']}') ?? 0,
        humidity: double.tryParse('${j['hR']}'),
      );
}
