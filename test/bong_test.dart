import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:troi_hom_nay/bong.dart';
import 'package:troi_hom_nay/outfit.dart';

void main() {
  // Chỉ kiểm tra widget dựng được và có/không có lớp SVG phụ kiện.
  // Không chứng minh phụ kiện nằm đúng chỗ: cái đó phải nhìn trên máy.
  for (final entry in {
    Mood.rain: 2, // vũng nước phía sau + ô phía trước
    Mood.sunny: 1,
    Mood.cold: 1,
    Mood.normal: 0,
  }.entries) {
    testWidgets('Bông mood ${entry.key.name}: ${entry.value} lớp SVG',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: Bong(mood: entry.key, width: 200)),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(SvgPicture), findsNWidgets(entry.value));
      expect(tester.takeException(), isNull);
    });
  }
}
