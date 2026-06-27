enum FireRiskLevel {
  reduzido,
  moderado,
  elevado,
  muitoElevado,
  maximo,
  unknown
}

FireRiskLevel fireRiskFromCode(int code) {
  switch (code) {
    case 1:
      return FireRiskLevel.reduzido;
    case 2:
      return FireRiskLevel.moderado;
    case 3:
      return FireRiskLevel.elevado;
    case 4:
      return FireRiskLevel.muitoElevado;
    case 5:
      return FireRiskLevel.maximo;
    default:
      return FireRiskLevel.unknown;
  }
}

class FireRisk {
  final String dico;
  final int rcm;
  final double latitude;
  final double longitude;
  final DateTime? date;

  const FireRisk({
    required this.dico,
    required this.rcm,
    required this.latitude,
    required this.longitude,
    required this.date,
  });

  FireRiskLevel get level => fireRiskFromCode(rcm);
}
