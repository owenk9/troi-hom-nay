import 'dart:convert';

import 'package:http/http.dart' as http;

/// Hà Nội. Bản đầu dùng vị trí cố định, chưa xin quyền định vị.
const hanoiLat = 21.0285;
const hanoiLon = 105.8542;

/// Các mốc giờ hiển thị trên biểu đồ theo giờ.
const chartHours = [7, 10, 13, 16, 19, 22];

class HourPoint {
  const HourPoint(this.hour, this.feelsLike);

  final int hour;
  final double feelsLike;
}

class Weather {
  const Weather({
    required this.temp,
    required this.feelsLike,
    required this.todayMax,
    required this.todayMin,
    required this.maxRainChance,
    required this.maxUv,
    required this.hours,
    this.aqi,
  });

  final double temp;
  final double feelsLike;
  final double todayMax;
  final double todayMin;
  final int maxRainChance;
  final double maxUv;
  final List<HourPoint> hours;
  final int? aqi;

  /// Đọc phản hồi của Open-Meteo `/v1/forecast`. Mảng `hourly` bắt đầu từ
  /// 00:00 hôm nay nên chỉ số mảng chính là giờ trong ngày.
  factory Weather.fromForecastJson(Map<String, dynamic> json, {int? aqi}) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;

    final feels = (hourly['apparent_temperature'] as List).cast<num?>();
    final rain = (hourly['precipitation_probability'] as List).cast<num?>();

    // Xác suất mưa cao nhất trong khung 6h-22h hôm nay.
    var maxRain = 0;
    for (var h = 6; h <= 22 && h < rain.length; h++) {
      final v = rain[h]?.round() ?? 0;
      if (v > maxRain) maxRain = v;
    }

    return Weather(
      temp: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      todayMax: (daily['temperature_2m_max'] as List).first.toDouble(),
      todayMin: (daily['temperature_2m_min'] as List).first.toDouble(),
      maxRainChance: maxRain,
      maxUv: ((daily['uv_index_max'] as List).first as num).toDouble(),
      hours: [
        for (final h in chartHours)
          if (h < feels.length && feels[h] != null)
            HourPoint(h, feels[h]!.toDouble()),
      ],
      aqi: aqi,
    );
  }
}

Future<Weather> fetchWeather({http.Client? client}) async {
  final c = client ?? http.Client();
  try {
    final forecastUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$hanoiLat',
      'longitude': '$hanoiLon',
      'current': 'temperature_2m,apparent_temperature',
      'hourly': 'apparent_temperature,precipitation_probability',
      'daily': 'temperature_2m_max,temperature_2m_min,uv_index_max',
      'timezone': 'Asia/Ho_Chi_Minh',
      'forecast_days': '2',
    });
    final res = await c.get(forecastUri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Open-Meteo trả về mã ${res.statusCode}');
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return Weather.fromForecastJson(json, aqi: await _fetchAqi(c));
  } finally {
    if (client == null) c.close();
  }
}

/// AQI là phần phụ: lỗi thì trả null để màn hình hiện "—", không làm hỏng cả trang.
Future<int?> _fetchAqi(http.Client c) async {
  try {
    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': '$hanoiLat',
      'longitude': '$hanoiLon',
      'current': 'us_aqi',
      'timezone': 'Asia/Ho_Chi_Minh',
    });
    final res = await c.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) return null;
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return ((json['current'] as Map<String, dynamic>)['us_aqi'] as num?)
        ?.round();
  } catch (_) {
    return null;
  }
}
