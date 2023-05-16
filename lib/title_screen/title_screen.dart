import 'package:flutter/material.dart';

import '../assets.dart';
import '../styles.dart'; // Add this import

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  final _finalReceiveLightAmt = 0.7; // Add this attribute
  final _finalEmitLightAmt = 0.5; // And this attribute

  @override
  Widget build(BuildContext context) {
    // 처음엔 녹색 계열
    final orbColor = AppColors.orbColors[0]; // Add this final variable
    final emitColor = AppColors.emitColors[0]; // And this one

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          // 배경 이미지를 같은 레이어에 쭉 쌓은 느낌
          children: [
            /// Bg-Base
            Image.asset(AssetPaths.titleBgBase),

            /// Bg-Receive
            _LitImage(
              // Modify from here...
              color: orbColor,
              imgSrc: AssetPaths.titleBgReceive,
              lightAmt: _finalReceiveLightAmt,
            ), // to here.

            /// Mg-Base
            _LitImage(
              // Modify from here...
              imgSrc: AssetPaths.titleMgBase,
              color: orbColor,
              lightAmt: _finalReceiveLightAmt,
            ), // to here.

            /// Mg-Receive
            _LitImage(
              // Modify from here...
              imgSrc: AssetPaths.titleMgReceive,
              color: orbColor,
              lightAmt: _finalReceiveLightAmt,
            ), // to here.

            /// Mg-Emit
            _LitImage(
              // Modify from here...
              imgSrc: AssetPaths.titleMgEmit,
              color: emitColor,
              lightAmt: _finalEmitLightAmt,
            ), // to here.

            /// Fg-Rocks
            Image.asset(AssetPaths.titleFgBase),

            /// Fg-Receive
            _LitImage(
              // Modify from here...
              imgSrc: AssetPaths.titleFgReceive,
              color: orbColor,
              lightAmt: _finalReceiveLightAmt,
            ), // to here.

            /// Fg-Emit
            _LitImage(
              // Modify from here...
              imgSrc: AssetPaths.titleFgEmit,
              color: emitColor,
              lightAmt: _finalEmitLightAmt,
            ), // to here.
          ],
        ),
      ),
    );
  }
}

/// 불러온 이미지를 설정된 색과 빛의 밝기에 따라 블렌딩
class _LitImage extends StatelessWidget {
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
