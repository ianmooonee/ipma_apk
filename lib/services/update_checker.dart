import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class GithubRelease {
  final String tagName;
  final String name;
  final String body;
  final String htmlUrl;
  final String? apkUrl;
  final int? apkSize;
  final DateTime? publishedAt;

  const GithubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.htmlUrl,
    required this.apkUrl,
    required this.apkSize,
    required this.publishedAt,
  });
}

class UpdateChecker {
  UpdateChecker({
    required this.owner,
    required this.repo,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String owner;
  final String repo;
  final http.Client _client;

  String get _latestUrl =>
      'https://api.github.com/repos/$owner/$repo/releases/latest';

  Future<({String version, int build})> currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return (
      version: info.version,
      build: int.tryParse(info.buildNumber) ?? 0,
    );
  }

  Future<GithubRelease?> fetchLatest() async {
    final r = await _client.get(
      Uri.parse(_latestUrl),
      headers: const {'Accept': 'application/vnd.github+json'},
    );
    if (r.statusCode != 200) return null;
    final j = jsonDecode(r.body);
    if (j is! Map<String, dynamic>) return null;
    final assets = (j['assets'] as List?) ?? const [];
    Map<String, dynamic>? apk;
    for (final a in assets.cast<Map<String, dynamic>>()) {
      final name = (a['name'] as String?) ?? '';
      if (name.toLowerCase().endsWith('.apk')) {
        apk = a;
        break;
      }
    }
    return GithubRelease(
      tagName: (j['tag_name'] as String?) ?? '',
      name: (j['name'] as String?) ?? '',
      body: (j['body'] as String?) ?? '',
      htmlUrl: (j['html_url'] as String?) ?? '',
      apkUrl: apk == null ? null : apk['browser_download_url'] as String?,
      apkSize: apk == null ? null : (apk['size'] as num?)?.toInt(),
      publishedAt: DateTime.tryParse((j['published_at'] as String?) ?? ''),
    );
  }

  /// Returns the release if a newer version is available, else null.
  Future<GithubRelease?> checkForUpdate() async {
    final current = await currentVersion();
    final latest = await fetchLatest();
    if (latest == null) return null;
    final remote = _parseSemver(latest.tagName);
    final local = _parseSemver(current.version);
    if (remote == null || local == null) return null;
    return _isNewer(remote, local) ? latest : null;
  }

  /// Downloads the APK to a temp file and opens Android's installer.
  Future<void> downloadAndInstall(
    GithubRelease release, {
    void Function(int received, int? total)? onProgress,
  }) async {
    final url = release.apkUrl;
    if (url == null) {
      throw StateError('Release has no APK asset.');
    }
    if (Platform.isAndroid) {
      final status = await Permission.requestInstallPackages.request();
      if (!status.isGranted) {
        throw StateError(
          'Permissão de instalação negada. Ative "Instalar apps desconhecidas" nas definições do Android.',
        );
      }
    }
    final req = http.Request('GET', Uri.parse(url));
    final res = await _client.send(req);
    if (res.statusCode != 200) {
      throw HttpException('Falha ao descarregar APK (${res.statusCode})');
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/ipma_${release.tagName}.apk');
    if (await file.exists()) await file.delete();
    final sink = file.openWrite();
    final total = res.contentLength ?? release.apkSize;
    var received = 0;
    await for (final chunk in res.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (onProgress != null) onProgress(received, total);
    }
    await sink.close();
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      throw StateError(
          'Não foi possível abrir o instalador: ${result.message}');
    }
  }

  void dispose() => _client.close();

  static List<int>? _parseSemver(String raw) {
    final s = raw.startsWith('v') ? raw.substring(1) : raw;
    final core = s.split('+').first.split('-').first;
    final parts = core.split('.');
    if (parts.isEmpty) return null;
    final out = <int>[];
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null) return null;
      out.add(n);
    }
    while (out.length < 3) {
      out.add(0);
    }
    return out;
  }

  static bool _isNewer(List<int> a, List<int> b) {
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final ai = i < a.length ? a[i] : 0;
      final bi = i < b.length ? b[i] : 0;
      if (ai > bi) return true;
      if (ai < bi) return false;
    }
    return false;
  }
}
