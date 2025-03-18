import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class WindowsConfig {
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'LawnMate Employee',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    await Window.setEffect(
      effect: WindowEffect.acrylic,
      color: Colors.white.withOpacity(0.8),
    );
  }

  static Future<void> setWindowSize(Size size) async {
    await windowManager.setSize(size);
  }

  static Future<void> setWindowPosition(Offset position) async {
    await windowManager.setPosition(position);
  }

  static Future<void> minimize() async {
    await windowManager.minimize();
  }

  static Future<void> maximize() async {
    await windowManager.maximize();
  }

  static Future<void> close() async {
    await windowManager.close();
  }
} 