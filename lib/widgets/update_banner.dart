import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/update_checker.dart';

const _kRepoOwner = 'ianmooonee';
const _kRepoName = 'ipma_apk';

class UpdateBanner extends StatefulWidget {
  const UpdateBanner({super.key});

  @override
  State<UpdateBanner> createState() => _UpdateBannerState();
}

class _UpdateBannerState extends State<UpdateBanner> {
  final _checker = UpdateChecker(owner: _kRepoOwner, repo: _kRepoName);
  GithubRelease? _release;
  bool _dismissed = false;
  bool _busy = false;
  double? _progress;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb &&
        Platform.isAndroid &&
        _kRepoOwner != 'YOUR_GITHUB_USERNAME') {
      _check();
    }
  }

  Future<void> _check() async {
    try {
      final r = await _checker.checkForUpdate();
      if (!mounted) return;
      setState(() => _release = r);
    } catch (_) {/* offline / API down — silent */}
  }

  Future<void> _install() async {
    final r = _release;
    if (r == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
    });
    try {
      await _checker.downloadAndInstall(r, onProgress: (recv, total) {
        if (!mounted || total == null || total == 0) return;
        setState(() => _progress = recv / total);
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _checker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _release;
    if (r == null || _dismissed) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.system_update, color: scheme.onPrimaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nova versão ${r.tagName} disponível',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed:
                    _busy ? null : () => setState(() => _dismissed = true),
                icon: Icon(Icons.close, color: scheme.onPrimaryContainer),
                tooltip: 'Mais tarde',
              ),
            ],
          ),
          if (r.body.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              r.body.trim(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
          ],
          if (_busy) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 4),
            Text(
              _progress == null
                  ? 'A descarregar…'
                  : 'A descarregar… ${(_progress! * 100).round()}%',
              style: TextStyle(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (r.apkUrl != null)
                FilledButton.icon(
                  onPressed: _busy ? null : _install,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Atualizar'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
