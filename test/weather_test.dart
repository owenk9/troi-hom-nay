import 'package:flutter_test/flutter_test.dart';
import 'package:troi_hom_nay/weather.dart';

/// Dữ liệu mẫu dựng theo cấu trúc Open-Meteo mà mình dùng. Test này chỉ chứng
/// minh phần đọc dữ liệu đúng với cấu trúc đó, không chứng minh API trả đúng
/// như vậy. Điều đó cần kiểm tra bằng một lệnh gọi thật.
Map<String, dynamic> sample() => {
      'current': {'temperature_2m': 24.0, 'apparent_temperature': 27.2},
      'daily': {
        'temperature_2m_max': [29.0, 28.0],
        'temperature_2m_min': [22.0, 21.0],
        'uv_index_max': [7.4, 6.0],
      },
      'hourly': {
        // 48 giờ, giờ thứ h có nhiệt độ cảm nhận 20 + h/2.
        'apparent_temperature': [for (var h = 0; h < 48; h++) 20 + h / 2],
        // mưa 40% lúc 19h, còn lại 0.
        'precipitation_probability': [
          for (var h = 0; h < 48; h++) h == 19 ? 40 : 0
        ],
      },
    };

void main() {
  test('đọc nhiệt độ, cao/thấp, UV hôm nay', () {
    final w = Weather.fromForecastJson(sample());
    expect(w.temp, 24.0);
    expect(w.feelsLike, 27.2);
    expect(w.todayMax, 29.0);
    expect(w.todayMin, 22.0);
    expect(w.maxUv, 7.4);
  });

  test('xác suất mưa cao nhất lấy trong khung 6h-22h', () {
    final w = Weather.fromForecastJson(sample());
    expect(w.maxRainChance, 40);
  });

  test('mưa lúc 3h sáng không được tính', () {
    final json = sample();
    (json['hourly']['precipitation_probability'] as List)[3] = 90;
    expect(Weather.fromForecastJson(json).maxRainChance, 40);
  });

  test('biểu đồ theo giờ lấy đúng 6 mốc', () {
    final w = Weather.fromForecastJson(sample());
    expect(w.hours.map((p) => p.hour), chartHours);
    expect(w.hours.first.feelsLike, 23.5); // 20 + 7/2
  });

  test('AQI truyền vào được giữ lại, không có thì null', () {
    expect(Weather.fromForecastJson(sample(), aqi: 62).aqi, 62);
    expect(Weather.fromForecastJson(sample()).aqi, isNull);
  });
}
