import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/weather_store.dart';
import '../widgets/city_picker.dart';
import '../widgets/daily_strip.dart';
import '../widgets/observation_panel.dart';
import '../widgets/today_hero.dart';
import '../widgets/update_banner.dart';
import '../widgets/warnings_panel.dart';
import 'national_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherStore>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<WeatherStore>();
    final theme = Theme.of(context);

    if (store.loading && store.daily.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (store.error != null && store.daily.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(store.error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: store.refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar de novo'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final today = store.daily.isNotEmpty ? store.daily.first : null;
    final city = store.selected?.local ?? 'Portugal';

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: RefreshIndicator(
        onRefresh: store.refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: today == null
                    ? const SizedBox.shrink()
                    : TodayHero(
                        city: city,
                        today: today,
                        hourly: store.hourly,
                        lastUpdated: store.lastUpdated,
                        fireRisk: store.fireRisk,
                        sea: store.sea,
                        seaSourceName: store.seaSourceName,
                        tempHistory20d: store.tempHistory20d,
                        onCityTap: () => _openPicker(context),
                        onRefresh: store.refresh,
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: WarningsPanel(warnings: store.warnings),
            ),
            const SliverToBoxAdapter(child: UpdateBanner()),
            SliverToBoxAdapter(
              child: ObservationPanel(observations: store.nearbyObservations),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Próximos dias',
                theme: theme,
              ),
            ),
            SliverToBoxAdapter(
              child: DailyStrip(days: store.daily, uv: store.uv),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NationalScreen()),
                  ),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Ver todo o país'),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final store = context.read<WeatherStore>();
    final picked = await CityPicker.show(
      context,
      locations: store.locations,
      currentId: store.selected?.globalIdLocal,
    );
    if (picked != null) {
      await store.select(picked);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
