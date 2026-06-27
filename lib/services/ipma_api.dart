import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/daily_forecast.dart';
import '../models/fire_risk.dart';
import '../models/hourly_forecast.dart';
import '../models/hp_city_forecast.dart';
import '../models/location.dart';
import '../models/sea_forecast.dart';
import '../models/sea_location.dart';
import '../models/station_observation.dart';
import '../models/uv_forecast.dart';
import '../models/weather_warning.dart';

class AggregateForecast {
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;
  final List<SeaSnapshot> sea;
  final DateTime? dataUpdate;

  const AggregateForecast({
    required this.daily,
    required this.hourly,
    required this.sea,
    required this.dataUpdate,
  });
}

class IpmaApi {
  IpmaApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'https://api.ipma.pt';

  Future<List<IpmaLocation>> fetchLocations() async {
    final r = await _get('$_base/open-data/distrits-islands.json');
    final list = (jsonDecode(r) as Map<String, dynamic>)['data'] as List;
    return list
        .cast<Map<String, dynamic>>()
        .map(IpmaLocation.fromJson)
        .toList()
      ..sort((a, b) => a.local.compareTo(b.local));
  }

  Future<List<SeaLocation>> fetchSeaLocations() async {
    final r = await _get('$_base/open-data/sea-locations.json');
    final list = jsonDecode(r) as List;
    return list
        .cast<Map<String, dynamic>>()
        .map(SeaLocation.fromJson)
        .toList();
  }

  Future<List<SeaSnapshot>> fetchSeaForecastForLocation(
      int globalIdLocal) async {
    final out = <SeaSnapshot>[];
    for (var day = 0; day < 3; day++) {
      try {
        final r = await _get(
            '$_base/open-data/forecast/oceanography/daily/hp-daily-sea-forecast-day$day.json');
        final body = jsonDecode(r) as Map<String, dynamic>;
        final date = DateTime.tryParse((body['forecastDate'] as String?) ?? '');
        if (date == null) continue;
        final data = body['data'] as List? ?? const [];
        for (final entry in data.cast<Map<String, dynamic>>()) {
          if ((entry['globalIdLocal'] as num?)?.toInt() == globalIdLocal) {
            out.add(SeaSnapshot.fromHpSea(entry, date));
            break;
          }
        }
      } catch (_) {}
    }
    return out;
  }

  Future<Map<int, String>> fetchWeatherTypes() async {
    final r = await _get('$_base/open-data/weather-type-classe.json');
    final list = (jsonDecode(r) as Map<String, dynamic>)['data'] as List;
    return {
      for (final e in list.cast<Map<String, dynamic>>())
        e['idWeatherType'] as int: (e['descWeatherTypePT'] as String?) ??
            (e['descWeatherTypeEN'] as String?) ??
            '',
    };
  }

  Future<List<WeatherWarning>> fetchWarnings() async {
    final r = await _get('$_base/open-data/forecast/warnings/warnings_www.json');
    final list = jsonDecode(r) as List;
    return list
        .cast<Map<String, dynamic>>()
        .map(WeatherWarning.fromJson)
        .toList();
  }

  Future<List<UvDay>> fetchUv() async {
    final r = await _get('$_base/open-data/forecast/meteorology/uv/uv.json');
    final list = jsonDecode(r) as List;
    return list.cast<Map<String, dynamic>>().map(UvDay.fromJson).toList();
  }

  Future<List<FireRisk>> fetchFireRisk(int idDay) async {
    final r = await _get(
        '$_base/open-data/forecast/meteorology/rcm/rcm-d$idDay.json');
    final body = jsonDecode(r) as Map<String, dynamic>;
    final dateStr = body['dataPrev'] as String?;
    final date = dateStr == null ? null : DateTime.tryParse(dateStr);
    final local = body['local'] as Map<String, dynamic>? ?? const {};
    final out = <FireRisk>[];
    for (final entry in local.entries) {
      final v = entry.value as Map<String, dynamic>;
      final data = v['data'] as Map<String, dynamic>?;
      final rcm = (data?['rcm'] as num?)?.toInt();
      if (rcm == null) continue;
      out.add(FireRisk(
        dico: (v['dico'] as String?) ?? entry.key,
        rcm: rcm,
        latitude: (v['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (v['longitude'] as num?)?.toDouble() ?? 0,
        date: date,
      ));
    }
    return out;
  }

  Future<List<StationObservation>> fetchStationObservations() async {
    final r = await _get(
        '$_base/open-data/observation/meteorology/stations/obs-surface.geojson');
    final body = jsonDecode(r) as Map<String, dynamic>;
    final feats = body['features'] as List? ?? const [];
    final perStation = <int, StationObservation>{};
    for (final f in feats.cast<Map<String, dynamic>>()) {
      final obs = StationObservation.fromFeature(f);
      final existing = perStation[obs.idEstacao];
      if (existing == null ||
          (obs.time != null &&
              (existing.time == null || obs.time!.isAfter(existing.time!)))) {
        perStation[obs.idEstacao] = obs;
      }
    }
    return perStation.values.toList();
  }

  Future<String> fetchTempHistoryCsv() async {
    return _get(
        '$_base/open-data/observation/climate/temperature/t2m-p1d-continental-obssup-idw-concelhos-20d.csv');
  }

  Future<List<HpCityForecast>> fetchHpDaily(int idDay) async {
    final r = await _get(
        '$_base/open-data/forecast/meteorology/cities/daily/hp-daily-forecast-day$idDay.json');
    final body = jsonDecode(r) as Map<String, dynamic>;
    final list = body['data'] as List? ?? const [];
    return list
        .cast<Map<String, dynamic>>()
        .map(HpCityForecast.fromJson)
        .toList();
  }

  Future<AggregateForecast> fetchAggregate(int globalIdLocal) async {
    final url = '$_base/public-data/forecast/aggregate/$globalIdLocal.json';
    final body = jsonDecode(await _get(url)) as List;
    final records = body.cast<Map<String, dynamic>>();

    final daily = <DailyForecast>[];
    final hourly = <HourlyForecast>[];
    final sea = <SeaSnapshot>[];
    DateTime? update;

    for (final r in records) {
      final p = r['idPeriodo'];
      if (p == 24) {
        daily.add(DailyForecast.fromAggregate(r));
      } else if (p == 1) {
        hourly.add(HourlyForecast.fromAggregate(r));
        if (r['ondulacao'] != null) {
          sea.add(SeaSnapshot.fromAggregate(r));
        }
      }
      final u = r['dataUpdate'];
      if (u is String) {
        final dt = DateTime.tryParse(u);
        if (dt != null && (update == null || dt.isAfter(update))) {
          update = dt;
        }
      }
    }

    daily.sort((a, b) => a.date.compareTo(b.date));
    hourly.sort((a, b) => a.date.compareTo(b.date));
    sea.sort((a, b) => a.date.compareTo(b.date));

    return AggregateForecast(
      daily: daily,
      hourly: hourly,
      sea: sea,
      dataUpdate: update,
    );
  }

  Future<String> _get(String url) async {
    final resp = await _client.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('GET $url -> ${resp.statusCode}');
    }
    return utf8.decode(resp.bodyBytes);
  }

  void close() => _client.close();
}
