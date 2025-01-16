import 'dart:io';
import 'package:f_tools/models/app_info_model.dart';
import 'package:f_tools/utils/app_search/app_search.dart';
import 'package:path/path.dart' as path;

class LinuxAppSearch implements AppSearch {
  final _appPaths = [
    '/usr/share/applications',
    '/var/lib/snapd/desktop/applications',
    '${Platform.environment['HOME']}/.local/share/applications'
  ];

  @override
  Future<List<AppInfoModel>> getApps() async {
    final apps = <AppInfoModel>[];

    for (final dir in _appPaths) {
      await _scanDesktopFiles(dir, apps);
    }

    return apps;
  }

  Future<void> _scanDesktopFiles(
      String directory, List<AppInfoModel> apps) async {
    try {
      final dir = Directory(directory);
      await for (final entity in dir.list()) {
        if (entity is File && path.extension(entity.path) == '.desktop') {
          final appInfo = await _parseDesktopFile(entity.path);
          if (appInfo != null) {
            apps.add(appInfo);
          }
        }
      }
    } catch (e) {
      print('扫描目录失败: $directory - $e');
    }
  }

  Future<AppInfoModel?> _parseDesktopFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      // 检查是否包含Desktop Entry段
      if (!content.contains('[Desktop Entry]')) {
        return null;
      }

      // 提取Desktop Entry段的内容
      final entryContent = content
          .split('\n')
          .skipWhile((line) => !line.contains('[Desktop Entry]'))
          .takeWhile(
              (line) => !line.startsWith('[') || line == '[Desktop Entry]')
          .where((line) => line.contains('='))
          .map((line) => line.split('='))
          .map((parts) =>
              MapEntry(parts[0].trim(), parts.slice(1).join('=').trim()))
          .fold<Map<String, String>>({}, (map, entry) {
        map[entry.key] = entry.value;
        return map;
      });

      // 验证必要字段
      if (entryContent['Type'] != 'Application' ||
          entryContent['Exec'] == null ||
          (entryContent['NoDisplay'] == 'true' &&
              !entryContent['Exec']!.startsWith('gnome-control-center'))) {
        return null;
      }

      // 检查桌面环境兼容性
      final desktopSession =
          Platform.environment['DESKTOP_SESSION']?.toLowerCase() ?? '';
      final isGnome = desktopSession == 'ubuntu' || desktopSession == 'gnome';

      if (entryContent['OnlyShowIn'] != null) {
        final showIn = entryContent['OnlyShowIn']!.toLowerCase();
        if (isGnome && !showIn.contains('gnome')) {
          return null;
        }
      }

      if (entryContent['NotShowIn'] != null) {
        final notShowIn = entryContent['NotShowIn']!.toLowerCase();
        if ((isGnome && notShowIn.contains('gnome')) ||
            (desktopSession != '' && notShowIn.contains(desktopSession))) {
          return null;
        }
      }

      // 处理图标路径
      final iconPath =
          await _resolveIconPath(entryContent['Icon'] ?? '', filePath);
      if (iconPath == null) {
        return null;
      }

      // 处理程序执行命令
      var execCommand = entryContent['Exec']!
          .replaceAll(RegExp(r' %[A-Za-z]'), '') // 移除参数占位符
          .replaceAll('"', '')
          .trim();

      if (entryContent['Terminal'] == 'true') {
        execCommand = 'gnome-terminal -x $execCommand';
      }

      // 获取本地化的描述
      final description = _getLocalizedValue(entryContent, 'Comment',
              Platform.environment['LANG']?.split('.')[0] ?? 'en_US') ??
          filePath;

      // 生成关键词列表
      final keywords = <String>[entryContent['Name'] ?? ''];
      if (entryContent['X-Ubuntu-Gettext-Domain'] != null) {
        final domain = entryContent['X-Ubuntu-Gettext-Domain']!;
        if (domain != entryContent['Name']) {
          keywords.add(domain);
        }
      }

      return AppInfoModel(
          name: entryContent['Name'] ?? path.basenameWithoutExtension(filePath),
          path: filePath,
          icon: 'file://$iconPath',
          keywords: keywords,
          description: description);
    } catch (e) {
      print('解析桌面文件失败: $filePath - $e');
      return null;
    }
  }

  String? _getLocalizedValue(
      Map<String, String> entries, String key, String locale) {
    // 尝试获取本地化的值
    final localizedKey = '$key[$locale]';
    if (entries.containsKey(localizedKey)) {
      return entries[localizedKey];
    }
    // 回退到默认值
    return entries[key];
  }

  Future<String?> _resolveIconPath(
      String iconName, String desktopFilePath) async {
    if (iconName.isEmpty) return null;

    // 如果是绝对路径
    if (iconName.startsWith('/')) {
      return await File(iconName).exists() ? iconName : null;
    }

    // 检查应用程序是否在系统目录
    final isSystemApp = desktopFilePath.startsWith('/usr/share/applications') ||
        desktopFilePath.startsWith('/var/lib/snapd/desktop/applications');

    if (!isSystemApp) {
      // 检查本地图标
      final localIconPath = path.join(
          Platform.environment['HOME']!, '.local/share/icons', '$iconName.png');
      return await File(localIconPath).exists() ? localIconPath : null;
    }

    // 在系统图标主题中查找
    final themes = [
      'ubuntu-mono-dark',
      'ubuntu-mono-light',
      'Yaru',
      'hicolor',
      'Adwaita',
      'Humanity'
    ];

    final sizes = [
      '48x48',
      '48',
      'scalable',
      '256x256',
      '512x512',
      '256',
      '512'
    ];
    final types = [
      'apps',
      'categories',
      'devices',
      'mimetypes',
      'legacy',
      'actions',
      'places',
      'status',
      'mimes'
    ];
    final extensions = ['.png', '.svg'];

    // 在所有可能的位置查找图标
    for (final theme in themes) {
      for (final size in sizes) {
        for (final type in types) {
          for (final ext in extensions) {
            final iconPath = path.join(
                '/usr/share/icons', theme, size, type, iconName + ext);
            if (await File(iconPath).exists()) {
              return iconPath;
            }

            final alternatePath = path.join(
                '/usr/share/icons', theme, type, size, iconName + ext);
            if (await File(alternatePath).exists()) {
              return alternatePath;
            }
          }
        }
      }
    }

    // 检查 pixmaps 目录
    final pixmapPath = path.join('/usr/share/pixmaps', '$iconName.png');
    if (await File(pixmapPath).exists()) {
      return pixmapPath;
    }

    return null;
  }
}

extension ListExtension<T> on List<T> {
  List<T> slice(int start, [int? end]) {
    final actualEnd = end ?? length;
    return sublist(start, actualEnd > length ? length : actualEnd);
  }
}
