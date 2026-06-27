enum WarningLevel { green, yellow, orange, red, unknown }

WarningLevel _parseLevel(String? s) {
  switch (s?.toLowerCase()) {
    case 'green':
      return WarningLevel.green;
    case 'yellow':
      return WarningLevel.yellow;
    case 'orange':
      return WarningLevel.orange;
    case 'red':
      return WarningLevel.red;
    default:
      return WarningLevel.unknown;
  }
}

class WeatherWarning {
  final String idAreaAviso;
  final String awarenessTypeName;
  final WarningLevel level;
  final DateTime startTime;
  final DateTime endTime;
  final String text;

  const WeatherWarning({
    required this.idAreaAviso,
    required this.awarenessTypeName,
    required this.level,
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  bool get isActive =>
      level != WarningLevel.green && level != WarningLevel.unknown;

  factory WeatherWarning.fromJson(Map<String, dynamic> j) => WeatherWarning(
        idAreaAviso: (j['idAreaAviso'] as String?) ?? '',
        awarenessTypeName: (j['awarenessTypeName'] as String?) ?? '',
        level: _parseLevel(j['awarenessLevelID'] as String?),
        startTime: DateTime.parse(j['startTime'] as String),
        endTime: DateTime.parse(j['endTime'] as String),
        text: (j['text'] as String?) ?? '',
      );
}
