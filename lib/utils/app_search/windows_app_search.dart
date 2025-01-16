// import 'dart:io';
// import 'dart:ffi';
// import 'package:f_tools/utils/app_search/app_search.dart';
// import 'package:path/path.dart' as path;
// import 'package:win32/win32.dart';
// import 'package:ffi/ffi.dart';

// class WindowsAppSearch implements AppSearch {
//   final _startMenuPaths = [
//     path.join(
//         'C:', 'ProgramData', 'Microsoft', 'Windows', 'Start Menu', 'Programs'),
//     path.join(Platform.environment['APPDATA']!, 'Microsoft', 'Windows',
//         'Start Menu', 'Programs')
//   ];

//   @override
//   Future<List<AppInfo>> getApps() async {
//     final apps = <AppInfo>[];

//     for (final dir in _startMenuPaths) {
//       await _scanDirectory(dir, apps);
//     }

//     return apps;
//   }

//   Future<void> _scanDirectory(String directory, List<AppInfo> apps) async {
//     try {
//       final dir = Directory(directory);
//       await for (final entity in dir.list(recursive: true)) {
//         if (entity is File && path.extension(entity.path) == '.lnk') {
//           final appInfo = await _getLnkInfo(entity.path);
//           if (appInfo != null) {
//             apps.add(appInfo);
//           }
//         }
//       }
//     } catch (e) {
//       print('扫描目录失败: $directory - $e');
//     }
//   }

//   Future<AppInfo?> _getLnkInfo(String lnkPath) async {
//     try {
//       // 使用win32 API读取快捷方式信息
//       final name = path.basenameWithoutExtension(lnkPath);
//       final target = await _getShortcutTarget(lnkPath);

//       if (target != null && !target.toLowerCase().contains('unin')) {
//         return AppInfo(
//           name: name,
//           path: target,
//           icon: await _extractIcon(target),
//           keywords: _generateKeywords(name),
//           action: 'start "" "$target"',
//           description: target,
//         );
//       }
//     } catch (e) {
//       print('读取快捷方式失败: $lnkPath - $e');
//     }
//     return null;
//   }

//   Future<String?> _getShortcutTarget(String lnkPath) async {
//     final shellLink = CoCreateInstance(
//       CLSID_ShellLink,
//       nullptr,
//       CLSCTX_INPROC_SERVER,
//       IID_IShellLink,
//     );

//     try {
//       final persistFile = IShellLinkW.from(shellLink)
//           .QueryInterface<IPersistFile>(IID_IPersistFile);

//       final lpPath = lnkPath.toNativeUtf16();
//       try {
//         final hr = persistFile.Load(lpPath, STGM_READ);
//         if (FAILED(hr)) {
//           return null;
//         }

//         final shellLinkW = IShellLinkW.from(shellLink);
//         final buffer = calloc<Uint16>(MAX_PATH).cast<Utf16>();
//         final findData = calloc<WIN32_FIND_DATAW>();

//         try {
//           final hr =
//               shellLinkW.GetPath(buffer, MAX_PATH, findData, SLGP_UNCPRIORITY);
//           if (FAILED(hr)) {
//             return null;
//           }

//           return buffer.toDartString();
//         } finally {
//           calloc.free(buffer);
//           calloc.free(findData);
//         }
//       } finally {
//         free(lpPath);
//         persistFile.Release();
//       }
//     } finally {
//       IShellLinkW.from(shellLink).Release();
//     }
//   }

//   Future<String?> _extractIcon(String exePath) async {
//     try {
//       final tempDir = Directory.systemTemp;
//       final iconDir = Directory(path.join(tempDir.path, 'ProcessIcon'));

//       // 确保图标目录存在
//       if (!await iconDir.exists()) {
//         await iconDir.create();
//       }

//       final fileName = path.basenameWithoutExtension(exePath);
//       final iconPath =
//           path.join(iconDir.path, '${Uri.encodeComponent(fileName)}.png');

//       // 如果图标已存在则直接返回
//       if (await File(iconPath).exists()) {
//         return 'file://$iconPath';
//       }

//       // 提取图标
//       final hInstance = GetModuleHandle(nullptr);
//       final hIcon =
//           ExtractAssociatedIcon(hInstance, exePath.toNativeUtf16(), nullptr);

//       if (hIcon == 0) {
//         return null;
//       }

//       try {
//         // 创建兼容的DC
//         final hdc = GetDC(NULL);
//         if (hdc == NULL) {
//           return null;
//         }

//         try {
//           // 创建内存DC
//           final hdcMem = CreateCompatibleDC(hdc);
//           if (hdcMem == NULL) {
//             return null;
//           }

//           try {
//             // 创建位图
//             final hbmp = CreateCompatibleBitmap(hdc, 32, 32);
//             if (hbmp == NULL) {
//               return null;
//             }

//             try {
//               // 选择位图
//               final hbmpOld = SelectObject(hdcMem, hbmp);

//               // 绘制图标
//               DrawIcon(hdcMem, 0, 0, hIcon);

//               // 保存为PNG
//               await _saveBitmapAsPng(hbmp, iconPath);

//               SelectObject(hdcMem, hbmpOld);
//               return 'file://$iconPath';
//             } finally {
//               DeleteObject(hbmp);
//             }
//           } finally {
//             DeleteDC(hdcMem);
//           }
//         } finally {
//           ReleaseDC(NULL, hdc);
//         }
//       } finally {
//         DestroyIcon(hIcon);
//       }
//     } catch (e) {
//       print('提取图标失败: $exePath - $e');
//       return null;
//     }
//   }

//   Future<void> _saveBitmapAsPng(int hBitmap, String filePath) async {
//     // 注意：这里需要使用一个图像处理库来完成位图到PNG的转换
//     // 可以使用 image 包或其他支持Windows GDI的图像处理库
//     // 这里仅作为示例，实际实现需要根据具体使用的图像库来完成
//     throw UnimplementedError('需要实现位图到PNG的转换');
//   }

//   List<String> _generateKeywords(String appName) {
//     final keywords = <String>[appName];

//     // 添加应用名称的小写形式
//     keywords.add(appName.toLowerCase());

//     // 如果应用名称包含空格，添加无空格版本
//     if (appName.contains(' ')) {
//       keywords.add(appName.replaceAll(' ', ''));
//     }

//     // 添加首字母缩写
//     final initials = appName
//         .split(' ')
//         .where((word) => word.isNotEmpty)
//         .map((word) => word[0])
//         .join()
//         .toLowerCase();
//     if (initials.length > 1) {
//       keywords.add(initials);
//     }

//     // 如果包含中文字符，可以添加拼音支持
//     if (_containsChinese(appName)) {
//       // TODO: 添加拼音支持
//       // 需要引入拼音转换库
//     }

//     return keywords;
//   }

//   bool _containsChinese(String text) {
//     return RegExp(r'[\u4e00-\u9fa5]').hasMatch(text);
//   }
// }
