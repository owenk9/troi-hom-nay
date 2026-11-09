/// Luật gợi ý mặc gì. Hàm thuần túy, không gọi mạng, để test được.
enum Mood { rain, sunny, cold, normal }

class Outfit {
  const Outfit({required this.items, required this.mood, required this.say});

  final List<String> items;
  final Mood mood;
  final String say;
}

/// [feelsLike] là nhiệt độ cảm nhận (°C), [maxRainChance] là xác suất mưa cao
/// nhất trong ngày (%), [maxUv] là chỉ số UV cao nhất trong ngày.
Outfit recommendOutfit({
  required double feelsLike,
  required int maxRainChance,
  required double maxUv,
}) {
  final items = <String>[];

  if (feelsLike < 18) {
    items.add('Áo khoác dày');
  } else if (feelsLike < 22) {
    items.addAll(['Áo dài tay', 'Khoác mỏng']);
  } else if (feelsLike < 27) {
    items.addAll(['Áo thun', 'Khoác mỏng']);
  } else if (feelsLike < 32) {
    items.add('Áo thun');
  } else {
    items.add('Đồ thoáng mát');
  }

  if (maxRainChance >= 50) {
    items.add('Ô');
  } else if (maxRainChance >= 30) {
    items.add('Ô gấp');
  }

  if (maxUv >= 8) {
    items.addAll(['Kính râm', 'Kem chống nắng']);
  } else if (maxUv >= 6) {
    items.add('Kem chống nắng');
  }

  // Thứ tự ưu tiên tâm trạng của Bông: mưa > nắng gắt > lạnh > bình thường.
  final Mood mood;
  final String say;
  if (maxRainChance >= 50) {
    mood = Mood.rain;
    say = 'Hôm nay có mưa, bạn nhớ mang ô nha!';
  } else if (maxUv >= 8) {
    mood = Mood.sunny;
    say = 'Nắng gắt lắm, mình đeo kính râm rồi. Bạn nhớ bôi kem chống nắng!';
  } else if (feelsLike < 22) {
    mood = Mood.cold;
    say = 'Trời se lạnh, mình quàng khăn rồi. Bạn mặc ấm nhé!';
  } else {
    mood = Mood.normal;
    say = 'Hôm nay thời tiết dễ chịu, mình đi chơi thôi!';
  }

  return Outfit(items: items, mood: mood, say: say);
}
