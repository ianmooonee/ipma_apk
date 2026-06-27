import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_forecast.dart';
import '../models/fire_risk.dart';
import '../models/hourly_forecast.dart';
import '../models/location.dart';
import '../models/sea_forecast.dart';
import '../models/sea_location.dart';
import '../models/station_observation.dart';
import '../models/uv_forecast.dart';
import '../models/weather_warning.dart';
import '../services/ipma_api.dart';

const _kLastCityKey = 'last_global_id_v2';
const _kLocationsCacheKey = 'locations_cache_v1';
const _defaultGlobalId = 1060300; // Coimbra

class WeatherStore extends ChangeNotifier {
  WeatherStore({IpmaApi? api}) : _api = api ?? IpmaApi();

  final IpmaApi _api;

  List<IpmaLocation> locations = const [];
  IpmaLocation? selected;

  List<DailyForecast> daily = const [];
  List<HourlyForecast> hourly = const [];
  List<SeaSnapshot> sea = const [];
  String? seaSourceName;
  List<SeaLocation> seaLocations = const [];
  List<WeatherWarning> warnings = const [];
  List<UvDay> uv = const [];
  FireRisk? fireRisk;
  StationObservation? observation;
  List<StationObservation> nearbyObservations = const [];
  List<({DateTime date, double value})> tempHistory20d = const [];
  DateTime? lastUpdated;

  bool loading = false;
  String? error;

