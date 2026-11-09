import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'outfit.dart';

// Ảnh Bông (370x301) nằm trong khung tọa độ 370x344 như bản thiết kế web,
// chừa 40 đơn vị phía trên cho ô, mũ. Phụ kiện vẽ bằng SVG theo cùng khung.
const _boxW = 370.0;
const _boxH = 344.0;
const _imgW = 370.0;
const _imgH = 301.0;
const _imgTop = 40.0;
const _viewBox = '140 790 370 344';

String _svg(String body) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="$_viewBox">$body</svg>';

const _stroke = 'stroke="#1F1A17" stroke-linejoin="round" stroke-linecap="round"';

// Vũng nước dưới chân, nằm phía sau Bông.
final _rainBack = _svg(
    '<ellipse cx="330" cy="1124" rx="170" ry="9" fill="#9ED3EE" opacity=".65"/>');

final _umbrella = _svg('''
<g transform="translate(0 16)" $_stroke stroke-width="4">
<path d="M182 846 C182 806 250 794 330 794 C410 794 478 806 478 846 Q448 826 419 846 Q389 826 360 846 Q330 826 300 846 Q270 826 241 846 Q211 826 182 846 Z" fill="#4DA3DC"/>
<path d="M330 794 L241 846 M330 794 L330 832 M330 794 L419 846" fill="none" stroke-width="2.5" stroke-opacity=".55"/>
<path d="M330 794 L330 782" fill="none" stroke-width="5"/>
<path d="M215 818 Q245 802 290 799" fill="none" stroke="#fff" stroke-opacity=".5" stroke-width="5"/>
<path d="M166 868 q9 14 0 22 q-9 -8 0 -22Z M492 872 q9 14 0 22 q-9 -8 0 -22Z M160 925 q9 14 0 22 q-9 -8 0 -22Z M496 925 q9 14 0 22 q-9 -8 0 -22Z" fill="#6EC1EA" stroke-width="3"/>
</g>''');

final _shades = _svg('''
<g $_stroke stroke-width="3.5">
<path d="M236 910 L218 905 M311 916 L330 913" fill="none" stroke-width="4"/>
<path d="M235 908 L272 908 L272 927 Q272 942 254 942 Q237 942 235 927 Z" fill="#263238"/>
<path d="M274 913 L311 913 L311 932 Q311 947 293 947 Q276 947 274 932 Z" fill="#263238"/>
<path d="M231 907 L315 912" fill="none" stroke-width="5"/>
<path d="M272 916 Q273 913 274 921" fill="none" stroke-width="4"/>
<path d="M242 917 L252 917 M242 923 L247 923 M281 922 L291 922 M281 928 L286 928" stroke="#fff" stroke-opacity=".55" stroke-width="3.2" fill="none"/>
</g>''');

final _scarf = _svg('''
<g $_stroke stroke-width="4">
<path d="M192 1040 Q270 1078 366 1030 L368 1056 Q270 1100 198 1068 Z" fill="#2A9D8F"/>
<path d="M332 1060 L354 1110 L322 1106 Z" fill="#2A9D8F"/>
</g>''');

/// Phụ kiện vẽ phía sau Bông (null nếu không có).
String? _backFor(Mood mood) => mood == Mood.rain ? _rainBack : null;

/// Phụ kiện vẽ phía trước Bông (null nếu không có).
String? _frontFor(Mood mood) => switch (mood) {
      Mood.rain => _umbrella,
      Mood.sunny => _shades,
      Mood.cold => _scarf,
      Mood.normal => null,
    };

class Bong extends StatelessWidget {
  const Bong({super.key, required this.mood, this.width = 120});

  final Mood mood;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scale = width / _boxW;
    final back = _backFor(mood);
    final front = _frontFor(mood);
    return SizedBox(
      width: width,
      height: _boxH * scale,
      child: Stack(
        children: [
          if (back != null) Positioned.fill(child: SvgPicture.string(back)),
          Positioned(
            left: 0,
            top: _imgTop * scale,
            width: _imgW * scale,
            height: _imgH * scale,
            child: Image.asset('assets/bong.png', fit: BoxFit.fill),
          ),
          if (front != null) Positioned.fill(child: SvgPicture.string(front)),
        ],
      ),
    );
  }
}
