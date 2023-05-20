import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Add this import

import '../assets.dart';
import '../styles.dart';
import 'title_screen_ui.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  /// focusable_control_builder 패키지에서 isHovered 를 이용하여 마우스 움직임 감지
  Color get _emitColor => AppColors.emitColors[_difficultyOverride ?? _difficulty];
  Color get _orbColor => AppColors.orbColors[_difficultyOverride ?? _difficulty];

  /// Currently selected difficulty
  int _difficulty = 0;

  /// Currently focused difficulty (if any)
  int? _difficultyOverride;

  void _handleDifficultyPressed(int value) {
    setState(() => _difficulty = value);
  }

  void _handleDifficultyFocused(int? value) {
    setState(() => _difficultyOverride = value);
  }

  final _finalReceiveLightAmt = 0.7;
  final _finalEmitLightAmt = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // 난이도에 따라 자연스럽게 배경색이 바뀌는 연출
        child: _AnimatedColors(
          // Edit from here...
          orbColor: _orbColor,
          emitColor: _emitColor,
          builder: (_, orbColor, emitColor) {
            return Stack(
              children: [
                /// Bg-Base
                Image.asset(AssetPaths.titleBgBase),

                /// Bg-Receive
                _LitImage(
                  color: orbColor,
                  imgSrc: AssetPaths.titleBgReceive,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Mg-Base
                _LitImage(
                  imgSrc: AssetPaths.titleMgBase,
                  color: orbColor,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Mg-Receive
                _LitImage(
                  imgSrc: AssetPaths.titleMgReceive,
                  color: orbColor,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Mg-Emit
                _LitImage(
                  imgSrc: AssetPaths.titleMgEmit,
                  color: emitColor,
                  lightAmt: _finalEmitLightAmt,
                ),

                /// Fg-Rocks
                Image.asset(AssetPaths.titleFgBase),

                /// Fg-Receive
                _LitImage(
                  imgSrc: AssetPaths.titleFgReceive,
                  color: orbColor,
                  lightAmt: _finalReceiveLightAmt,
                ),

                /// Fg-Emit
                _LitImage(
                  imgSrc: AssetPaths.titleFgEmit,
                  color: emitColor,
                  lightAmt: _finalEmitLightAmt,
                ),

                /// UI
                Positioned.fill(
                  child: TitleScreenUi(
                    difficulty: _difficulty,
                    onDifficultyFocused: _handleDifficultyFocused,
                    onDifficultyPressed: _handleDifficultyPressed,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 1.seconds, delay: .3.seconds);
          },
        ), // to here.
      ),
    );
  }
}

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
    final hsl = HSLColor.fromColor(color);
    return Image.asset(
      imgSrc,
      color: hsl.withLightness(hsl.lightness * lightAmt).toColor(),
      colorBlendMode: BlendMode.modulate,
    );
  }
}

class _AnimatedColors extends StatelessWidget {
  const _AnimatedColors({
    required this.emitColor,
    required this.orbColor,
    required this.builder,
  });

  final Color emitColor;
  final Color orbColor;

  // 배경 이미지 스택을 그리는 위젯이 전달 됨
  final Widget Function(BuildContext context, Color orbColor, Color emitColor) builder;

  /// 실제 위젯을 생성
  @override
  Widget build(BuildContext context) {
    final duration = .5.seconds;
    // 첫번째 애니메이션
    return TweenAnimationBuilder(
      // tween 의미: 애니메이션 시퀀스에서 중간 프레임을 생성하여 부드러운 움직임을 표현
      tween: ColorTween(begin: emitColor, end: emitColor),
      duration: duration,
      builder: (_, emitColor, __) {
        // 두번째 애니메이션
        return TweenAnimationBuilder(
          tween: ColorTween(begin: orbColor, end: orbColor),
          duration: duration,
          builder: (context, orbColor, __) {
            // builder 함수를 사용하여 최종 위젯 생성
            return builder(context, orbColor!, emitColor!);
          },
        );
      },
    );
  }
}
