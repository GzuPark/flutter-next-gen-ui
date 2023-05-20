import 'package:extra_alignments/extra_alignments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusable_control_builder/focusable_control_builder.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart'; // Add this import

import '../assets.dart';
import '../common/shader_effect.dart'; // And this import
import '../common/ticking_builder.dart'; // And this import
import '../common/ui_scaler.dart';
import '../styles.dart';

class TitleScreenUi extends StatelessWidget {
  const TitleScreenUi({
    super.key,
    required this.difficulty,
    required this.onDifficultyPressed,
    required this.onDifficultyFocused,
  });

  final int difficulty;
  final void Function(int difficulty) onDifficultyPressed;
  final void Function(int? difficulty) onDifficultyFocused;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 50),
      child: Stack(
        children: [
          /// Title Text
          const TopLeft(
            // Add a const here, as well
            child: UiScaler(
              alignment: Alignment.topLeft,
              child: _TitleText(),
            ),
          ),

          /// Difficulty Btns
          BottomLeft(
            // Add from here...
            child: UiScaler(
              alignment: Alignment.bottomLeft,
              child: _DifficultyBtns(
                difficulty: difficulty,
                onDifficultyPressed: onDifficultyPressed,
                onDifficultyFocused: onDifficultyFocused,
              ),
            ),
          ),

          /// StartBtn
          BottomRight(
            // Add from here...
            child: UiScaler(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 40),
                child: _StartBtn(onPressed: () {}),
              ),
            ),
          ), // to here.
        ],
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  const _TitleText();

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      // Modify this line
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(20),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(-(TextStyles.h1.letterSpacing! * .5), 0),
              child: Text('OUTPOST', style: TextStyles.h1),
            ),
            Image.asset(AssetPaths.titleSelectedLeft, height: 65),
            Text('57', style: TextStyles.h2),
            Image.asset(AssetPaths.titleSelectedRight, height: 65),
          ], // Edit from here...
          // https://pub.dev/packages/flutter_animate
          // It also adds an .animate() extension method to all widgets, which wraps the widget in Animate().
          // 라고 하는데 Animate()를 따로 쓰지 않아도 모든 위젯에 animate() 메서드를 사용할 수 있는 것 같음
        ).animate().fadeIn(delay: .8.seconds, duration: .7.seconds),
        Text('INTO THE UNKNOWN', style: TextStyles.h3).animate().fadeIn(delay: 1.seconds, duration: .7.seconds),
      ],
    );
    return Consumer<FragmentPrograms?>(
      // Add from here...
      builder: (context, fragmentPrograms, _) {
        if (fragmentPrograms == null) return content;
        return TickingBuilder(
          builder: (context, time) {
            return AnimatedSampler(
              (image, size, canvas) {
                const double overdrawPx = 30;
                // ui_glitch.frag 내용 호출, FragmentShader 객체 생성
                final shader = fragmentPrograms.ui.fragmentShader();
                shader
                  ..setFloat(0, size.width)
                  ..setFloat(1, size.height)
                  ..setFloat(2, time)
                  ..setImageSampler(0, image);
                Rect rect = Rect.fromLTWH(-overdrawPx, -overdrawPx, size.width + overdrawPx, size.height + overdrawPx);
                canvas.drawRect(rect, Paint()..shader = shader);
              },
              child: content,
            );
          },
        );
      },
    ); // to here.
  }
}

class _DifficultyBtns extends StatelessWidget {
  const _DifficultyBtns({
    required this.difficulty,
    required this.onDifficultyPressed,
    required this.onDifficultyFocused,
  });

  final int difficulty;
  final void Function(int difficulty) onDifficultyPressed;
  final void Function(int? difficulty) onDifficultyFocused;

