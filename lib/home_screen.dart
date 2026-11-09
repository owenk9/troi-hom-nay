import 'package:flutter/material.dart';

import 'bong.dart';
import 'outfit.dart';
import 'weather.dart';

// Màu lấy từ bản mock.
const _ink = Color(0xFF2B2118);
const _muted = Color(0xFF7A6B5C);
const _surface2 = Color(0xFFEFE9DF);
const _accent = Color(0xFFE8833A);
const _cool = Color(0xFF2A8C8C);
const _warn = Color(0xFFB7791F);
const _ok = Color(0xFF2F9E44);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Weather> _weather = fetchWeather();

  void _reload() => setState(() => _weather = fetchWeather());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Weather>(
          future: _weather,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return _ErrorView(error: snap.error!, onRetry: _reload);
            }
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: _Content(weather: snap.data!),
            );
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final outfit = recommendOutfit(
      feelsLike: weather.feelsLike,
      maxRainChance: weather.maxRainChance,
      maxUv: weather.maxUv,
    );
    final text = Theme.of(context).textTheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${weather.feelsLike.round()}°',
                style: text.displayLarge?.copyWith(
                    color: _ink, fontWeight: FontWeight.w700, height: 0.9)),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Hà Nội',
                    style: text.titleMedium?.copyWith(
                        color: _ink, fontWeight: FontWeight.w700)),
                Text('Thực tế ${weather.temp.round()}° · '
                    'cao ${weather.todayMax.round()}° · '
                    'thấp ${weather.todayMin.round()}°',
                    style: text.bodySmall?.copyWith(color: _muted)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        _BongSays(say: outfit.say, mood: outfit.mood),
        const SizedBox(height: 12),
        _OutfitCard(items: outfit.items),
        const SizedBox(height: 12),
        _HourlyCard(hours: weather.hours),
        const SizedBox(height: 12),
        _StatsRow(weather: weather),
      ],
    );
  }
}

class _BongSays extends StatelessWidget {
  const _BongSays({required this.say, required this.mood});

  final String say;
  final Mood mood;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Bong(mood: mood, width: 120),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFDED4C6), width: 2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(say,
                style: const TextStyle(
                    color: _ink, fontWeight: FontWeight.w600, height: 1.35)),
          ),
        ),
      ],
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _accent, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HÔM NAY MẶC',
              style: TextStyle(
                  color: _ink,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in items)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                      color: _ink, borderRadius: BorderRadius.circular(999)),
                  child: Text(item,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.hours});

  final List<HourPoint> hours;

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) return const SizedBox.shrink();
    // Cột cao theo nhiệt độ cảm nhận, thấp nhất 30 px, cao nhất 80 px.
    final lo = hours.map((h) => h.feelsLike).reduce((a, b) => a < b ? a : b);
    final hi = hours.map((h) => h.feelsLike).reduce((a, b) => a > b ? a : b);
    double barHeight(double v) =>
        hi == lo ? 55 : 30 + (v - lo) / (hi - lo) * 50;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _surface2, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('THEO GIỜ · CẢM GIÁC (°C)',
              style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SizedBox(
            height: 124,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in hours)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('${h.feelsLike.round()}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: _muted,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Container(
                            height: barHeight(h.feelsLike),
                            decoration: BoxDecoration(
                              color: h.feelsLike >= 30 ? _accent : _cool,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(7),
                                  bottom: Radius.circular(3)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text('${h.hour}h',
                              style: const TextStyle(
                                  fontSize: 10, color: _muted)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final uv = weather.maxUv;
    final aqi = weather.aqi;
    return Row(
      children: [
        Expanded(
            child: _Stat(
                value: uv.round().toString(),
                label: uv >= 8 ? 'UV rất cao' : uv >= 6 ? 'UV cao' : 'UV',
                color: uv >= 6 ? _warn : _ok)),
        const SizedBox(width: 8),
        Expanded(
            child: _Stat(
                value: aqi?.toString() ?? '—',
                label: aqi == null ? 'AQI chưa có' : _aqiLabel(aqi),
                color: aqi == null || aqi <= 100 ? _ok : _warn)),
        const SizedBox(width: 8),
        Expanded(
            child: _Stat(
                value: '${weather.maxRainChance}%',
                label: 'Mưa cao nhất',
                color: weather.maxRainChance >= 50 ? _cool : _ink)),
      ],
    );
  }

  String _aqiLabel(int aqi) {
    if (aqi <= 50) return 'AQI tốt';
    if (aqi <= 100) return 'AQI khá';
    if (aqi <= 150) return 'AQI kém';
    return 'AQI xấu';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: _surface2, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 140, child: Image.asset('assets/bong.png')),
            const SizedBox(height: 12),
            const Text('Bông chưa lấy được thời tiết',
                style: TextStyle(
                    color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, fontSize: 12)),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