  Future<void> init() async {
    loading = true;
    notifyListeners();
    try {
      await _loadLocations();
      if (seaLocations.isEmpty) {
        try {
          seaLocations = await _api.fetchSeaLocations();
        } catch (_) {}
      }
      final prefs = await SharedPreferences.getInstance();
      final lastId = prefs.getInt(_kLastCityKey) ?? _defaultGlobalId;
      selected = locations.firstWhere(
        (l) => l.globalIdLocal == lastId,
        orElse: () => locations.firstWhere(
          (l) => l.globalIdLocal == _defaultGlobalId,
          orElse: () => locations.first,
        ),
      );
      await _loadForecast();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> select(IpmaLocation loc) async {
    selected = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastCityKey, loc.globalIdLocal);
    await refresh();
  }

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await _loadForecast();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kLocationsCacheKey);
    if (cached != null) {
      final list = jsonDecode(cached) as List;
      locations = list
          .cast<Map<String, dynamic>>()
          .map(IpmaLocation.fromJson)
          .toList()
        ..sort((a, b) => a.local.compareTo(b.local));
    }
    try {
      final fresh = await _api.fetchLocations();
      locations = fresh;
      await prefs.setString(
        _kLocationsCacheKey,
        jsonEncode(fresh.map(_locToJson).toList()),
      );
    } catch (_) {
      if (locations.isEmpty) rethrow;
    }
  }

  Future<void> _loadForecast() async {
    final loc = selected;
    if (loc == null) return;
    final results = await Future.wait([
      _api.fetchAggregate(loc.globalIdLocal),
      _api.fetchWarnings().catchError((_) => <WeatherWarning>[]),
      _api.fetchUv().catchError((_) => <UvDay>[]),
      _api.fetchFireRisk(0).catchError((_) => <FireRisk>[]),
      _api.fetchStationObservations()
          .catchError((_) => <StationObservation>[]),
      _api.fetchTempHistoryCsv().catchError((_) => ''),
    ]);
    final r = results[0] as AggregateForecast;
    final allWarnings = results[1] as List<WeatherWarning>;
    final allUv = results[2] as List<UvDay>;
    final allFire = results[3] as List<FireRisk>;
    final allObs = results[4] as List<StationObservation>;
    final csv = results[5] as String;
    daily = r.daily;
    hourly = r.hourly;
    sea = r.sea;
    seaSourceName = r.sea.isEmpty ? null : loc.local;
    lastUpdated = r.dataUpdate;
    final area = loc.idAreaAviso;
    warnings = area == null
        ? const []
        : allWarnings.where((w) => w.idAreaAviso == area).toList()
      ..sort((a, b) => b.level.index.compareTo(a.level.index));
    uv = allUv.where((u) => u.globalIdLocal == loc.globalIdLocal).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    fireRisk = _nearestFireRisk(allFire, loc.latitude, loc.longitude);
    nearbyObservations = _nearbyObservations(allObs, loc.latitude, loc.longitude);
    observation = nearbyObservations.isEmpty ? null : nearbyObservations.first;
    tempHistory20d = _parseTempHistory(csv, loc.local);

    if (sea.isEmpty && area != null) {
      if (seaLocations.isEmpty) {
        try {
          seaLocations = await _api.fetchSeaLocations();
        } catch (_) {}
      }
      final twin = _findSeaTwin(area);
      if (twin != null) {
        try {
          final twinSea =
              await _api.fetchSeaForecastForLocation(twin.globalIdLocal);
          if (twinSea.isNotEmpty) {
            sea = twinSea;
            seaSourceName = twin.local;
          }
        } catch (_) {}
      }
    }
  }

  SeaLocation? _findSeaTwin(String area) {
    for (final s in seaLocations) {
      if (s.idAreaAviso == area) return s;
    }
    return null;
  }

  FireRisk? _nearestFireRisk(List<FireRisk> list, double lat, double lon) {
    if (list.isEmpty) return null;
    FireRisk? best;
    double bestD = double.infinity;
    for (final f in list) {
      final dLat = f.latitude - lat;
      final dLon = f.longitude - lon;
      final d = dLat * dLat + dLon * dLon;
      if (d < bestD) {
        bestD = d;
        best = f;
      }
    }
    return best;
  }

  /// Closest stations (by squared lat/lon distance) with usable temperature.
  /// Returns up to 6, all within ~0.6° (~60 km) of the city.
  List<StationObservation> _nearbyObservations(
      List<StationObservation> list, double lat, double lon) {
    const maxD = 0.6 * 0.6;
    final scored = <({double d, StationObservation o})>[];
    for (final o in list) {
      if (o.temperatura == null) continue;
      final dLat = o.latitude - lat;
      final dLon = o.longitude - lon;
      final d = dLat * dLat + dLon * dLon;
      if (d <= maxD) scored.add((d: d, o: o));
    }
    scored.sort((a, b) => a.d.compareTo(b.d));
    return scored.take(6).map((e) => e.o).toList();
  }

  List<({DateTime date, double value})> _parseTempHistory(
      String csv, String cityName) {
    if (csv.isEmpty) return const [];
    final lines = csv.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return const [];
    final header = lines.first.split(',');
    final znameIdx = header.indexOf('zname');
    final meanIdx = header.indexOf('mean_meant2m');
    if (znameIdx < 0 || meanIdx < 0) return const [];
    final target = _normalise(cityName);
    final values = <DateTime, double>{};
    for (final line in lines.skip(1)) {
      final cols = line.split(',');
      if (cols.length <= meanIdx) continue;
      if (_normalise(cols[znameIdx]) != target) continue;
      final t = DateTime.tryParse(cols[0]);
      final v = double.tryParse(cols[meanIdx]);
      if (t == null || v == null) continue;
      values[t] = v;
    }
    final sorted = values.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted
        .map((e) => (date: e.key, value: e.value))
        .toList();
  }

  String _normalise(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c')
      .trim();

  Map<String, dynamic> _locToJson(IpmaLocation l) => {
        'globalIdLocal': l.globalIdLocal,
        'local': l.local,
        'idDistrito': l.idDistrito,
        'idRegiao': l.idRegiao,
        'idAreaAviso': l.idAreaAviso,
        'latitude': l.latitude.toString(),
        'longitude': l.longitude.toString(),
      };

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }
}