  @override
  Widget build(BuildContext context) {
    // 난이도에 따라 버튼 변경
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DifficultyBtn(
          label: 'Casual',
          selected: difficulty == 0,
          onPressed: () => onDifficultyPressed(0),
          onHover: (over) => onDifficultyFocused(over ? 0 : null),
        ) // Add from here...
            // Title 과 마찬가지로 효과 적용, 다만 난이도 순서대로 나오도록 약간씩의 시간 차이 존재
            .animate()
            .fadeIn(delay: 1.3.seconds, duration: .35.seconds)
            .slide(begin: const Offset(0, .2)), // to here
        _DifficultyBtn(
          label: 'Normal',
          selected: difficulty == 1,
          onPressed: () => onDifficultyPressed(1),
          onHover: (over) => onDifficultyFocused(over ? 1 : null),
        ) // Add from here...
            .animate()
            .fadeIn(delay: 1.5.seconds, duration: .35.seconds)
            .slide(begin: const Offset(0, .2)), // to here
        _DifficultyBtn(
          label: 'Hardcore',
          selected: difficulty == 2,
          onPressed: () => onDifficultyPressed(2),
          onHover: (over) => onDifficultyFocused(over ? 2 : null),
        ) // Add from here...
            .animate()
            .fadeIn(delay: 1.7.seconds, duration: .35.seconds)
            .slide(begin: const Offset(0, .2)), // to here
        const Gap(20),
      ],
    );
  }
}

class _DifficultyBtn extends StatelessWidget {
  const _DifficultyBtn({
    required this.selected,
    required this.onPressed,
    required this.onHover,
    required this.label,
  });
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final void Function(bool hasFocus) onHover;

  @override
  Widget build(BuildContext context) {
    // https://pub.dev/packages/focusable_control_builder
    return FocusableControlBuilder(
      onPressed: onPressed,
      onHoverChanged: (_, state) => onHover.call(state.isHovered),
      builder: (_, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 250,
            height: 60,
            child: Stack(
              children: [
                /// Bg with fill and outline
                // 마우스 오버 혹은 선택 동작으로 난이도가 약간 불투명해지는 것을 애니메이션 효과로 진행
                AnimatedOpacity(
                  // Edit from here
                  opacity: (!selected && (state.isHovered || state.isFocused)) ? 1 : 0,
                  duration: .3.seconds,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D1FF).withOpacity(.1),
                      border: Border.all(color: Colors.white, width: 5),
                    ),
                  ),
                ), // to here.

                if (state.isHovered || state.isFocused) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D1FF).withOpacity(.1),
                    ),
                  ),
                ],

                /// cross-hairs (selected state)
                if (selected) ...[
                  CenterLeft(
                    child: Image.asset(AssetPaths.titleSelectedLeft),
                  ),
                  CenterRight(
                    child: Image.asset(AssetPaths.titleSelectedRight),
                  ),
                ],

                /// Label
                Center(
                  child: Text(label.toUpperCase(), style: TextStyles.btn),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartBtn extends StatefulWidget {
  const _StartBtn({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_StartBtn> createState() => _StartBtnState();
}

class _StartBtnState extends State<_StartBtn> {
  AnimationController? _btnAnim;
  bool _wasHovered = false;

  @override
  Widget build(BuildContext context) {
    // https://pub.dev/packages/focusable_control_builder
    return FocusableControlBuilder(
      cursor: SystemMouseCursors.click,
      onPressed: widget.onPressed,
      builder: (_, state) {
        if ((state.isHovered || state.isFocused) && !_wasHovered && _btnAnim?.status != AnimationStatus.forward) {
          _btnAnim?.forward(from: 0);
        }
        _wasHovered = (state.isHovered || state.isFocused);
        return SizedBox(
          width: 520,
          height: 100,
          child: Stack(
            children: [
              Positioned.fill(child: Image.asset(AssetPaths.titleStartBtn)),
              if (state.isHovered || state.isFocused) ...[
                Positioned.fill(child: Image.asset(AssetPaths.titleStartBtnHover)),
              ],
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('START MISSION', style: TextStyles.btn.copyWith(fontSize: 24, letterSpacing: 18)),
                  ],
                ),
              ),
            ],
          ) // Edit from here...
              // 마우스 오버하면 검은색이 왼쪽에서 오른쪽으로 지나가는 효과
              .animate(autoPlay: false, onInit: (c) => _btnAnim = c)
              .shimmer(duration: .7.seconds, color: Colors.black),
        ).animate().fadeIn(delay: 2.3.seconds).slide(begin: const Offset(0, .2));
      }, // to here.
    );
  }
}
