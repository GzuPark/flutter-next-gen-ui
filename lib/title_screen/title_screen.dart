import 'package:flutter/material.dart';

import '../assets.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // 배경 이미지를 같은 레이어에 쭉 쌓은 느낌
        child: Stack(
          children: [
            /// Bg-Base
            Image.asset(AssetPaths.titleBgBase),

            /// Bg-Receive
            Image.asset(AssetPaths.titleBgReceive),

            /// Mg-Base
            Image.asset(AssetPaths.titleMgBase),

            /// Mg-Receive
            Image.asset(AssetPaths.titleMgReceive),

            /// Mg-Emit
            Image.asset(AssetPaths.titleMgEmit),

            /// Fg-Rocks
            Image.asset(AssetPaths.titleFgBase),

            /// Fg-Receive
            Image.asset(AssetPaths.titleFgReceive),

            /// Fg-Emit
            Image.asset(AssetPaths.titleFgEmit),
          ],
        ),
      ),
    );
  }
}

/// 불러온 이미지를 설정된 색과 빛의 밝기에 따라 블렌딩
class _LitImage extends StatelessWidget {
  // Add from here...
  const _LitImage({
    required this.color,
    required this.imgSrc,
    required this.lightAmt,
  });
  final Color color;
  final String imgSrc;
  final double lightAmt;

  @override
  Widget build(BuildContext context) {
    /// 색을 HSL (for hue, saturation, lightness) 형태로 변환
    final hsl = HSLColor.fromColor(color);
    return Image.asset(
      imgSrc,
      // Receive, Emit에 따른 밝기 scale
      color: hsl.withLightness(hsl.lightness * lightAmt).toColor(),
      // 읽어온 이미지에 위에 설정한 색을 blending
      colorBlendMode: BlendMode.modulate,
    );
  }
}
