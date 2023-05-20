import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:window_size/window_size.dart';

import 'assets.dart'; // Add this import
import 'title_screen/title_screen.dart';

void main() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowMinSize(const Size(800, 500));
  }
  // https://pub.dev/packages/flutter_animate
  Animate.restartOnHotReload = true; // Add this line
  runApp(
    // Edit from here...
    // https://docs.flutter.dev/ui/advanced/shaders
    // pubspec.yaml 에서 shader 영역에 파일을 지정하고 아래처럼 호출하면 컴파일을 하고 필요한 런타임 메타데이터를 생성
    FutureProvider<FragmentPrograms?>(
      // 각 frag 파일을 읽어오는 기능
      create: (context) => loadFragmentPrograms(),
      initialData: null,
      child: const NextGenApp(),
    ),
  ); // to here.
}

class NextGenApp extends StatelessWidget {
  const NextGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(brightness: Brightness.dark),
      home: const TitleScreen(),
    );
  }
}
