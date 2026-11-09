import 'package:flutter_test/flutter_test.dart';
import 'package:troi_hom_nay/outfit.dart';

void main() {
  group('recommendOutfit - quần áo theo nhiệt độ cảm nhận', () {
    test('15° lạnh: áo khoác dày, tâm trạng lạnh', () {
      final o = recommendOutfit(feelsLike: 15, maxRainChance: 0, maxUv: 2);
      expect(o.items, contains('Áo khoác dày'));
      expect(o.mood, Mood.cold);
    });

    test('25° se mát: áo thun + khoác mỏng', () {
      final o = recommendOutfit(feelsLike: 25, maxRainChance: 0, maxUv: 2);
      expect(o.items, containsAll(['Áo thun', 'Khoác mỏng']));
    });

    test('28° ấm: chỉ áo thun, không khoác', () {
      final o = recommendOutfit(feelsLike: 28, maxRainChance: 0, maxUv: 2);
      expect(o.items, contains('Áo thun'));
      expect(o.items, isNot(contains('Khoác mỏng')));
    });

    test('34° nóng: đồ thoáng', () {
      final o = recommendOutfit(feelsLike: 34, maxRainChance: 0, maxUv: 2);
      expect(o.items, contains('Đồ thoáng mát'));
    });
  });

  group('recommendOutfit - mưa và nắng', () {
    test('mưa từ 50%: mang ô, tâm trạng mưa', () {
      final o = recommendOutfit(feelsLike: 27, maxRainChance: 60, maxUv: 2);
      expect(o.items, contains('Ô'));
      expect(o.mood, Mood.rain);
    });

    test('mưa 30-49%: chỉ nhắc ô gấp', () {
      final o = recommendOutfit(feelsLike: 27, maxRainChance: 40, maxUv: 2);
      expect(o.items, contains('Ô gấp'));
      expect(o.mood, isNot(Mood.rain));
    });

    test('UV từ 8: kính râm và kem chống nắng', () {
      final o = recommendOutfit(feelsLike: 30, maxRainChance: 0, maxUv: 9);
      expect(o.items, containsAll(['Kính râm', 'Kem chống nắng']));
      expect(o.mood, Mood.sunny);
    });

    test('UV 6-7: chỉ kem chống nắng', () {
      final o = recommendOutfit(feelsLike: 30, maxRainChance: 0, maxUv: 6);
      expect(o.items, contains('Kem chống nắng'));
      expect(o.items, isNot(contains('Kính râm')));
    });

    test('ưu tiên tâm trạng: mưa > nắng gắt > lạnh > bình thường', () {
      expect(
          recommendOutfit(feelsLike: 15, maxRainChance: 80, maxUv: 9).mood,
          Mood.rain);
      expect(
          recommendOutfit(feelsLike: 15, maxRainChance: 0, maxUv: 9).mood,
          Mood.sunny);
      expect(
          recommendOutfit(feelsLike: 15, maxRainChance: 0, maxUv: 1).mood,
          Mood.cold);
      expect(
          recommendOutfit(feelsLike: 26, maxRainChance: 0, maxUv: 1).mood,
          Mood.normal);
    });
  });

  test('câu Bông nói không rỗng', () {
    final o = recommendOutfit(feelsLike: 26, maxRainChance: 0, maxUv: 1);
    expect(o.say, isNotEmpty);
  });
}
