import 'package:flutter/material.dart';

class WeatherVisual {
  final IconData icon;
  final List<Color> gradient;
  final String description;

  const WeatherVisual({
    required this.icon,
    required this.gradient,
    required this.description,
  });
}

/// IPMA `idWeatherType` → icon + gradient + Portuguese label.
/// Reference: https://api.ipma.pt/open-data/weather-type-classe.json
const _table = <int, WeatherVisual>{
  0: WeatherVisual(icon: Icons.help_outline, gradient: [Color(0xFF607D8B), Color(0xFF455A64)], description: '—'),
  1: WeatherVisual(icon: Icons.wb_sunny, gradient: [Color(0xFFFFB74D), Color(0xFFFF8A65)], description: 'Céu limpo'),
  2: WeatherVisual(icon: Icons.wb_sunny_outlined, gradient: [Color(0xFFFFCA28), Color(0xFFFF9800)], description: 'Céu pouco nublado'),
  3: WeatherVisual(icon: Icons.cloud_queue, gradient: [Color(0xFF64B5F6), Color(0xFF1976D2)], description: 'Céu parcialmente nublado'),
  4: WeatherVisual(icon: Icons.cloud, gradient: [Color(0xFF78909C), Color(0xFF455A64)], description: 'Céu muito nublado ou encoberto'),
  5: WeatherVisual(icon: Icons.cloud, gradient: [Color(0xFF90A4AE), Color(0xFF546E7A)], description: 'Céu nublado por nuvens altas'),
  6: WeatherVisual(icon: Icons.grain, gradient: [Color(0xFF4FC3F7), Color(0xFF0277BD)], description: 'Aguaceiros'),
  7: WeatherVisual(icon: Icons.grain, gradient: [Color(0xFF4FC3F7), Color(0xFF01579B)], description: 'Aguaceiros fracos'),
  8: WeatherVisual(icon: Icons.grain, gradient: [Color(0xFF29B6F6), Color(0xFF01579B)], description: 'Aguaceiros fortes'),
  9: WeatherVisual(icon: Icons.umbrella, gradient: [Color(0xFF4DD0E1), Color(0xFF00838F)], description: 'Chuva'),
  10: WeatherVisual(icon: Icons.umbrella, gradient: [Color(0xFF26C6DA), Color(0xFF006064)], description: 'Chuva fraca ou chuvisco'),
  11: WeatherVisual(icon: Icons.umbrella, gradient: [Color(0xFF00ACC1), Color(0xFF004D5B)], description: 'Chuva forte'),
  12: WeatherVisual(icon: Icons.grain, gradient: [Color(0xFF80DEEA), Color(0xFF00838F)], description: 'Períodos de chuva'),
  13: WeatherVisual(icon: Icons.grain, gradient: [Color(0xFF80DEEA), Color(0xFF006064)], description: 'Períodos de chuva fraca'),
  14: WeatherVisual(icon: Icons.umbrella, gradient: [Color(0xFF4DD0E1), Color(0xFF004D5B)], description: 'Períodos de chuva forte'),
  15: WeatherVisual(icon: Icons.water_drop, gradient: [Color(0xFFB0BEC5), Color(0xFF455A64)], description: 'Chuvisco'),
  16: WeatherVisual(icon: Icons.foggy, gradient: [Color(0xFFCFD8DC), Color(0xFF607D8B)], description: 'Neblina'),
  17: WeatherVisual(icon: Icons.foggy, gradient: [Color(0xFFB0BEC5), Color(0xFF455A64)], description: 'Nevoeiro ou nuvens baixas'),
  18: WeatherVisual(icon: Icons.ac_unit, gradient: [Color(0xFFE1F5FE), Color(0xFF81D4FA)], description: 'Neve'),
  19: WeatherVisual(icon: Icons.thunderstorm, gradient: [Color(0xFF5C6BC0), Color(0xFF1A237E)], description: 'Trovoada'),
  20: WeatherVisual(icon: Icons.thunderstorm, gradient: [Color(0xFF7986CB), Color(0xFF283593)], description: 'Aguaceiros e trovoada'),
  21: WeatherVisual(icon: Icons.grain, gradient: [Color(0xFF80DEEA), Color(0xFF00838F)], description: 'Granizo'),
  22: WeatherVisual(icon: Icons.ac_unit, gradient: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)], description: 'Geada'),
  23: WeatherVisual(icon: Icons.thunderstorm, gradient: [Color(0xFF5C6BC0), Color(0xFF1A237E)], description: 'Chuva e trovoada'),
  24: WeatherVisual(icon: Icons.cloud_queue, gradient: [Color(0xFF90A4AE), Color(0xFF455A64)], description: 'Nebulosidade convectiva'),
  25: WeatherVisual(icon: Icons.wb_sunny_outlined, gradient: [Color(0xFFFFD54F), Color(0xFFFFB300)], description: 'Céu com periodos de muito nublado'),
  26: WeatherVisual(icon: Icons.foggy, gradient: [Color(0xFFCFD8DC), Color(0xFF607D8B)], description: 'Nevoeiro'),
  27: WeatherVisual(icon: Icons.cloud, gradient: [Color(0xFF78909C), Color(0xFF37474F)], description: 'Céu muito nublado'),
};

WeatherVisual weatherVisualFor(int id) =>
    _table[id] ?? _table[0]!;
