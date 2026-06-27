class SeaSnapshot {
  final DateTime date;
  final double? waveHeight;
  final String swellDir;
  final double? swellPeriod;
  final double? waterTemp;

  const SeaSnapshot({
    required this.date,
    required this.waveHeight,
    required this.swellDir,
    required this.swellPeriod,
    required this.waterTemp,
  });

  factory SeaSnapshot.fromAggregate(Map<String, dynamic> j) => SeaSnapshot(
        date: DateTime.parse(j['dataPrev'] as String),
        waveHeight: double.tryParse('${j['ondulacao']}'),
        swellDir: (j['dirOndulacao'] as String?) ?? '',
        swellPeriod: double.tryParse('${j['periodoPico']}'),
        waterTemp: double.tryParse('${j['tempAguaMar']}'),
      );

  factory SeaSnapshot.fromHpSea(Map<String, dynamic> j, DateTime date) {
    double? avg(dynamic a, dynamic b) {
      final av = double.tryParse('$a');
      final bv = double.tryParse('$b');
      if (av == null && bv == null) return null;
      if (av == null) return bv;
      if (bv == null) return av;
      return (av + bv) / 2;
    }

    return SeaSnapshot(
      date: date,
      waveHeight: avg(j['waveHighMin'], j['waveHighMax']),
      swellDir: (j['predWaveDir'] as String?) ?? '',
      swellPeriod: avg(j['wavePeriodMin'], j['wavePeriodMax']),
      waterTemp: avg(j['sstMin'], j['sstMax']),
    );
  }
}
