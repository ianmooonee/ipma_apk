class UvDay {
  final int globalIdLocal;
  final DateTime date;
  final double iUv;
  final String intervaloHora;
  final int idPeriodo;

  const UvDay({
    required this.globalIdLocal,
    required this.date,
    required this.iUv,
    required this.intervaloHora,
    required this.idPeriodo,
  });

  factory UvDay.fromJson(Map<String, dynamic> j) => UvDay(
        globalIdLocal: (j['globalIdLocal'] as num).toInt(),
        date: DateTime.parse(j['data'] as String),
        iUv: double.tryParse('${j['iUv']}') ?? 0,
        intervaloHora: (j['intervaloHora'] as String?) ?? '',
        idPeriodo: (j['idPeriodo'] as int?) ?? 0,
      );
}
