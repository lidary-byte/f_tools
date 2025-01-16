/*
 * @Description: 
 * @Author: lidary-byte lidaryl@163.com
 * @Date: 2025-01-15 16:06:13
 * @LastEditors: lidary-byte lidaryl@163.com
 * @LastEditTime: 2025-01-16 17:07:31
 */
import 'package:f_tools/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWindow();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FTools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      getPages: AppRoutes.routes,
      initialRoute: AppRoutePath.home,
    );
  }
}

Future initWindow() async {
  // 初始化窗口管理器
  await windowManager.ensureInitialized();

  // 配置窗口属性
  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 400),
    center: true,
    skipTaskbar: true,
    alwaysOnTop: true,
    backgroundColor: Colors.black,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  // await windowManager.setResizable(false);
  // await windowManager.setMaximizable(false);
  // await windowManager.setMinimizable(false);
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    // await Window.setEffect(effect: WindowEffect.acrylic);
    await windowManager.setHasShadow(true);
    await windowManager.setOpacity(0.8);
  });
  // , () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // }
}
