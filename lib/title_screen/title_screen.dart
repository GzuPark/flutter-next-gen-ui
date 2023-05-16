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
