import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../assets.dart';
import '../orb_shader/orb_shader_config.dart';
import '../orb_shader/orb_shader_widget.dart';
import '../styles.dart';
import 'particle_overlay.dart'; // Add this import
import 'title_screen_ui.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> with SingleTickerProviderStateMixin {
  final _orbKey = GlobalKey<OrbShaderWidgetState>();

  /// Editable Settings
  /// 0-1, receive lighting strength
  final _minReceiveLightAmt = .35;
  final _maxReceiveLightAmt = .7;

  /// 0-1, emit lighting strength
  final _minEmitLightAmt = .5;
  final _maxEmitLightAmt = 1;

  /// Internal
  var _mousePos = Offset.zero;

  /// focusable_control_builder 패키지에서 isHovered 를 이용하여 마우스 움직임 감지
  Color get _emitColor => AppColors.emitColors[_difficultyOverride ?? _difficulty];
  Color get _orbColor => AppColors.orbColors[_difficultyOverride ?? _difficulty];

  /// Currently selected difficulty
  int _difficulty = 0;

  /// Currently focused difficulty (if any)
  int? _difficultyOverride;
  double _orbEnergy = 0;
  double _minOrbEnergy = 0;

  double get _finalReceiveLightAmt {
    // lerpDouble은 'dart:ui'에 있음, _orbEnergy로 min, max 사이로 보간
    final light = lerpDouble(_minReceiveLightAmt, _maxReceiveLightAmt, _orbEnergy) ?? 0;
    return light + _pulseEffect.value * .05 * _orbEnergy;
  }

  double get _finalEmitLightAmt {
    return lerpDouble(_minEmitLightAmt, _maxEmitLightAmt, _orbEnergy) ?? 0;
  }

  // orb의 pulse는 랜덤한 지속 시간으로 애니메이션 효과를 보여줌
  late final _pulseEffect = AnimationController(
    vsync: this,
    duration: _getRndPulseDuration(),
    lowerBound: -1,
    upperBound: 1,
  );

  Duration _getRndPulseDuration() => 100.ms + 200.ms * Random().nextDouble();

  // 난이도에 따라 에너지 최소 크기를 선정, 난이도가 높을 수록 최소 에너지 크기가 큼
  double _getMinEnergyForDifficulty(int difficulty) {
    if (difficulty == 1) {
      return .3;
    } else if (difficulty == 2) {
      return .6;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _pulseEffect.forward();
    _pulseEffect.addListener(_handlePulseEffectUpdate);
  }

  void _handlePulseEffectUpdate() {
    if (_pulseEffect.status == AnimationStatus.completed) {
      _pulseEffect.reverse();
      _pulseEffect.duration = _getRndPulseDuration();
    } else if (_pulseEffect.status == AnimationStatus.dismissed) {
      _pulseEffect.duration = _getRndPulseDuration();
      _pulseEffect.forward();
    }
  }

  // 난이도를 선택할 경우 해당 난이도의 가장 작은 에너지로 애니메이션 시작
  void _handleDifficultyPressed(int value) {
    setState(() => _difficulty = value);
    _bumpMinEnergy();
  }

  Future<void> _bumpMinEnergy([double amount = 0.1]) async {
    setState(() {
      _minOrbEnergy = _getMinEnergyForDifficulty(_difficulty) + amount;
    });
    await Future<void>.delayed(.2.seconds);
    setState(() {
      _minOrbEnergy = _getMinEnergyForDifficulty(_difficulty);
    });
  }

  void _handleStartPressed() => _bumpMinEnergy(0.3);

  void _handleDifficultyFocused(int? value) {
    setState(() {
      _difficultyOverride = value;
      if (value == null) {
        _minOrbEnergy = _getMinEnergyForDifficulty(_difficulty);
      } else {
        _minOrbEnergy = _getMinEnergyForDifficulty(value);
      }
    });
  }

  /// Update mouse position so the orbWidget can use it, doing it here prevents
  /// btns from blocking the mouse-move events in the widget itself.
  void _handleMouseMove(PointerHoverEvent e) {
    setState(() {
      _mousePos = e.localPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        // 난이도에 따라 자연스럽게 배경색이 바뀌는 연출
        child: MouseRegion(
          onHover: _handleMouseMove,
          child: _AnimatedColors(
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
                    pulseEffect: _pulseEffect,
                    lightAmt: _finalReceiveLightAmt,
                  ),

                  /// Orb
                  Positioned.fill(
                    child: Stack(
                      children: [
                        // Orb 구현체, 구현 방법에 대해 반드시 이해해보고 싶음
                        OrbShaderWidget(
                          key: _orbKey,
                          mousePos: _mousePos,
                          minEnergy: _minOrbEnergy,
                          config: OrbShaderConfig(
                            ambientLightColor: orbColor,
                            materialColor: orbColor,
                            lightColor: orbColor,
                          ),
                          onUpdate: (energy) => setState(() {
                            _orbEnergy = energy;
                          }),
                        ),
                      ],
                    ),
                  ),

                  /// Mg-Base
                  _LitImage(
                    imgSrc: AssetPaths.titleMgBase,
                    color: orbColor,
                    pulseEffect: _pulseEffect,
                    lightAmt: _finalReceiveLightAmt,
                  ),

                  /// Mg-Receive
                  _LitImage(
                    imgSrc: AssetPaths.titleMgReceive,
                    color: orbColor,
                    pulseEffect: _pulseEffect,
                    lightAmt: _finalReceiveLightAmt,
                  ),

                  /// Mg-Emit
                  _LitImage(
                    imgSrc: AssetPaths.titleMgEmit,
                    color: emitColor,
                    pulseEffect: _pulseEffect,
                    lightAmt: _finalEmitLightAmt,
                  ),

                  /// Particle Field
                  Positioned.fill(
                    // Add from here...
                    child: IgnorePointer(
                      child: ParticleOverlay(
                        color: orbColor,
                        energy: _orbEnergy,
                      ),
                    ),
                  ), // to here.

                  /// Fg-Rocks
                  Image.asset(AssetPaths.titleFgBase),

                  /// Fg-Receive
                  _LitImage(
                    imgSrc: AssetPaths.titleFgReceive,
                    color: orbColor,
                    pulseEffect: _pulseEffect,
                    lightAmt: _finalReceiveLightAmt,
                  ),

                  /// Fg-Emit
                  _LitImage(
                    imgSrc: AssetPaths.titleFgEmit,
                    color: emitColor,
                    pulseEffect: _pulseEffect,
                    lightAmt: _finalEmitLightAmt,
                  ),

                  /// UI
                  Positioned.fill(
                    child: TitleScreenUi(
                      difficulty: _difficulty,
                      onDifficultyFocused: _handleDifficultyFocused,
                      onDifficultyPressed: _handleDifficultyPressed,
                      onStartPressed: _handleStartPressed,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 1.seconds, delay: .3.seconds);
            },
          ),
        ),
      ),
    );
  }
}

class _LitImage extends StatelessWidget {
  const _LitImage({
    required this.color,
    required this.imgSrc,
    required this.pulseEffect, // Add this parameter
    required this.lightAmt,
  });
  final Color color;
  final String imgSrc;
  final AnimationController pulseEffect; // Add this attrubute
  final double lightAmt;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    // pulseEffect 이벤트가 일어나면 lightAmt 값에 따라 배경의 밝기가 변함
    return ListenableBuilder(
      // Edit from here...
      listenable: pulseEffect,
      builder: (context, child) {
        return Image.asset(
          imgSrc,
          color: hsl.withLightness(hsl.lightness * lightAmt).toColor(),
          colorBlendMode: BlendMode.modulate,
        );
      },
    ); // to here.
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
